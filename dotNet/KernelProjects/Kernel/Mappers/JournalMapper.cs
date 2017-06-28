using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Linq;
using System.Xml;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Commons.Collections;

namespace Makolab.Fractus.Kernel.Mappers
{
    /// <summary>
    /// Mapper class that contains method that are used by the Journal.
    /// </summary>
    public class JournalMapper : Mapper
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="JournalMapper"/> class.
        /// </summary>
        public JournalMapper()
        {
        }

        /// <summary>
        /// Gets the journal actions from the database.
        /// </summary>
        /// <returns>Dictionary containing journal actions as a key and id of the action as a value.</returns>
        public Dictionary<JournalAction, Guid> GetJournalActions()
        {
            XDocument xml = this.ExecuteStoredProcedure(StoredProcedure.journal_p_getJournalActions);
            Dictionary<JournalAction, Guid>  dictActions = new Dictionary<JournalAction, Guid>();

            string[] journalActions = Enum.GetNames(typeof(JournalAction));

            foreach (XElement entry in xml.Root.Elements())
            {
                Guid id = new Guid(entry.Element("id").Value);
                JournalAction action = JournalAction.Unspecified;

                if (journalActions.Contains(entry.Element("name").Value))
                    action = (JournalAction)Enum.Parse(typeof(JournalAction), entry.Element("name").Value);

                if (action != JournalAction.Unspecified)
                    dictActions.Add(action, id);
            }

            return dictActions;
        }

        /// <summary>
        /// Creates the SQL GUID (UniqueIdentifier type) parameter.
        /// </summary>
        /// <param name="name">Parameter name.</param>
        /// <param name="value">Parameter value.</param>
        /// <returns>Created <see cref="SqlParameter"/>. Contains DBNull.Value if input value is null.</returns>
        private SqlParameter CreateSqlGuidParameter(string name, Guid? value)
        {
            SqlParameter param = new SqlParameter(name, SqlDbType.UniqueIdentifier);

            if (value != null)
                param.Value = value.Value;
            else
                param.Value = DBNull.Value;

            return param;
        }

        /// <summary>
        /// Creates the SQL XML parameter.
        /// </summary>
        /// <param name="name">Parameter name.</param>
        /// <param name="value">Parameter value.</param>
        /// <returns>Created <see cref="SqlParameter"/>. Contains DBNull.Value if input value is null.</returns>
        private SqlParameter CreateSqlXmlParameter(string name, XDocument value)
        {
            SqlParameter param = new SqlParameter(name, SqlDbType.Xml);

            if (value != null)
            {
                XmlReader reader = value.CreateReader();
                SqlXml xml = new SqlXml(reader);
                reader.Close();
                param.SqlValue = xml;
            }
            else
                param.Value = DBNull.Value;

            return param;
        }

		/// <summary>
		/// Logs action to the journal.
		/// </summary>
		/// <param name="userId">Id of the user that caused the action.</param>
		/// <param name="journalActionId">Id of the journal action.</param>
		/// <param name="firstObjectId">First object id parameter.</param>
		/// <param name="secondObjectId">Second object id parameter.</param>
		/// <param name="thirdObjectId">Third object id parameter.</param>
		/// <param name="xmlParams">Xml parameters.</param>
		/// <param name="kernelVersion">The kernel version.</param>
		public virtual void LogToJournal(Guid? userId, Guid journalActionId, Guid? firstObjectId, Guid? secondObjectId, Guid? thirdObjectId, XDocument xmlParams, string kernelVersion)
		{
			SqlCommand cmd = SqlConnectionManager.Instance.Command;
			cmd.CommandText = StoredProcedure.journal_p_insertJournalEntry.ToProcedureName();
			cmd.Parameters.Clear();

			SqlParameter param = new SqlParameter("@journalActionId", SqlDbType.UniqueIdentifier);
			param.Value = journalActionId;
			cmd.Parameters.Add(param);

			cmd.Parameters.Add(this.CreateSqlGuidParameter("@applicationUserId", userId));
			cmd.Parameters.Add(this.CreateSqlGuidParameter("@firstObjectId", firstObjectId));
			cmd.Parameters.Add(this.CreateSqlGuidParameter("@secondObjectId", secondObjectId));
			cmd.Parameters.Add(this.CreateSqlGuidParameter("@thirdObjectId", thirdObjectId));
			cmd.Parameters.Add(this.CreateSqlXmlParameter("@xmlParams", xmlParams));

			param = new SqlParameter("@kernelVersion", SqlDbType.VarChar);

			param.Value = kernelVersion;

			cmd.Parameters.Add(param);

			cmd.ExecuteNonQuery();
		}
		
		/// <summary>
		/// Logs test step.
		/// </summary>
		/// <param name="commandName"></param>
		/// <param name="xmlParam"></param>
        //public virtual void LogTestStep(string commandName, XDocument xmlParam, bool isValid)
        //{
        //    SqlCommand cmd = SqlConnectionManager.TestDbInstance.Command;
        //    cmd.CommandText = StoredProcedure.dbo_p_insertTestStep.ToProcedureName();

        //    var dateElements = xmlParam.Descendants().Where(element => element.Name.LocalName.ToLowerInvariant().Contains("date"));
        //    foreach (var dElement in dateElements)
        //    {
        //        dElement.Value = "{$currentdate}";
        //    }

        //    cmd.Parameters.Clear();

        //    cmd.Parameters.Add("commandName", SqlDbType.VarChar).Value = commandName;
        //    cmd.Parameters.Add(this.CreateSqlXmlParameter("xmlParam", xmlParam));
        //    cmd.Parameters.Add("isValid", SqlDbType.Bit).Value = isValid;

        //    cmd.ExecuteNonQuery();
        //}

        /// <summary>
        /// Checks whether <see cref="IBusinessObject"/> version in database hasn't changed against current version.
        /// </summary>
        /// <param name="obj">The <see cref="IBusinessObject"/> containing its version to check.</param>
        public override void CheckBusinessObjectVersion(IBusinessObject obj)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Creates a <see cref="BusinessObject"/> of a selected type.
        /// </summary>
        /// <param name="type">The type of <see cref="IBusinessObject"/> to create.</param>
        /// <param name="requestXml">Client requestXml containing initial parameters for the object.</param>
        /// <returns>A new <see cref="IBusinessObject"/>.</returns>
        public override IBusinessObject CreateNewBusinessObject(BusinessObjectType type, XDocument requestXml)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Loads the <see cref="BusinessObject"/> with a specified Id.
        /// </summary>
        /// <param name="type">Type of <see cref="BusinessObject"/> to load.</param>
        /// <param name="id"><see cref="IBusinessObject"/>'s id indicating which <see cref="BusinessObject"/> to load.</param>
        /// <returns>
        /// Loaded <see cref="IBusinessObject"/> object.
        /// </returns>
        public override IBusinessObject LoadBusinessObject(BusinessObjectType type, Guid id)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Creates communication xml for the specified <see cref="IBusinessObject"/> and his children.
        /// </summary>
        /// <param name="obj">Main <see cref="IBusinessObject"/>.</param>
        public override void CreateCommunicationXml(IBusinessObject obj)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Converts Xml in database format to <see cref="BusinessObject"/>'s xml format.
        /// </summary>
        /// <param name="xml">Xml to convert.</param>
        /// <param name="id">Id of the main <see cref="BusinessObject"/>.</param>
        /// <returns>Converted xml.</returns>
        public override XDocument ConvertDBToBoXmlFormat(XDocument xml, Guid id)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Updates <see cref="IBusinessObject"/> dictionary index in the database.
        /// </summary>
        /// <param name="obj"><see cref="IBusinessObject"/> for which to update the index.</param>
        public override void UpdateDictionaryIndex(IBusinessObject obj)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Creates communication xml for objects that are in the xml operations list.
        /// </summary>
        /// <param name="operations"></param>
        public override void CreateCommunicationXml(XDocument operations)
        {
            throw new NotImplementedException();
        }

		public override BidiDictionary<BusinessObjectType, Type> SupportedBusinessObjectsTypes
		{
			get { throw new NotImplementedException(); }
		}
	}
}
