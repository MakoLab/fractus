using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.ServiceModel;
using System.Threading;
using System.Web.Hosting;
using System.Xml;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.HelperObjects;
using KernelHelpers;

namespace Makolab.Fractus.Kernel.Services
{
    /// <summary>
    /// Helper class that contains common methods used by the services.
    /// </summary>
    public abstract class ServiceHelper
    {
        /// <summary>
        /// Instance of <see cref="ServiceHelper"/>.
        /// </summary>
        private static ServiceHelper instance = ServiceHelper.CreateInstance();

        /// <summary>
        /// Gets the instance of <see cref="ServiceHelper"/>.
        /// </summary>
        public static ServiceHelper Instance
        {
            get { return ServiceHelper.instance; }
        }

        /// <summary>
        /// Creates the proper <see cref="ServiceHelper"/> instance.
        /// </summary>
        /// <returns>Created <see cref="ServiceHelper"/> instance.</returns>
        private static ServiceHelper CreateInstance()
        {
            FractusKernelSectionHandler handler = (FractusKernelSectionHandler)ConfigurationManager.GetSection("fractusKernel");
            bool desktopMode = handler.DesktopMode;

            if (desktopMode)
                return new DesktopServiceHelper();
            else
                return new WebServiceHelper();
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ServiceHelper"/> class.
        /// </summary>
        protected ServiceHelper()
        { }

        /// <summary>
        /// Gets the client address (ip address or host name).
        /// </summary>
        /// <returns>Client IP address or hostname.</returns>
        protected abstract string GetHostAddress();

        /// <summary>
        /// Performs login operation using specified credentials.
        /// </summary>
        /// <param name="username">Username.</param>
        /// <param name="password">Password (SHA 256 hash).</param>
        /// <param name="language">User's language version.</param>
        /// <returns>
        /// Created sessionId if successful; otherwise, <see cref="ClientException"/> is thrown.
        /// </returns>
        public string LogOn(string username, string password, string language)
        {
            return this.LogOn(username, password, language, null);
        }

        public string LogOn(string username, string password, string language, string profile)
        {
            try
            {
                Guid sessionId = SecurityManager.Instance.LogOn(username, password, language, this.GetHostAddress());
                User usr = SessionManager.User;
                Guid userId = usr.UserId;
                Guid branchId = usr.BranchId;
                Guid companyId = usr.CompanyId;

                if (!String.IsNullOrEmpty(profile))
                    SessionManager.Profile = profile;

                XElement retXml = new XElement("root",
                    new XElement("sessionId", sessionId.ToUpperString()),
                    new XElement("userId", userId.ToUpperString()),
                    new XElement("branchId", branchId.ToUpperString()),
                    new XElement("companyId", companyId.ToUpperString()),
                    new XElement("isHeadquarter", ConfigurationMapper.Instance.IsHeadquarter.ToString(CultureInfo.InvariantCulture)),
                    new XElement("permissionProfile", usr.PermissionProfile),
                    new XElement("version", this.GetVersion())
                    );

                if (!String.IsNullOrEmpty(profile))
                {
					if (ConfigurationMapper.Instance.Profiles != null && ConfigurationMapper.Instance.Profiles.ContainsKey(profile))
					{
						var attr = ConfigurationMapper.Instance.Profiles[profile].Attribute("id");

						if (attr != null)
						{
							retXml.Add(new XElement("userProfileId", attr.Value));
							SessionManager.ProfileId = attr.Value;
						}
						else
							SessionManager.ProfileId = null;
					}
					else
					{
						SessionManager.Profile = null;
						SessionManager.ProfileId = null;
					}
                }

                return retXml.ToString(SaveOptions.DisableFormatting);
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:611");
                ServiceHelper.Instance.OnException(ex);
            }

            return null;
        }

        /// <summary>
        /// Gets the client language version.
        /// </summary>
        /// <returns>Client language version.</returns>
        protected abstract string GetClientLanguageVersion();

        public XDocument CreateExceptionXml(Exception ex)
        {
            //load exceptions templates
            XDocument exceptionsTemplates;
            Assembly kernelAssembly = Assembly.GetAssembly(typeof(Kernel.Exceptions.ClientException));
            StreamReader exReader = new StreamReader(kernelAssembly.GetManifestResourceStream("Makolab.Fractus.Kernel.Templates.Exceptions.xml"));

            exceptionsTemplates = XDocument.Parse(exReader.ReadToEnd());
            exReader.Dispose();
            //

            ClientException cex = ex as ClientException;
            XDocument exceptionXml = XDocument.Parse("<exception/>");

            SqlException sqlEx = ex as SqlException;

            RawClientException rcex = ex as RawClientException;

			TypeInitializationException tiex = ex as TypeInitializationException;

			//Rzucenie wyjątkiem w konstruktorze wywoła wyjątek TypeInitializationException
			//Jeśli jest wywołany obsłużonym wyjątkiem to taki zostanie przetworzony
			if (tiex != null && tiex.InnerException != null)
			{
				ClientException innercex = tiex.InnerException as ClientException;
				if (innercex != null)
				{
					cex = innercex;
				}
			}

            if (sqlEx != null && sqlEx.Number == -2)
            {
                cex = new ClientException(ClientExceptionId.SqlTimeout);
            }

            if (cex != null)
            {
                var exNode = from node in exceptionsTemplates.Root.Elements()
                             where node.Attribute("id").Value == cex.Id.ToString()
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

                if (ConfigurationMapper.Instance.LogHandledExceptions)
                    ServiceHelper.Instance.LogException(ex);
                else if (cex.InnerException != null)
                    ServiceHelper.Instance.LogException(cex.InnerException);
            }
            else if (rcex != null)
            {
                exceptionXml.Root.Add(new XElement("customMessage", rcex.Message));

                if (ConfigurationMapper.Instance.LogHandledExceptions)
                    ServiceHelper.Instance.LogException(ex);
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
                exceptionXml.Root.Element("serverVersion").Value = ServiceHelper.Instance.GetVersion();

                //if (ex.InnerException != null)
                //{
                //    exceptionXml.Root.Add(ServiceHelper.Instance.CreateInnerExceptionXml(ex.InnerException));
                //}

                int logNumber = ServiceHelper.Instance.LogException(ex);

                if (logNumber > 0)
                    exceptionXml.Root.Element("logNumber").Value = logNumber.ToString(CultureInfo.InvariantCulture);
                else
                    exceptionXml.Root.Element("logNumber").Remove();
            }

            //leave only one language
            string userLang = null;

			if (SessionManager.SessionId != null)
			{
				try
				{
					userLang = SessionManager.Language;
				}
				catch (Exception)
				{
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("EXCEPTION: (KernelServices) What is this exception?"); 
				}
			}
			if (userLang == null)
				userLang = this.GetClientLanguageVersion();

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

        /// <summary>
        /// Method invoked on every exception that wraps the exception and logs it.
        /// </summary>
        /// <param name="ex">The exception to wrap and log.</param>
        public void OnException(Exception ex)
        {
            RoboFramework.Tools.RandomLogHelper.GetLog().Error("OnException:" + ex.Message + ex.StackTrace);
            //FastTest.Fail("OnException");
			SessionManager.VolatileElements.WasExceptionThrown = true;
            throw new FaultException(this.CreateExceptionXml(ex).OuterXml());
        }

        /// <summary>
        /// Logs the exception to the log file.
        /// </summary>
        /// <param name="ex">The exception to log.</param>
        /// <returns>Exception number in the log file or 0 if there was an error writing to file.</returns>
		public int LogException(Exception ex)
		{
			int result = LogException(ex, null);

			if (ex.InnerException != null && ex.InnerException is System.Reflection.ReflectionTypeLoadException)
			{
				var typeLoadException = ex.InnerException as System.Reflection.ReflectionTypeLoadException;
				var loaderExceptions = typeLoadException.LoaderExceptions;
				foreach (var lex in loaderExceptions)
				{
					result += LogException(lex, null);
				}
			}

			return result;
		}

        public int LogException(Exception ex, XElement customLogElement)
        {
            Monitor.Enter(typeof(ServiceHelper));
            FileStream file = null;
            StreamReader reader = null;
            XmlWriter writer = null;

            try
            {
                string logFolder = ConfigurationManager.AppSettings["LogFolder"];

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

				if (customLogElement != null)
				{
					logElement.Add(customLogElement);
				}
				else
				{
					this.AppendExceptionDataToLogElement(ex, logElement);
				}

                log.Root.Add(logElement);

                file.SetLength(0); //clear the file
                writer = XmlWriter.Create(file);
                log.WriteTo(writer);

                return logNumber;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:612");
                return 0;
            }
            finally
            {
                if (writer != null)
                    writer.Close();

                if (reader != null)
                    reader.Dispose();

                Monitor.Exit(typeof(ServiceHelper));
            }
        }

		private void AppendExceptionDataToLogElement(Exception ex, XElement logElement)
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

        /// <summary>
        /// Gets the version of executing assembly and the kernel assembly.
        /// </summary>
        /// <returns><see cref="System.String"/> that represents both versions separated by slash character.</returns>
        public string GetVersion()
        {
            Assembly kernelAssembly = Assembly.GetAssembly(typeof(Kernel.Exceptions.ClientException));
            return Assembly.GetExecutingAssembly().GetName().Version.ToString() + "/" + kernelAssembly.GetName().Version.ToString();
        }

        /// <summary>
        /// Method invoked on every wrapper method exit.
        /// </summary>
        public abstract void OnExit();

        /// <summary>
        /// Logs off the current user.
        /// </summary>
        public void LogOff()
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
				SessionManager.VolatileElements.ClientCommand = "LogOff";
				SecurityManager.Instance.LogOff();
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:613");
                ServiceHelper.Instance.OnException(ex);
            }
        }

        /// <summary>
        /// Method invoked on every wrapper method entry.
        /// </summary>
        public abstract void OnEntry();

        /// <summary>
        /// Method invoked on every wrapper method entry.
        /// </summary>
        public abstract void OnEntryMock();

        /// <summary>
        /// Gets the entire log file by date.
        /// </summary>
        /// <param name="date">The date.</param>
        /// <returns>Entire log file.</returns>
        public string GetLogByDate(string date)
        {
            ServiceHelper.Instance.OnEntry();
            string retXml = null;

            try
            {
                Monitor.Enter(typeof(ServiceHelper));

                FileStream file = null;
                StreamReader reader = null;

                try
                {
                    string logFolder = ConfigurationManager.AppSettings["LogFolder"];

                    if (logFolder[logFolder.Length - 1] == '\\')
                        logFolder = logFolder.Substring(0, logFolder.Length - 1);

                    file = new FileStream(String.Format(CultureInfo.InvariantCulture, "{0}\\{1}.xml", logFolder, date), FileMode.Open);

                    reader = new StreamReader(file);
                    retXml = reader.ReadToEnd();
                }
                catch (FileNotFoundException)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:614");
                    retXml = "<?xml version=\"1.0\" encoding=\"utf-16\"?><logs/>";
                }
                finally
                {
                    if (reader != null)
                        reader.Dispose();

                    Monitor.Exit(typeof(ServiceHelper));
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:615");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }
    }
}
