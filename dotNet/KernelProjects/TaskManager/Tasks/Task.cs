using System;
using System.Globalization;
using System.Threading;
using System.Xml.Linq;

namespace Makolab.Fractus.TaskManager.Tasks
{
    internal abstract class Task
    {
        protected string result;
        private object progressLock = new object();
        private bool wasError = false;
        private bool wasTerminated = false;
        public int Progress { get; set; }

        public void Start()
        {
            try
            {
                this.StartProcedure();
            }
            catch (ThreadAbortException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:709");
                this.wasTerminated = true;
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:710");
                this.wasError = true;
            }
        }

        protected abstract void StartProcedure();

        public XElement Query()
        {
            XElement retVal = XElement.Parse("<root><progress>" + this.Progress.ToString(CultureInfo.InvariantCulture) + "</progress></root>");

            if (this.wasTerminated)
                retVal.Add(new XElement("status", "terminated"));
            else if (this.wasError)
                retVal.Add(new XElement("status", "error"));
            else if (this.Progress == 100)
                retVal.Add(new XElement("status", "completed"));
            else
                retVal.Add(new XElement("status", "inProgress"));

            return retVal;
        }

        public string GetResult()
        {
            return this.result;
        }
    }
}
