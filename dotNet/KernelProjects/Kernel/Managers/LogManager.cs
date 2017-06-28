using System;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Threading;
using System.Xml;
using System.Xml.Linq;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.Managers
{
    public static class LogManager
    {
        public static void LogRemoteOrder(XElement request, string response)
        {
            Monitor.Enter(typeof(LogManager));
            FileStream file = null;
            StreamReader reader = null;
            XmlWriter writer = null;

            try
            {
                string logFolder = ConfigurationManager.AppSettings["RemoteOrderLogFolder"];

                if (String.IsNullOrEmpty(logFolder))
                    return;

                if (!Path.IsPathRooted(logFolder))
                    logFolder = Path.Combine(AppDomain.CurrentDomain.SetupInformation.ApplicationBase, logFolder);

                if (logFolder[logFolder.Length - 1] == '\\')
                    logFolder = logFolder.Substring(0, logFolder.Length - 1);

                DateTime now = DateTime.Now;

                file = new FileStream(String.Format(CultureInfo.InvariantCulture, "{0}\\RemoteOrder {1}-{2}-{3}.xml",
                    logFolder, now.Year, now.Month.ToString("D2", CultureInfo.InvariantCulture), now.Day.ToString("D2", CultureInfo.InvariantCulture)),
                    FileMode.OpenOrCreate);

                reader = new StreamReader(file);

                XDocument log = null;

                if (file.Length != 0) //log already exists
                {
                    log = XDocument.Parse(reader.ReadToEnd());
                }
                else //create new log
                {
                    log = XDocument.Parse("<logs/>");
                }

                XElement logElement = new XElement("log");
                logElement.Add(new XElement("dateTime", now.Round(DateTimeAccuracy.Millisecond).ToIsoString()));
                logElement.Add(new XElement("request", request));

                XElement responseXml = null;

                try
                {
                    responseXml = XElement.Parse(response);
                }
                catch (Exception)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:103");
                    RoboFramework.Tools.RandomLogHelper.GetLog().Fatal("EXCEPTION: What is this exception??");
                }

                if (responseXml != null)
                    logElement.Add(new XElement("response", responseXml));
                else
                    logElement.Add(new XElement("response", response));

                log.Root.Add(logElement);

                file.SetLength(0); //clear the file
                writer = XmlWriter.Create(file);
                log.WriteTo(writer);
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: What is this exception? (2)");
            }
            finally
            {
                if (writer != null)
                    writer.Close();

                if (reader != null)
                    reader.Dispose();

                Monitor.Exit(typeof(LogManager));
            }
        }
    }
}
