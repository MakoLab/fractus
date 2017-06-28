namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Data.SqlClient;
    using System.Xml.Linq;
    using Makolab.Commons.Communication;
    using Makolab.Fractus.Kernel.Managers;

    /// <summary>
    /// Class that retrieves and saves contractor xml.
    /// </summary>
    public class ContractorRepository : Repository<DBXml> //, IDisposable
    {
        /// <summary>
        /// Contractor mapper.
        /// </summary>
        private ContractorMapper mapper;

        /// <summary>
        /// Contractor mapper from Kernel assembly.
        /// </summary>
        private Kernel.Mappers.ContractorMapper kernelContractorMapper;

        public ExecutionController ExecutionController { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorRepository"/> class.
        /// </summary>
        /// <param name="context">The unit of work.</param>
        protected ContractorRepository(IUnitOfWork context) : base(context)
        {
            if (context == null) throw new ArgumentNullException("context");

            this.mapper = context.MapperFactory.CreateMapper<ContractorMapper>(context.ConnectionManager);
            if (this.mapper == null) this.mapper = new ContractorMapper(context.ConnectionManager);

            this.mapper.Transaction = context.Transaction;

            this.kernelContractorMapper = context.MapperFactory.CreateMapper<Kernel.Mappers.ContractorMapper>(context.ConnectionManager); 

            using(IConnectionWrapper conWrapper = context.ConnectionManager.SynchronizeConnection())
            {

                if (this.kernelContractorMapper == null)
                {
                    SqlConnectionManager.Instance.SetConnection(conWrapper.Connection, context.Transaction as SqlTransaction);
                    this.kernelContractorMapper = new Kernel.Mappers.ContractorMapper();
                }
            }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ContractorRepository"/> class.
        /// </summary>
        /// <param name="context">The context.</param>
        /// <param name="executionController">The execution controller.</param>
        public ContractorRepository(IUnitOfWork context, ExecutionController executionController) : this(context)
        {
            this.ExecutionController = executionController;
        }

        /// <summary>
        /// Executes the operations based on constractor related xml.
        /// </summary>
        /// <param name="operations">The xml with operations.</param>
        public void ExecuteOperations(DBXml operations)
        {
            this.ExecutionController.ExecuteOperations(this.kernelContractorMapper.ExecuteOperations, operations);
            //if (this.ChangesetBuffer != null) this.ChangesetBuffer.AddOrReplaceData(operations.Tables);
            //else
            //{
            //    using (Context.ConnectionManager.SynchronizeConnection())
            //    {
            //        this.kernelContractorMapper.ExecuteOperations(operations.Xml);
            //    }
            //}
        }

        /// <summary>
        /// Finds the contractor snapshot.
        /// </summary>
        /// <param name="contractorId">The contractor id.</param>
        /// <returns>Contractor data in xml format.</returns>
        public DBXml FindContractorSnapshot(Guid contractorId)
        {
            return this.mapper.GetContractorSnapshot(contractorId);
        }

        /// <summary>
        /// Finds the contractor relations snapshot.
        /// </summary>
        /// <param name="contractorRelationsId">The contractor relations id.</param>
        /// <returns>Contractor relations data in xml format.</returns>
        public DBXml FindContractorRelationsSnapshot(Guid contractorRelationsId)
        {
            return this.mapper.GetContractorRelationsSnapshot(contractorRelationsId);
        }

        /// <summary>
        /// Finds the contractor group membership snapshot.
        /// </summary>
        /// <param name="contractorGroupMembershipId">The contractor group membership id.</param>
        /// <returns>Contractor group membership data in xml format.</returns>
        public DBXml FindContractorGroupMembershipSnapshot(Guid contractorGroupMembershipId)
        {
            return this.mapper.GetContractorGroupMembershipSnapshot(contractorGroupMembershipId);
        }

        /// <summary>
        /// Indexes the contractor.
        /// </summary>
        /// <param name="contractorInfo">The contractor data.</param>
        public void IndexContractor(XNode contractorInfo) 
        {
            this.ExecutionController.ExecuteCommand(() => this.mapper.UpdateContractorIndex(contractorInfo));
        }

        //#region IDisposable Members

        ///// <summary>
        ///// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        ///// </summary>
        //public void Dispose()
        //{
        //    Dispose(true);
        //    GC.SuppressFinalize(this);
        //}

        //#endregion

        ///// <summary>
        ///// Releases unmanaged and - optionally - managed resources
        ///// </summary>
        ///// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        //protected virtual void Dispose(bool disposing)
        //{
        //    if (disposing)
        //    {

        //    }
        //}
    }
}
