using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using log4net;
using System.Configuration;
using Makolab.Fractus.SalesOrderTracker;
using System.Xml.Linq;
using System.Security.Cryptography;
using System.Text;

namespace XmlStoreProcedureProxy
{
    public partial class authenticate : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (Request.HttpMethod == "POST")
                {
                    XDocument loginInfo = XDocument.Load(System.Xml.XmlReader.Create(Request.InputStream));

                    if (loginInfo.Root.Elements().Any() == false)
                    {
                        var challenge = Guid.NewGuid();
                        Session["challenge"] = challenge;
                        Response.ContentType = "text/xml";
                        Response.Write(String.Format("<root>{0}</root>", challenge));
                    }
                    else
                    {
                        if (Session["challenge"] == null)
                        {
                            Response.StatusCode = (int)System.Net.HttpStatusCode.BadRequest;
                            Response.Write("Nie wygenerowano challenge");
                        }
                        else
                        {
                            string login = loginInfo.Root.Element("username").Value;
                            string password = loginInfo.Root.Element("password").Value;

                            var connStrCfg = ConfigurationManager.ConnectionStrings["db"];
                            if (connStrCfg == null) throw new ConfigurationErrorsException("Brak połączenia do bazy o nazwie db w konfiguracji.");

                            var dbHelper = new DatabaseHelper(connStrCfg.ConnectionString);

                            var result = dbHelper.ExecuteXmlStoreProcedure(ConfigurationManager.AppSettings["loginSP"],
                                                                           dbHelper.CreateSqlParameter("@login",
                                                                                                       System.Data.SqlDbType.NVarChar,
                                                                                                       login));

                            var userElement = result.Root.Element("applicationUser").Element("entry");
                            if (userElement == null) Response.StatusCode = (int)System.Net.HttpStatusCode.BadRequest;
                            else
                            {
                                var pwdWithSalt = HashPasswordWithChallenge(userElement.Element("password").Value, Session["challenge"].ToString());

                                if (pwdWithSalt.Equals(password, StringComparison.OrdinalIgnoreCase))
                                {
                                    userElement.Element("password").Remove();
                                    Session["user"] = userElement;
                                    Response.StatusCode = (int)System.Net.HttpStatusCode.OK;
                                }
                                else Response.StatusCode = (int)System.Net.HttpStatusCode.BadRequest;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.StatusCode = 400;
                Response.Write(ex.Message);
                ILog log = log4net.LogManager.GetLogger(typeof(_execute));
                log.Error(ex.ToString());
            }
        }

        private static string HashPasswordWithChallenge(string pwd, string challenge)
        {
            var pwdWithSalt = String.Concat(pwd, challenge);

            return BitConverter.ToString(new SHA256Managed()
                                                    .ComputeHash(Encoding.UTF8.GetBytes(pwdWithSalt)))
                              .ToUpperInvariant()
                              .Replace("-", "");
        }
    }
}