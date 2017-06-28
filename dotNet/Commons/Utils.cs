using System;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Xml.Linq;
using System.Collections.Generic;
using System.IO;
using System.Collections;
using System.Threading;
using System.Xml;

namespace Makolab.Fractus.Commons
{
    public static class Utils
    {
        public static XElement CreateInnerExceptionXml(Exception ex, string serverVersion, bool includeStackTrace)
        {
            return Utils.CreateInnerExceptionXml(ex, serverVersion, includeStackTrace, null);
        }

        /// <summary>
        /// Creates <see cref="XElement"/> for the <see cref="Exception"/>.
        /// </summary>
        /// <param name="ex">The exception to create the <see cref="XElement"/> for</param>
        /// <returns>Created exception's <see cref="XElement"/>.</returns>
        public static XElement CreateInnerExceptionXml(Exception ex, string serverVersion, bool includeStackTrace, XElement additionalElement)
        {
            XElement logElement = new XElement("innerException");

            logElement.Add(new XElement("className", ex.GetType().ToString()));
            logElement.Add(new XElement("message", ex.Message));

            if (includeStackTrace)
                logElement.Add(new XElement("stackTrace", ex.StackTrace));

            if (!String.IsNullOrEmpty(serverVersion))
                logElement.Add(new XElement("serverVersion", serverVersion));

            logElement.Add(new XElement("targetSite", ex.TargetSite));

            if (additionalElement != null)
                logElement.Add(additionalElement);

            string parameters = String.Empty;

            foreach (string key in ex.Data.Keys)
            {
                parameters += String.Format(CultureInfo.InvariantCulture, "{0}:{1}, ", key, ex.Data[key]);
            }

            if (!String.IsNullOrEmpty(parameters))
            {
                //truncate last comma and space
                parameters = parameters.Substring(0, parameters.Length - 2);

                logElement.Add(new XElement("data", parameters));
            }

            SqlException sqlex = ex as SqlException;

            if (sqlex != null)
            {
                logElement.Add(new XElement("number", sqlex.Number.ToString(CultureInfo.InvariantCulture)));
                logElement.Add(new XElement("procedure", sqlex.Procedure));
                logElement.Add(new XElement("lineNumber", sqlex.LineNumber.ToString(CultureInfo.InvariantCulture)));
            }

            if (ex.InnerException != null)
                logElement.Add(Utils.CreateInnerExceptionXml(ex.InnerException, null, includeStackTrace, null));

            return logElement;
        }

        public static int LogException(Exception ex, Type lockType, string logFolder)
        {
            Monitor.Enter(lockType);
            FileStream file = null;
            StreamReader reader = null;
            XmlWriter writer = null;

            try
            {
                if (!Path.IsPathRooted(logFolder))
                    logFolder = Path.Combine(AppDomain.CurrentDomain.SetupInformation.ApplicationBase, logFolder);

                if (logFolder[logFolder.Length - 1] == '\\')
                    logFolder = logFolder.Substring(0, logFolder.Length - 1);

                DateTime now = DateTime.Now;

                file = new FileStream(String.Format(CultureInfo.InvariantCulture, "{0}\\{1}-{2}-{3}.xml",
                    logFolder, now.Year, now.Month.ToString("D2", CultureInfo.InvariantCulture), now.Day.ToString("D2", CultureInfo.InvariantCulture)),
                    FileMode.OpenOrCreate);

                reader = new StreamReader(file);

                XDocument log = null;
                int logNumber = 1;

                if (file.Length != 0) //log already exists
                {
                    log = XDocument.Parse(reader.ReadToEnd());
                    logNumber = Convert.ToInt32(((XElement)log.Root.LastNode).Attribute("number").Value, CultureInfo.InvariantCulture);
                    logNumber++;
                }
                else //create new log
                {
                    log = XDocument.Parse("<logs/>");
                }

                XElement logElement = new XElement("log");
                logElement.Add(new XAttribute("number", logNumber));
                logElement.Add(new XElement("dateTime", now.Round(DateTimeAccuracy.Millisecond).ToIsoString()));

                logElement.Add(Utils.CreateInnerExceptionXml(ex, "1.0", true).Elements());

                log.Root.Add(logElement);

                file.SetLength(0); //clear the file
                writer = XmlWriter.Create(file);
                log.WriteTo(writer);

                return logNumber;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:2");
                return 0;
            }
            finally
            {
                if (writer != null)
                    writer.Close();

                if (reader != null)
                    reader.Dispose();

                Monitor.Exit(lockType);
            }
        }

        public static bool IsNewValue(XElement previousValuesXml, string newValue)
        {
            if (String.IsNullOrEmpty(newValue))
                return false;
            if (previousValuesXml == null || !previousValuesXml.HasElements)
                return true;

            return !previousValuesXml.Elements().Any(oldValue => oldValue != null && oldValue.Value == newValue);
        }

        public static string ResolveMessage(string template, params string[] parameters)
        {
            IEnumerator paramsPtr = parameters.GetEnumerator();
            while (paramsPtr.MoveNext())
            {
                string containerName = (string)paramsPtr.Current;
                if (paramsPtr.MoveNext())
                {
                    string paramValue = (string)paramsPtr.Current;
                    template = template.Replace(String.Format("%{0}%", containerName), paramValue);
                }
                else
                    break;
            }

            return template;
        }
    }
}
