using System;
using System.Configuration;
using System.IO;

namespace Makolab.Printing.Web
{
    public partial class Export : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string format = Request.Form["outputFormat"];
            string filename = Request.Form["outputContentType"];

            string contentType = null;

            using (MemoryStream ms = new MemoryStream())
            {
                switch (format)
                {
                    case "pdf":
                        contentType = "application/pdf";
                        if (filename != "content")
                            filename += ".pdf";
                        break;
                    case "csv":
                        contentType = "application/octet-stream";
                        if (filename != "content")
                            filename += ".csv";
                        break;
                    case "xls":
                        contentType = "application/vnd.ms-excel";
                        if (filename != "content")
                            filename += ".xls";
                        break;
                    case "xml":
                        contentType = "text/xml";
                        if (filename != "content")
                            filename += ".xml";
                        break;
                    case "fiscal":
                        contentType = "text/plain";
                        if (filename != "content")
                            filename = null;
                        break;
                    case "vcard":
                        contentType = "text/x-vcard";
                        if (filename != "content")
                            filename += ".vcf";
                        break;
                    case "text":
                        contentType = "text/plain";
                        if (filename != "content")
                            filename += ".txt";
                        break;
                    default:
                        throw new InvalidOperationException("Unknown output format");
                }

                MakoPrint.Generate(Request.Form["xml"], this.LoadResource(ConfigurationManager.AppSettings["XsltFolder"], Request.Form["xsltName"]),
                    this.LoadResource(ConfigurationManager.AppSettings["PrintConfigFolder"], Request.Form["printConfigName"]),
                    this.LoadResource(ConfigurationManager.AppSettings["DriverConfigFolder"], Request.Form["driverConfig"]), format, ms);

                Response.AddHeader("Content-Type", contentType);
                Response.AddHeader("Content-Length", ms.Length.ToString());

                if (!String.IsNullOrEmpty(filename) && filename != "content")
                    Response.AddHeader("Content-Disposition", "attachment; filename=" + filename);

                if (ms.Length != 0)
                    Response.OutputStream.Write(ms.GetBuffer(), 0, (int)ms.Length);

                Response.OutputStream.Flush();
                Response.OutputStream.Close();
            }
        }

        private string LoadResource(string path, string filename)
        {
            if (String.IsNullOrEmpty(filename))
                return null;

            if (!path.EndsWith("\\"))
                path += "\\";

            using (FileStream fs = new FileStream(path + filename, FileMode.Open, FileAccess.Read))
            {
                using (StreamReader r = new StreamReader(fs))
                {
                    return r.ReadToEnd();
                }
            }
        }
    }
}
