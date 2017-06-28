using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using System.IO;
using System.Xml.Linq;
using System.Data.SqlClient;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Communication.Scripts
{ 
    public class CustomScript : ExecutingScript
    {
        private CustomRepository repository;

        public CustomScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
        {
            this.ExecutionController = controller;
            this.repository = new CustomRepository(unitOfWork, controller);
        }

        public override bool ExecutePackage(ICommunicationPackage communicationPackage)
        {
            SessionManager.VolatileElements.DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId;
            SessionManager.VolatileElements.LocalTransactionId = this.LocalTransactionId;
            try
            {
                XDocument commPkg = XDocument.Parse(communicationPackage.XmlData.Content);
                this.repository.ExecuteOperations(new DBXml(commPkg));

                return true;
            }
            catch (SqlException e)
            {
                this.Log.Error("CustomScript:ExecutePackage " + e.ToString());
                return false;
            }
        }
    }
}
