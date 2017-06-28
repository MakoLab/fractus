using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.Coordinators;
using System.Xml.Linq;
using Makolab.Commons.Communication;
using Makolab.Fractus.Commons;
using System.Data.SqlClient;
using Makolab.Commons.Communication.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using System.Globalization;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process the Dictionary communication package.
    /// </summary>
    public class DictionarySnapshotScript : SnapshotScript
    {
        private DocumentRepository repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="DictionarySnapshot"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public DictionarySnapshotScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
        {
            this.repository = new DocumentRepository(unitOfWork, controller);
            this.repository.ExecutionController = controller;
        }

        /// <summary>
        /// Executes the communication package.
        /// </summary>
        /// <param name="communicationPackage">The communication package to execute.</param>
        /// <returns>
        /// 	<c>true</c> if execution succeeded; otherwise, <c>false</c>
        /// </returns>
        public override bool ExecutePackage(Makolab.Commons.Communication.ICommunicationPackage communicationPackage)
        {
            XDocument commXml = XDocument.Parse(communicationPackage.XmlData.Content);
            try
            {
                string dictionaryName = commXml.Root.Elements().First().Name.LocalName;
                string cappitalizedDictionaryName = dictionaryName.Capitalize();

                this.mainObjectTag = dictionaryName;

                return base.ExecutePackage(communicationPackage);

            }
            catch (SqlException e)
            {
                if (e.Number == 50012) // Conflict detection
                {
                    throw new ConflictException("Conflict detected while changing dictionary");
                }
                else
                {
                    this.Log.Error("SnapshotScript:ExecutePackage " + e.ToString());
                    return false;
                }
            }
        }

        private string mainObjectTag;
        public override string MainObjectTag
        {
            get { return this.mainObjectTag; }
        }

        public override void ExecuteChangeset(DBXml changeset)
        {
            this.repository.ExecuteOperations(changeset);
        }

        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            var currentSnapshot = GetDictionary(this.MainObjectTag);
            foreach (var entry in currentSnapshot.Root.Element(this.MainObjectTag).Elements(this.MainObjectTag)) entry.Name = "entry";
            return GetSnapshotOrNull(new DBXml(currentSnapshot));
        }

        public override bool ValidateVersion(DBXml commSnapshot, DBXml dbSnapshot)
        {
            return true;
        }

        /// <summary>
        /// Gets the specified dictionary.
        /// </summary>
        /// <param name="dictionaryType">Type of the dictionary.</param>
        /// <returns>The specified dictionary.</returns>
        private XDocument GetDictionary(string dictionaryType)
        {
            if (dictionaryType.Equals("branch", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetBranches();
            else if (dictionaryType.Equals("company", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetCompanies();
            else if (dictionaryType.Equals("contractorField", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetContractorFields();
            else if (dictionaryType.Equals("contractorRelationType", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetContractorRelationTypes();
            else if (dictionaryType.Equals("containerType", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetContainerTypes();
            else if (dictionaryType.Equals("country", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetCountries();
            else if (dictionaryType.Equals("currency", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetCurrencies();
            else if (dictionaryType.Equals("documentField", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetDocumentFields();
            else if (dictionaryType.Equals("documentFieldRelation", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetDocumentFieldRelations();
            else if (dictionaryType.Equals("documentNumberComponent", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetDocumentNumberComponents();
            else if (dictionaryType.Equals("documentType", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetDocumentTypes();
            else if (dictionaryType.Equals("financialRegister", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetFinancialRegisters();
            else if (dictionaryType.Equals("issuePlace", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetIssuePlaces();
            else if (dictionaryType.Equals("itemField", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetItemFields();
            else if (dictionaryType.Equals("itemRelationAttrValueType", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetItemRelationAttrValueTypes();
            else if (dictionaryType.Equals("itemRelationType", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetItemRelationTypes();
            else if (dictionaryType.Equals("itemType", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetItemTypes();
            else if (dictionaryType.Equals("jobPosition", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetJobPositions();
            else if (dictionaryType.Equals("numberSetting", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetNumberSettings();
            else if (dictionaryType.Equals("paymentMethod", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetPaymentMethods();
            else if (dictionaryType.Equals("shiftField", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetShiftFields();
            else if (dictionaryType.Equals("unit", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetUnits();
            else if (dictionaryType.Equals("unitType", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetUnitTypes();
            else if (dictionaryType.Equals("vatRate", StringComparison.OrdinalIgnoreCase)) return DictionaryMapper.Instance.GetVatRates();
            else throw new Exception("Unknown dictionary: " + dictionaryType);
        }
    }
}
