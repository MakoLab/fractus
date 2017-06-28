using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;

namespace Makolab.Fractus.Kernel.Managers.Logging
{
	public class TestRecorderExceptionLogger : ExceptionLogger
	{
		private static readonly TestRecorderExceptionLogger _Instance = new TestRecorderExceptionLogger();

		public static TestRecorderExceptionLogger Instance { get { return _Instance; } }

		protected override string LogFolderName
		{
			get { return ConfigurationManager.AppSettings["LogFolder"]; }
		}

		protected override Type LockType
		{
			get { return typeof(TestRecorderExceptionLogger); }
		}

		protected override string FileNamePart
		{
			get { return "TestRecorder"; }
		}
	}
}
