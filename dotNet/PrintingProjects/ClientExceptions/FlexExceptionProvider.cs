using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.Xml;
using System.Reflection;
using System.IO;

namespace Makolab.Fractus.Commons
{
    public class FlexExceptionProvider
    {
        public static FaultException GetClientException(Exception exception, string userLanguage)
        {
            if (exception == null) throw new ArgumentNullException("exception");
            if (String.IsNullOrEmpty(userLanguage)) throw new ArgumentException("userLanguage");

            XmlDocument exceptionXml = null;

            ClientException clientEx = exception as ClientException;
            if (clientEx != null) exceptionXml = CreateHandledException(clientEx, clientEx.Id, clientEx.MessageTemplateName, clientEx.Parameters);
            else 
            {
                ExceptionProperties prop = new ExceptionProperties(exception);
                if (prop.MessageType == ExceptionMessageType.Extended && CanHandleException(prop)) exceptionXml = CreateHandledException(prop.Source, prop.Id, prop.MessageTemplateName, prop.Parameters);
                else if (prop.MessageType == ExceptionMessageType.Simple) exceptionXml = CreateSimpleHandledException(prop.Source);
                else exceptionXml = CreateUnhandledException(exception);
            }
            FilterLanguageMessages(userLanguage, exceptionXml);

            return new FaultException(exceptionXml.OuterXml);
        }

        private static void FilterLanguageMessages(string userLanguage, XmlDocument exceptionXml)
        {
            List<XmlNode> localizedElements = new List<XmlNode>();
            foreach (XmlNode node in exceptionXml.DocumentElement.ChildNodes)
            {
                if (node.Attributes["lang"] != null) localizedElements.Add(node);
            }

            List<List<XmlNode>> groupedLocalizedElements = new List<List<XmlNode>>();
            List<XmlNode> checkedNodes = new List<XmlNode>();
            foreach (XmlNode node in localizedElements)
            {
                if (checkedNodes.Find(n => n.LocalName == node.LocalName) == null)
                {
                    groupedLocalizedElements.Add(localizedElements.FindAll(n => n.LocalName == node.LocalName));
                    checkedNodes.Add(node);
                }
            }

            foreach (List<XmlNode> groupedNodes in groupedLocalizedElements)
            {
                XmlNode preferredLang = groupedNodes.Find(n => n.Attributes["lang"].Value.Equals(userLanguage, StringComparison.OrdinalIgnoreCase));
                if (preferredLang == null) preferredLang = groupedNodes[0];
                foreach (XmlNode node in groupedNodes)
                {
                    if (node != preferredLang) node.ParentNode.RemoveChild(node);
                }
            }
        }

        /// <summary>
        /// Gets the version of executing assembly and the kernel assembly.
        /// </summary>
        /// <returns><see cref="System.String"/> that represents both versions separated by slash character.</returns>
        public static string GetVersion(Exception exception)
        {
            Assembly exceptionAssembly = Assembly.GetAssembly(exception.GetType());
            return Assembly.GetExecutingAssembly().GetName().Name + "-" + Assembly.GetExecutingAssembly().GetName().Version.ToString() + 
                    "/" + exceptionAssembly.GetName().Name + "-" + exceptionAssembly.GetName().Version.ToString();
        }

        private static XmlDocument CreateHandledException(Exception exception, string exceptionId, string messageTeplateName, ICollection<string> parameters)
        {
            XmlDocument exceptionsTemplate = new XmlDocument();
            Assembly excTemplateAssembly = Assembly.GetAssembly(exception.GetType());
            using (StreamReader exReader = new StreamReader(excTemplateAssembly.GetManifestResourceStream(messageTeplateName)))
            {
                exceptionsTemplate.LoadXml(exReader.ReadToEnd());
            }

            XmlDocument exceptionXml = new XmlDocument();
            exceptionXml.LoadXml("<exception/>");
            XmlNode excNode = exceptionsTemplate.DocumentElement.SelectSingleNode(String.Format("exception[@id='{0}']", exceptionId));
            if (excNode != null) PrepareExeptionMessage(parameters, exceptionXml, excNode);
            else
            {
                XmlNode msg = exceptionXml.CreateNode(XmlNodeType.Element, "customMessage", "");
                msg.InnerText = exception.Message;
                exceptionXml.DocumentElement.AppendChild(msg);
            }

            return exceptionXml;       
        }

        /// <summary>
        /// Creates the simple handled exception - exception with message from taken from exception property.
        /// </summary>
        /// <param name="exception">The exception.</param>
        /// <returns>Xml containing exception message.</returns>
        private static XmlDocument CreateSimpleHandledException(Exception exception)
        {
            XmlDocument exceptionsTemplate = new XmlDocument();
            Assembly excTemplateAssembly = Assembly.GetAssembly(typeof(FlexExceptionProvider));
            using (StreamReader exReader = new StreamReader(excTemplateAssembly.GetManifestResourceStream("Makolab.Fractus.Commons.Exceptions.xml")))
            {
                exceptionsTemplate.LoadXml(exReader.ReadToEnd());
            }

            XmlDocument exceptionXml = new XmlDocument();
            exceptionXml.LoadXml("<exception/>");

            //get simple exception node
            XmlNode excNode = exceptionsTemplate.DocumentElement.SelectSingleNode("exception[@id='SIMPLE_EXCEPTION']");
            if (excNode != null) PrepareExeptionMessage(null, exceptionXml, excNode);

            exceptionXml.DocumentElement.SelectSingleNode("extendedCustomMessage").InnerText = exception.Message;
            return exceptionXml;
        }

        private static XmlDocument CreateUnhandledException(Exception exception)
        {
            XmlDocument exceptionsTemplate = new XmlDocument();
            Assembly excTemplateAssembly = Assembly.GetAssembly(typeof(FlexExceptionProvider));
            using (StreamReader exReader = new StreamReader(excTemplateAssembly.GetManifestResourceStream("Makolab.Fractus.Commons.Exceptions.xml")))
            {
                exceptionsTemplate.LoadXml(exReader.ReadToEnd());
            }

            XmlDocument exceptionXml = new XmlDocument();
            exceptionXml.LoadXml("<exception/>");

            //get unhandled exception node
            XmlNode excNode = exceptionsTemplate.DocumentElement.SelectSingleNode("exception[@id='UNHANDLED_EXCEPTION']");
            PrepareExeptionMessage(null, exceptionXml, excNode);

            exceptionXml.DocumentElement.SelectSingleNode("message").InnerText = exception.Message;
            exceptionXml.DocumentElement.SelectSingleNode("className").InnerText = exception.GetType().ToString();
            exceptionXml.DocumentElement.SelectSingleNode("serverVersion").InnerText = GetVersion(exception);

            return exceptionXml;
        }

        private static bool CanHandleException(ExceptionProperties exception)
        {
            if (exception.IdProperty == null || exception.IdProperty.CanRead == false) return false;
            if (exception.MessageTemplateNameProperty == null || exception.MessageTemplateNameProperty.CanRead == false) return false;
            if (exception.ParametersProperty == null || exception.ParametersProperty.CanRead == false) return false;

            return true;
        }

        private static void PrepareExeptionMessage(ICollection<string> exceptionParameters, XmlDocument exceptionXml, XmlNode excNode)
        {
            foreach (XmlNode node in excNode.ChildNodes)
            {
                exceptionXml.DocumentElement.AppendChild(exceptionXml.ImportNode(node, true));
            }

            foreach (XmlAttribute attib in excNode.Attributes)
            {
                exceptionXml.DocumentElement.Attributes.Append((XmlAttribute)exceptionXml.ImportNode(attib, false));
            }

            //inject parameters into exception xml
            if (exceptionParameters != null)
            {
                foreach (string parameter in exceptionParameters)
                {
                    //dont use split because parameter value can include ':'
                    int delimiterIndex = parameter.IndexOf(':');
                    string key = parameter.Substring(0, delimiterIndex);
                    string value = parameter.Substring(delimiterIndex + 1, parameter.Length - delimiterIndex - 1);

                    foreach (XmlNode node in exceptionXml.DocumentElement.ChildNodes)
                    {
                        node.InnerText = node.InnerText.Replace("%" + key + "%", value);
                    }
                }
            }
        }
    }

}
