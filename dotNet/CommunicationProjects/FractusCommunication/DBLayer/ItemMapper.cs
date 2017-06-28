using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using System.Data.SqlClient;
using Makolab.Fractus.Commons;
using System.Data;
using Makolab.Commons.Communication;
using Makolab.Commons.Communication.DBLayer;

namespace Makolab.Fractus.Communication.DBLayer
{
    /// <summary>
    /// Class that persists item xml representation.
    /// </summary>
    public class ItemMapper : IMapper
    {
        /// <summary>
        /// Helper object.
        /// </summary>
        private MapperHelper helper;

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemMapper"/> class.
        /// </summary>
        public ItemMapper() { }

        /// <summary>
        /// Initializes a new instance of the <see cref="ItemMapper"/> class.
        /// </summary>
        /// <param name="databaseConnectorManager">The DatabaseConnector manager.</param>
        public ItemMapper(IDatabaseConnectionManager databaseConnectorManager)
        {
            if (databaseConnectorManager == null) throw new ArgumentNullException("databaseConnectorManager");

            this.Database = databaseConnectorManager;

            this.helper = new MapperHelper(this.Database, this);
        }

        /// <summary>
        /// Gets or sets the DatabaseConnector manager.
        /// </summary>
        /// <value>The DatabaseConnector manager.</value>
        public IDatabaseConnectionManager Database { get; private set; }

        #region IMapper Members

        /// <summary>
        /// Gets or sets the database transaction.
        /// </summary>
        /// <value>The database transaction.</value>
        public System.Data.IDbTransaction Transaction { get; set; }

        #endregion

        /// <summary>
        /// Gets the xml representing the item.
        /// </summary>
        /// <param name="id">The item id.</param>
        /// <returns>Item xml.</returns>
        public virtual DBXml GetItemSnapshot(Guid id)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getItemPackage.ToProcedureName(),
                                                       new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                       id);

            XDocument itemSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                itemSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(itemSnapshot);
        }


        /// <summary>
        /// Gets the xml representation of item's relation.
        /// </summary>
        /// <param name="itemRelationsId">The item's relation id.</param>
        /// <returns>Item's relation xml.</returns>
        public DBXml GetItemRelationsSnapshot(Guid itemRelationsId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getItemRelationPackage.ToProcedureName(),
                                                      new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                      itemRelationsId);

            XDocument itemRelationSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                itemRelationSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(itemRelationSnapshot);
        }

        /// <summary>
        /// Gets the xml representation of item's unit relation.
        /// </summary>
        /// <param name="itemUnitRelationId">The item's unit relation id.</param>
        /// <returns>Item's unit relation xml.</returns>
        public DBXml GetItemUnitRelationsSnapshot(Guid itemUnitRelationId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getItemUnitRelationPackage.ToProcedureName(),
                                                      new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                      itemUnitRelationId);

            XDocument itemUnitRelationSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                itemUnitRelationSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(itemUnitRelationSnapshot);
        }

        /// <summary>
        /// Gets the item group membership snapshot of specified id.
        /// </summary>
        /// <param name="itemGroupMembershipId">The item group membership id.</param>
        /// <returns>Item's group membership xml.</returns>
        public DBXml GetItemGroupMembershipSnapshot(Guid itemGroupMembershipId)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.communication_p_getItemGroupMembershipPackage.ToProcedureName(),
                                                      new SqlParameter("@id", SqlDbType.UniqueIdentifier),
                                                      itemGroupMembershipId);

            XDocument itemGroupMembershipSnapshot = null;
            using (this.Database.SynchronizeConnection())
            {
                itemGroupMembershipSnapshot = this.helper.GetXmlDocument(cmd.ExecuteXmlReader());
            }

            return new DBXml(itemGroupMembershipSnapshot);
        }

        /// <summary>
        /// Updates the index of the item.
        /// </summary>
        /// <param name="itemInfo">The item data.</param>
        public void UpdateItemIndex(XDocument itemInfo)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.item_p_updateItemDictionary.ToProcedureName(),
                                                        new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                        this.helper.CreateSqlXml(itemInfo));
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Updates the index of the item.
        /// </summary>
        /// <param name="itemInfo">The item data.</param>
        public void UpdateOrInsertPriceRule(XDocument priceRule)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.item_p_createPriceRule.ToProcedureName(),
                                                        new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                        this.helper.CreateSqlXml(priceRule));
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }

        public void UpdatePriceRuleList(XDocument ruleList)
        {
            SqlCommand cmd = this.helper.CreateCommand(StoredProcedure.item_p_savePriceRuleList.ToProcedureName(),
                                                        new SqlParameter("@xmlVar", SqlDbType.Xml),
                                                        this.helper.CreateSqlXml(ruleList));
            using (this.Database.SynchronizeConnection())
            {
                cmd.ExecuteNonQuery();
            }
        }
    }
}
