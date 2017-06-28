using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using Makolab.Fractus.SalesOrderTracker;
using System.Configuration;
using log4net;

namespace XmlStoreProcedureProxy
{
    public partial class _execute : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (ConfigurationManager.AppSettings["requireAuthentication"].Equals("true", StringComparison.OrdinalIgnoreCase) && Session["user"] == null)
                {
                    throw new UnauthorizedAccessException("Użytkownik nie zalogowany.");
                }

                if (Request.HttpMethod == "POST")
                {
                    XDocument data = XDocument.Load(System.Xml.XmlReader.Create(Request.InputStream));
                    var spNameAttribute = data.Root.Attribute("sp");

                    if (spNameAttribute == null) throw new ArgumentException("Niepoprawny format XMLa: brak atrybutu z nazwą procedury");

                    var connStrCfg = ConfigurationManager.ConnectionStrings["db"];
                    if (connStrCfg == null) throw new ConfigurationErrorsException("Brak połączenia do bazy o nazwie db w konfiguracji.");

                    var dbHelper = new DatabaseHelper(connStrCfg.ConnectionString);

                    var result = dbHelper.ExecuteXmlStoreProcedure(spNameAttribute.Value,
                                                                   dbHelper.CreateSqlParameter("@xml",
                                                                                               System.Data.SqlDbType.Xml,
                                                                                               dbHelper.CreateSqlXml(data)));

                    Response.ContentType = "text/xml";
                    Response.Write(result.ToString(SaveOptions.DisableFormatting));
                    //result.WriteTo(System.Xml.XmlWriter.Create(Response.Output));
                }
            }
            catch (UnauthorizedAccessException ex)
            {
                Response.StatusCode = (int)System.Net.HttpStatusCode.Unauthorized;
                ILog log = log4net.LogManager.GetLogger(typeof(_execute));
                log.Error(ex.ToString());
            }
            catch (Exception ex)
            {
                Response.StatusCode = (int)System.Net.HttpStatusCode.BadRequest;
                Response.Write(ex.Message);
                ILog log = log4net.LogManager.GetLogger(typeof(_execute));
                log.Error(ex.ToString());
            }
        }
    }
}