using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Xml.Linq;
using Makolab.Commons.Communication;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Communication.DBLayer
{
    public class CustomRepository : Repository<DBXml>
    {
        private CustomMapper mapper;
        public ExecutionController ExecutionController { get; set; }

         protected CustomRepository(IUnitOfWork context) : base(context)
        { 
            if (context == null) throw new ArgumentNullException("context");

            this.mapper = context.MapperFactory.CreateMapper<CustomMapper>(context.ConnectionManager);
            if (this.mapper == null) this.mapper = new CustomMapper(context.ConnectionManager);

            this.mapper.Transaction = context.Transaction;
            //using (IConnectionWrapper conWrapper = context.ConnectionManager.SynchronizeConnection())
            //{

            //    if (this.kernelContractorMapper == null)
            //    {
            //        SqlConnectionManager.Instance.SetConnection(conWrapper.Connection, context.Transaction as SqlTransaction);
            //        this.kernelContractorMapper = new Kernel.Mappers.ContractorMapper();
            //    }
            //}
        }
       public CustomRepository(IUnitOfWork context, ExecutionController executionController) : this(context)
        {
            this.ExecutionController = executionController;
        }

       public void ExecuteOperations(DBXml operations)
       {
           this.mapper.ExecuteCustomPackage(operations);
           
       }
    }
}
