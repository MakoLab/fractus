using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using System.Reflection;
using System.IO;
using Makolab.Fractus.Kernel.Exceptions;
using System.Data.SqlClient;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Mappers;
using System.Globalization;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.Managers.Logging
{
	public abstract class ExceptionLogger : LoggerBase<Exception>
	{
		private string GetVersion()
		{
			Assembly kernelAssembly = Assembly.GetAssembly(typeof(Kernel.Exceptions.ClientException));
			return Assembly.GetExecutingAssembly().GetName().Version.ToString() + "/" + kernelAssembly.GetName().Version.ToString();
		}

		private Exception GetExceptionToBeLogged(Exception ex)
		{
			ClientException cex = ex as ClientException;

			SqlException sqlEx = ex as SqlException;

			RawClientException rcex = ex as RawClientException;

			if (sqlEx != null && sqlEx.Number == -2)
			{
				cex = new ClientException(ClientExceptionId.SqlTimeout);
			}

			if (cex != null)
			{
				if (ConfigurationMapper.Instance.LogHandledExceptions)
					return ex;
				else if (cex.InnerException != null)
					return cex.InnerException;
			}
			else if (rcex != null && ConfigurationMapper.Instance.LogHandledExceptions)
			{
				return ex;
			}

			//if its an unhandled exception
			return ex;
		}

		protected override void AddItemInfoToLogElement(XElement logElement, Exception ex)
		{
			if (SessionManager.SessionId != null)
			{
				XDocument requestXml = SessionManager.VolatileElements.ClientRequest;

				if (requestXml != null)
					logElement.Add(new XElement("requestXml", requestXml.Root));
			}

			XElement additionalNodes = null;

			ClientException cex = ex as ClientException;

			if (cex != null)
			{
				additionalNodes = new XElement("clientException");
				additionalNodes.Add(new XElement("id", cex.Id.ToString()));

				if (cex.Parameters != null)
				{
					string parameters = String.Empty;

					foreach (var par in cex.Parameters)
					{
						parameters += (par + ";");
					}

					additionalNodes.Add(new XElement("parameters", parameters));
				}

				if (cex.XmlData != null)
					additionalNodes.Add(new XElement("xmlData", new XElement(cex.XmlData)));
			}

			logElement.Add(Utils.CreateInnerExceptionXml(ex, this.GetVersion(), true, additionalNodes).Elements());
		}
	}
}
