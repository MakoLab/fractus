using System;
using System.Collections.Generic;
using System.Reflection;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Mappers;
using System.Data.SqlClient;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Exceptions;

namespace Makolab.Fractus.Kernel.Managers
{
    /// <summary>
    /// Class that manages journal entries.
    /// </summary>
    internal class JournalManager
    {
        /// <summary>
        /// Instance of <see cref="JournalManager"/>.
        /// </summary>
        private static JournalManager instance = new JournalManager();

        /// <summary>
        /// Gets the instance of <see cref="SecurityManager"/>.
        /// </summary>
        public static JournalManager Instance
        {
            get { return JournalManager.instance; }
        }

		/// <summary>
		/// Get Journal Action
		/// </summary>
		/// <param name="boNodeName"></param>
		/// <param name="isNew"></param>
		/// <returns></returns>
		public static JournalAction GetJournalAction(string boNodeName, bool isNew)
		{
			JournalAction action = JournalAction.Unspecified;

			switch (boNodeName)
			{
				case "COMMERCIALDOCUMENT":
				case "COMPLAINTDOCUMENT":
				case "FINANCIALDOCUMENT":
				case "FINANCIALREPORT":
				case "INVENTORYDOCUMENT":
				case "SERVICEDOCUMENT":
				case "WAREHOUSEDOCUMENT":
					if (isNew)
						action = JournalAction.Document_New;
					else
						action = JournalAction.Document_Edit;
					break;
				case "CONTRACTOR":
					if (isNew)
						action = JournalAction.Contractor_New;
					else
						action = JournalAction.Contractor_Edit;
					break;
				case "ITEM":
					if (isNew)
						action = JournalAction.Item_New;
					else
						action = JournalAction.Item_Edit;
					break;
				case "CONFIGVALUE":
				case "SLOTGROUP"://<warehouseMap><slotGroup>......</warehouseMap>
					action = JournalAction.ConfigValue_Edit;
					break;
			}

			return action;
		}

		public static XElement AddJournalTransactionAttributes(XElement jXml)
		{
			jXml.Add(new XAttribute(XmlName.LocalTransactionId, SessionManager.VolatileElements.LocalTransactionId.ToUpperString()));
			jXml.Add(new XAttribute(XmlName.DeferredTransactionId, SessionManager.VolatileElements.DeferredTransactionId.ToUpperString()));
			return jXml;
		}

		public static XElement RemoveJournalTransactionAttributes(XElement jXml)
		{
			jXml.Attribute(XmlName.DeferredTransactionId).Remove();
			jXml.Attribute(XmlName.LocalTransactionId).Remove();
			return jXml;
		}

        /// <summary>
        /// Dictionary contains mapping from action name to its Id.
        /// </summary>
        private Dictionary<JournalAction, Guid> dictActions;

        /// <summary>
        /// Initializes a new instance of the <see cref="JournalManager"/> class.
        /// </summary>
        private JournalManager()
        {
            this.LoadActions();
        }

        /// <summary>
        /// Loads journal actions from the database.
        /// </summary>
        private void LoadActions()
        {
            SqlConnectionManager.Instance.InitializeConnection();

            try
            {
                JournalMapper mapper = DependencyContainerManager.Container.Get<JournalMapper>();
                this.dictActions = mapper.GetJournalActions();
            }
            finally
            {
                 SqlConnectionManager.Instance.ReleaseConnection();
            }
        }

		/// <summary>
		/// Logs action to the journal with transaction.
		/// </summary>
		/// <param name="action">The action.</param>
		/// <param name="xmlParams">Xml parameters.</param>
		public void LogToJournalWithTransaction(JournalAction action, XDocument xmlParams)
		{
			SqlConnectionManager.Instance.BeginTransaction();

			try
			{
				this.LogToJournal(action, xmlParams);

				if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
					SqlConnectionManager.Instance.CommitTransaction();
				else
					SqlConnectionManager.Instance.RollbackTransaction();
			}
			catch (SqlException sqle)
			{
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:100");
				SqlConnectionManager.Instance.RollbackTransaction();

				if (sqle.Number == 1205)
					throw new ClientException(ClientExceptionId.Deadlock, sqle);
				else if (sqle.Number == 17142 || sqle.Number == 10054)
					throw new ClientException(ClientExceptionId.SqlConnectionError);
				throw;
			}
			catch (Exception)
			{
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:101");
				SqlConnectionManager.Instance.RollbackTransaction();
				throw;
			}
		}

		/// <summary>
		/// Logs action to the journal.
		/// </summary>
		/// <param name="action">The action.</param>
		/// <param name="xmlParams">Xml parameters.</param>
		public void LogToJournal(JournalAction action, XDocument xmlParams)
		{
			this.LogToJournal(action, null, null, null, xmlParams);
		}

        /// <summary>
        /// Logs action to the journal.
        /// </summary>
        /// <param name="action">The action.</param>
        /// <param name="firstObjectId">First object id parameter.</param>
        /// <param name="secondObjectId">Second object id parameter.</param>
        /// <param name="thirdObjectId">Third object id parameter.</param>
        /// <param name="xmlParams">Xml parameters.</param>
        public void LogToJournal(JournalAction action, Guid? firstObjectId, Guid? secondObjectId, Guid? thirdObjectId, XDocument xmlParams)
        {
            this.LogToJournal(SessionManager.User.UserId, action, firstObjectId, secondObjectId, thirdObjectId, xmlParams);
        }

        /// <summary>
        /// Logs action to the journal.
        /// </summary>
        /// <param name="userId">Id of the user that caused the action.</param>
        /// <param name="action">The action.</param>
        /// <param name="firstObjectId">First object id parameter.</param>
        /// <param name="secondObjectId">Second object id parameter.</param>
        /// <param name="thirdObjectId">Third object id parameter.</param>
        /// <param name="xmlParams">Xml parameters.</param>
        public void LogToJournal(Guid? userId, JournalAction action, Guid? firstObjectId, Guid? secondObjectId, Guid? thirdObjectId, XDocument xmlParams)
        {
            JournalMapper mapper = DependencyContainerManager.Container.Get<JournalMapper>();

			if (!dictActions.ContainsKey(action))
			{
				throw new InvalidOperationException(String.Format("Missing journal action: {0}", action.ToString()));
			}

            mapper.LogToJournal(userId, this.dictActions[action], firstObjectId, secondObjectId, 
                thirdObjectId, xmlParams, Assembly.GetExecutingAssembly().GetName().Version.ToString());
        }
    }
}
