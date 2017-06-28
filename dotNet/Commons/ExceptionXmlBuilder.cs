using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using System.Reflection;
using System.IO;
using System.Data.SqlClient;
using System.Globalization;
using System.Configuration;

namespace Makolab.Fractus.Commons
{
	public class ExceptionXmlBuilder<ExceptionType>
			where ExceptionType : Exception, IClientException 
	{
		private string exceptionTemplatesXmlPath = null;
		private bool logHandledExceptions = true;
		private string logFolder = null;
		private string version = null;
		private string language = "pl";

		public ExceptionXmlBuilder()
		{
			this.version = this.GetVersion();
			this.exceptionTemplatesXmlPath = ConfigurationManager.AppSettings["ExceptionTemplatesXmlPath"];
			this.logHandledExceptions = Convert.ToBoolean(ConfigurationManager.AppSettings["LogHandledExceptions"] ?? "true");
			this.logFolder = ConfigurationManager.AppSettings["LogFolder"];
			this.language = ConfigurationManager.AppSettings["Language"] ?? "pl";
		}

		public XDocument CreateExceptionXml(Exception ex) 
		{
			//load exceptions templates
			XDocument exceptionsTemplates;
			Assembly kernelAssembly = Assembly.GetAssembly(typeof(ExceptionType));
			StreamReader exReader = new StreamReader(kernelAssembly.GetManifestResourceStream(this.exceptionTemplatesXmlPath));

			exceptionsTemplates = XDocument.Parse(exReader.ReadToEnd());
			exReader.Dispose();
			//

			XDocument exceptionXml = XDocument.Parse("<exception/>");

			SqlException sqlEx = ex as SqlException;

			ExceptionType cex = ex as ExceptionType;

			string clientExceptionIdString = null;

			if (sqlEx != null && sqlEx.Number == -2)
			{
				clientExceptionIdString = "SqlTimeout";
			}

			if (cex != null || clientExceptionIdString != null)
			{
				var exNode = from node in exceptionsTemplates.Root.Elements()
							 where node.Attribute("id").Value == (clientExceptionIdString ?? cex.ClientExceptionIdString)
							 select node;

				//copy exception template nodes to the final exception xml
				foreach (XElement element in exNode.ElementAt(0).Elements())
					exceptionXml.Root.Add(element);

				foreach (XAttribute attribute in exNode.ElementAt(0).Attributes())
					exceptionXml.Root.Add(attribute);
				//

				//inject parameters into exception xml
				if (cex.Parameters != null)
				{
					foreach (string parameter in cex.Parameters)
					{
						//dont use split because parameter value can include ':'
						int delimiterIndex = parameter.IndexOf(':');
						string key = parameter.Substring(0, delimiterIndex);
						string value = parameter.Substring(delimiterIndex + 1, parameter.Length - delimiterIndex - 1);

						foreach (XElement element in exceptionXml.Root.Descendants())
						{
							if (!element.HasElements)
								element.Value = element.Value.Replace("%" + key + "%", value);
						}
					}
				}

				if (cex.XmlData != null)
					exceptionXml.Root.Add(cex.XmlData);

				if (this.logHandledExceptions)
					this.LogException(ex);
				else if (cex.InnerException != null)
					this.LogException(cex.InnerException);
			}
			else
			{
				//if its an unhandled exception
				var exNode = from node in exceptionsTemplates.Root.Elements()
							 where node.Attribute("id").Value == "UNHANDLED_EXCEPTION"
							 select node;

				//copy exception template nodes to the final exception xml
				foreach (XElement element in exNode.ElementAt(0).Elements())
					exceptionXml.Root.Add(element);

				foreach (XAttribute attribute in exNode.ElementAt(0).Attributes())
					exceptionXml.Root.Add(attribute);
				//

				exceptionXml.Root.Element("message").Value = ex.Message;
				exceptionXml.Root.Element("className").Value = ex.GetType().ToString();
				exceptionXml.Root.Element("serverVersion").Value = this.version;

				//if (ex.InnerException != null)
				//{
				//    exceptionXml.Root.Add(ServiceHelper.Instance.CreateInnerExceptionXml(ex.InnerException));
				//}

				int logNumber = this.LogException(ex);

				if (logNumber > 0)
					exceptionXml.Root.Element("logNumber").Value = logNumber.ToString(CultureInfo.InvariantCulture);
				else
					exceptionXml.Root.Element("logNumber").Remove();
			}

			//leave only one language
			string userLang = this.language;

			var localizableNodes = from node in exceptionXml.Root.Elements()
								   where node.Attribute("lang") != null
								   group node by node.Name.LocalName into g
								   select g;

			foreach (var nodesGroup in localizableNodes)
			{
				var preferredLang = from node in nodesGroup
									where node.Attribute("lang").Value == userLang
									select node;

				XElement preferredElement = null;

				if (preferredLang.Count() > 0)
					preferredElement = preferredLang.ElementAt(0);
				else //select the first one
					preferredElement = nodesGroup.ElementAt(0);

				//delete the others
				foreach (XElement element in nodesGroup)
				{
					if (element != preferredElement)
						element.Remove();
				}
			}

			return exceptionXml;
		}

		private int LogException(Exception ex)
		{
			return Utils.LogException(ex, typeof(ExceptionType), this.logFolder);
		}

		private string GetVersion()
		{
			Assembly kernelAssembly = Assembly.GetAssembly(typeof(ExceptionType));
			return Assembly.GetExecutingAssembly().GetName().Version.ToString() + "/" + kernelAssembly.GetName().Version.ToString();
		}
	}


	public interface IClientException
	{
		string ClientExceptionIdString { get; }
		ICollection<string> Parameters { get; }
		XElement XmlData { get; set; }
	}
}
