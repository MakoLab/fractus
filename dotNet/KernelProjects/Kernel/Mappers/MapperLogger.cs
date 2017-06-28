using System;
using System.IO;
using System.Xml.Linq;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Class that logs communication between mappers and a database to a file.
    /// </summary>
    public static class MapperLogger
    {
        /// <summary>
        /// Gets the log file.
        /// </summary>
        /// <returns>Xml log file content.</returns>
        private static XDocument GetLogFile()
        {
            XDocument retXml = null;

            if (File.Exists(ConfigurationMapper.Instance.DatabaseCommunicationLogPath))
                retXml = XDocument.Load(ConfigurationMapper.Instance.DatabaseCommunicationLogPath);
            else
                retXml = XDocument.Parse("<root/>");

            return retXml;
        }

        /// <summary>
        /// Saves the log file.
        /// </summary>
        /// <param name="xml">Xml log file content.</param>
        private static void SaveLogFile(XDocument xml)
        {
            xml.Save(ConfigurationMapper.Instance.DatabaseCommunicationLogPath);
        }

        /// <summary>
        /// Logs the database operation.
        /// </summary>
        /// <param name="procedure">Stored procedure name.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result..</param>
        /// <param name="xml">Input xml.</param>
        /// <param name="retValue">Xml procedure's result.</param>
        public static void LogOperation(StoredProcedure procedure, bool hasResult, XDocument xml, XDocument retValue)
        {
            XDocument outXml = MapperLogger.GetLogFile();

            XElement element = new XElement("operation");
            element.Add(new XElement("procedure", procedure.ToString()));
            element.Add(new XElement("hasResult", hasResult.ToString()));

            if (xml != null)
                element.Add(new XElement("xml", xml.Root)); //auto-cloning

            if (retValue != null)
                element.Add(new XElement("retValue", retValue.Root)); //auto-cloning

            outXml.Root.Add(element);

            MapperLogger.SaveLogFile(outXml);
        }

        /// <summary>
        /// Logs the database operation.
        /// </summary>
        /// <param name="procedure">Stored procedure name.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result..</param>
        /// <param name="firstParamName">First parameter's name.</param>
        /// <param name="firstParamValue">First parameter's value.</param>
        /// <param name="secondParamName">Second parameter's name.</param>
        /// <param name="secondParamValue">Second parameter's value.</param>
        /// <param name="retValue">Xml procedure's result.</param>
        public static void LogOperation(StoredProcedure procedure, bool hasResult, string firstParamName, Guid? firstParamValue, string secondParamName, Guid? secondParamValue, string thirdParamName, Guid? thirdParamValue,
            string fourthParamName, Guid? fourthParamValue, XDocument retValue)
        {
            XDocument outXml = MapperLogger.GetLogFile();

            XElement element = new XElement("operation");
            element.Add(new XElement("procedure", procedure.ToString()));
            element.Add(new XElement("hasResult", hasResult.ToString()));

            if (firstParamName != null)
                element.Add(new XElement("firstParamValue", firstParamValue.ToUpperString()));

            if (secondParamName != null)
                element.Add(new XElement("secondParamValue", secondParamValue.ToUpperString()));

            if (thirdParamName != null)
                element.Add(new XElement("thirdParamValue", thirdParamValue.ToUpperString()));

            if (fourthParamName != null)
                element.Add(new XElement("fourthParamName", fourthParamValue.ToUpperString()));

            if (retValue != null)
                element.Add(new XElement("retValue", retValue.Root)); //auto-cloning

            outXml.Root.Add(element);

            MapperLogger.SaveLogFile(outXml);
        }

        /// <summary>
        /// Logs the database operation.
        /// </summary>
        /// <param name="procedure">Stored procedure name.</param>
        /// <param name="hasResult">Specifies whether the stored procedure queries the database for a result..</param>
        /// <param name="firstParamName">First parameter's name.</param>
        /// <param name="firstParamValue">First parameter's value.</param>
        /// <param name="retValue">Xml procedure's result.</param>
        public static void LogOperation(StoredProcedure procedure, bool hasResult, string firstParamName, string firstParamValue, XDocument retValue)
        {
            XDocument outXml = MapperLogger.GetLogFile();

            XElement element = new XElement("operation");
            element.Add(new XElement("procedure", procedure.ToString()));
            element.Add(new XElement("hasResult", hasResult.ToString()));

            if (firstParamName != null)
                element.Add(new XElement("firstParamValue", firstParamValue));

            if (retValue != null)
                element.Add(new XElement("retValue", retValue.Root)); //auto-cloning

            outXml.Root.Add(element);

            MapperLogger.SaveLogFile(outXml);
        }
    }
}
