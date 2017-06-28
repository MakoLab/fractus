using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using Makolab.Commons.Communication;
using System.Xml.Linq;

namespace Makolab.Fractus.Communication.DBLayer
{
    /// <summary>
    /// Class that retrieves and saves item xml.
    /// </summary>
    public class ItemRepository : Repository<DBXml>, IDisposable
    {
        /// <summary>
        /// Item mapper.
        /// </summary>
        private ItemMapper mapper;

        /// <summary>
        /// Item mapper from Kernel assembly.
        /// </summary>
        private Kernel.Mappers.ItemMapper kernelItemMapper;

        public ExecutionController ExecutionController { get; set; }

        #region Constructor
        /// <summary>
        /// Initializes a new instance of the <see cref="ItemRepository"/> class.
        /// </summary>
        /// <param name="context">The unit of work.</param>
        protected ItemRepository(IUnitOfWork context)
            : base(context)
        {
            if (context == null) throw new ArgumentNullException("context");

            this.mapper = context.MapperFactory.CreateMapper<ItemMapper>(context.ConnectionManager);
            if (this.mapper == null) this.mapper = new ItemMapper(context.ConnectionManager);

            this.mapper.Transaction = context.Transaction;

            this.kernelItemMapper = context.MapperFactory.CreateMapper<Kernel.Mappers.ItemMapper>(context.ConnectionManager);
            using (IConnectionWrapper conWrapper = context.ConnectionManager.SynchronizeConnection())
            {
                if (this.kernelItemMapper == null)
                {
                    Makolab.Fractus.Kernel.Managers.SqlConnectionManager.Instance.SetConnection(conWrapper.Connection, context.Transaction as SqlTransaction);
                    this.kernelItemMapper = new Kernel.Mappers.ItemMapper();
                }
            }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemRepository"/> class.
        /// </summary>
        /// <param name="context">The context.</param>
        /// <param name="executionController">The execution controller.</param>
        public ItemRepository(IUnitOfWork context, ExecutionController executionController) : this(context)
        {
            this.ExecutionController = executionController;
        }
        #endregion

        #region IDisposable Members

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {

            }
        }

        /// <summary>
        /// Executes the operations based on item related xml.
        /// </summary>
        /// <param name="operations">The xml with operations.</param>
        public void ExecuteOperations(DBXml operations)
        {
            this.ExecutionController.ExecuteOperations(this.kernelItemMapper.ExecuteOperations, operations);
            //if (this.ChangesetBuffer != null) this.ChangesetBuffer.AddOrReplaceData(operations.Tables);
            //else
            //{
            //    using (Context.ConnectionManager.SynchronizeConnection())
            //    {
            //        this.kernelItemMapper.ExecuteOperations(operations.Xml);
            //    }
            //}
        }

        /// <summary>
        /// Finds the item snapshot.
        /// </summary>
        /// <param name="itemId">The item id.</param>
        /// <returns>Item data in xml format.</returns>
        public DBXml FindItemSnapshot(Guid itemId)
        {
            return this.mapper.GetItemSnapshot(itemId);
        }

        /// <summary>
        /// Finds the item relations snapshot.
        /// </summary>
        /// <param name="itemRelationsId">The item relations id.</param>
        /// <returns>Item relations data in xml format.</returns>
        public DBXml FindItemRelationsSnapshot(Guid itemRelationsId)
        {
            return this.mapper.GetItemRelationsSnapshot(itemRelationsId);
        }

        /// <summary>
        /// Finds the item unit relations snapshot.
        /// </summary>
        /// <param name="itemUnitRelationsId">The item unit relations id.</param>
        /// <returns>Item unit relations data in xml format.</returns>
        public DBXml FindItemUnitRelationsSnapshot(Guid itemUnitRelationsId)
        {
            return this.mapper.GetItemUnitRelationsSnapshot(itemUnitRelationsId);
        }

        /// <summary>
        /// Finds the item group membership snapshot.
        /// </summary>
        /// <param name="contractorGroupMembershipId">The item group membership id.</param>
        /// <returns>Item group membership data in xml format.</returns>
        public DBXml FindContractorGroupMembershipSnapshot(Guid contractorGroupMembershipId)
        {
            return this.mapper.GetItemGroupMembershipSnapshot(contractorGroupMembershipId);
        }

        /// <summary>
        /// Indexes the item.
        /// </summary>
        /// <param name="itemInfo">The item data.</param>
        public void IndexItem(XDocument itemInfo)
        {
            this.ExecutionController.ExecuteCommand(() => this.mapper.UpdateItemIndex(itemInfo));   
        }

        public void SetPriceRule(XDocument priceRule)
        {
            this.ExecutionController.ExecuteCommand(() => this.mapper.UpdateOrInsertPriceRule(priceRule));
        }

        public void SetPriceRuleList(XDocument ruleList)
        {
            this.ExecutionController.ExecuteCommand(() => this.mapper.UpdatePriceRuleList(ruleList));
        }
    }
}
