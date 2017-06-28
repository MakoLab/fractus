using System;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.TaskManager.Tasks
{
    internal class StoredProcedureTask : Task
    {
        private XElement param;
        private string storedProcedureName;
        private string storedProcedureParam;
        private bool hasResult = true;
		private int? sqlCommandTimeout;

        public StoredProcedureTask(XElement param)
        {
            this.param = param;
            this.storedProcedureName = param.Element("procedureName").Value;
            this.storedProcedureParam = param.Element("parameterXml").FirstNode.ToString(SaveOptions.DisableFormatting);
            
            if (param.Element("hasResult") != null && param.Element("hasResult").Value.ToUpperInvariant() == "FALSE")
                this.hasResult = false;

			if (param.Element("timeout") != null)
			{
				this.sqlCommandTimeout = Convert.ToInt32(param.Element("timeout"));
			}

        }

        protected override void StartProcedure()
        {
            SqlConnectionManager.Instance.InitializeConnection();

            try
            {
                ListMapper mapper = new ListMapper();
                this.result = mapper.ExecuteCustomProcedure(this.storedProcedureName, this.hasResult, XDocument.Parse(this.storedProcedureParam), true, this.sqlCommandTimeout).ToString(SaveOptions.DisableFormatting);
                this.Progress = 100;
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:708");
                XElement exceptionXml = Utils.CreateInnerExceptionXml(ex, null, false);
                exceptionXml.Name = "exception";
                this.result = exceptionXml.ToString(SaveOptions.DisableFormatting);
                throw;
            }
            finally
            {
                SqlConnectionManager.Instance.ReleaseConnection();
            }
        }
    }
}
