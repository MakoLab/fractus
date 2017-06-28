using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;
using System.IO;
using System.Threading;
using System.Xml.Linq;
using Makolab.Fractus.Commons;

namespace Makolab.Fractus.Kernel.Managers.Logging
{
	public abstract class LoggerBase<T>
	{
		private DateTime CurrentDateTime;
		private int LogNumber;
		private string _LogFolder;

		private string FileNameDatePart
		{
			get
			{
				return String.Format(CultureInfo.InvariantCulture, "{0:yyyy-MM-dd}", DateTime.Now);
			}
		}

		private string CurrentLogFile
		{
			get
			{
				return String.Format(CultureInfo.InvariantCulture, "{0}\\{1} {2}.xml", LogFolder, FileNamePart, FileNameDatePart);
			}
		}

		protected string LogFolder
		{
			get 
			{
				if (_LogFolder == null)
				{
					_LogFolder = LogFolderName;
					if (!Path.IsPathRooted(_LogFolder))
						_LogFolder = Path.Combine(AppDomain.CurrentDomain.SetupInformation.ApplicationBase, _LogFolder);

					if (_LogFolder[_LogFolder.Length - 1] == '\\')
						_LogFolder = _LogFolder.Substring(0, _LogFolder.Length - 1);
				}
				return _LogFolder; 
			}
		}

		abstract protected string LogFolderName { get; }

		abstract protected Type LockType { get; }

		abstract protected string FileNamePart { get; }

		private void ResetVolatileData()
		{
			CurrentDateTime = DateTime.Now;
			LogNumber = 1;
		}

		private XDocument FileToXDocument(FileStream file)
		{
			XDocument log = null;
			using (StreamReader reader = new StreamReader(file))
			{
				if (file.Length != 0) //log already exists
				{
					log = XDocument.Parse(reader.ReadToEnd());
					LogNumber = Convert.ToInt32(((XElement)log.Root.LastNode).Attribute("number").Value, CultureInfo.InvariantCulture);
					LogNumber++;
				}
				else //create new log
				{
					log = XDocument.Parse("<logs/>");
				}
			}
			file.Close();
			return log;
		}

		public int Log(T item)
		{
			Monitor.Enter(LockType);

			try
			{
				ResetVolatileData();
				XDocument log = FileToXDocument(new FileStream(CurrentLogFile, FileMode.OpenOrCreate));

				XElement logElement = new XElement("log");
				logElement.Add(new XAttribute("number", LogNumber));
				logElement.Add(new XElement("dateTime", CurrentDateTime.Round(DateTimeAccuracy.Millisecond).ToIsoString()));

				AddItemInfoToLogElement(logElement, item);

				log.Root.Add(logElement);
				log.Save(CurrentLogFile);

				return LogNumber;
			}
			catch (Exception)
			{
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:102");
				return 0;
			}
			finally
			{
				Monitor.Exit(LockType);
			}
		}

		abstract protected void AddItemInfoToLogElement(XElement logElement, T item);
	}
}
