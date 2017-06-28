using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators
{
    /// <summary>
    /// Class that coordinates business logic of dictionares BusinessObjects.
    /// </summary>
    internal class DictionaryCoordinator : TypedCoordinator<DictionaryMapper>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="DictionaryCoordinator"/> class.
        /// </summary>
        public DictionaryCoordinator() : this(true, true)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="DictionaryCoordinator"/> class.
        /// </summary>
        /// <param name="aquireDictionaryLock">If set to <c>true</c> coordinator will enter dictionary read lock.</param>
        /// <param name="canCommitTransaction">If set to <c>true</c> coordinator will be able to commit transaction.</param>
        public DictionaryCoordinator(bool aquireDictionaryLock, bool canCommitTransaction)
            : base(aquireDictionaryLock, canCommitTransaction)
        {
            try
            {
                SqlConnectionManager.Instance.InitializeConnection();
                this.Mapper = DependencyContainerManager.Container.Get<DictionaryMapper>();
            }
            catch (Exception)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:22");
                if (this.IsReadLockAquired)
                {
                    DictionaryMapper.Instance.DictionaryLock.ExitReadLock();
                    this.IsReadLockAquired = false;
                }

                throw;
            }
        }

        /// <summary>
        /// Gets the dictionaries version.
        /// </summary>
        /// <returns>The sum of all dictionaries versions.</returns>
        public int GetDictionariesVersion()
        {
            DictionaryMapper.Instance.CheckForChanges();
            return DictionaryMapper.Instance.DictionariesVersion;
        }

        /// <summary>
        /// Loads the selected dictionary.
        /// </summary>
        /// <param name="dictionary">Name of the dictionary to load.</param>
        /// <returns>Selected dictionary.</returns>
        public XDocument LoadDictionary(BusinessObjectType dictionary)
        {
            DictionaryMapper.Instance.CheckForChanges();

            XDocument retXml = null;

            switch (dictionary)
            {
                case BusinessObjectType.ContractorField:
                    retXml = DictionaryMapper.Instance.GetContractorFields();
                    break;
                case BusinessObjectType.ContractorRelationType:
                    retXml = DictionaryMapper.Instance.GetContractorRelationTypes();
                    break;
                case BusinessObjectType.Country:
                    retXml = DictionaryMapper.Instance.GetCountries();
                    break;
                case BusinessObjectType.Currency:
                    retXml = DictionaryMapper.Instance.GetCurrencies();
                    break;
                case BusinessObjectType.DocumentField:
                    retXml = DictionaryMapper.Instance.GetDocumentFields();
                    break;
                case BusinessObjectType.DocumentFieldRelation:
                    retXml = DictionaryMapper.Instance.GetDocumentFieldRelations();
                    break;
                case BusinessObjectType.DocumentNumberComponent:
                    retXml = DictionaryMapper.Instance.GetDocumentNumberComponents();
                    break;
                case BusinessObjectType.DocumentType:
                    retXml = DictionaryMapper.Instance.GetDocumentTypes();
                    break;
                case BusinessObjectType.IssuePlace:
                    retXml = DictionaryMapper.Instance.GetIssuePlaces();
                    break;
                case BusinessObjectType.ItemField:
                    retXml = DictionaryMapper.Instance.GetItemFields();
                    break;
                case BusinessObjectType.ItemRelationAttrValueType:
                    retXml = DictionaryMapper.Instance.GetItemRelationAttrValueTypes();
                    break;
                case BusinessObjectType.ItemRelationType:
                    retXml = DictionaryMapper.Instance.GetItemRelationTypes();
                    break;
                case BusinessObjectType.ItemType:
                    retXml = DictionaryMapper.Instance.GetItemTypes();
                    break;
                case BusinessObjectType.JobPosition:
                    retXml = DictionaryMapper.Instance.GetJobPositions();
                    break;
                case BusinessObjectType.NumberSetting:
                    retXml = DictionaryMapper.Instance.GetNumberSettings();
                    break;
                case BusinessObjectType.PaymentMethod:
                    retXml = DictionaryMapper.Instance.GetPaymentMethods();
                    break;
                case BusinessObjectType.Unit:
                    retXml = DictionaryMapper.Instance.GetUnits();
                    break;
                case BusinessObjectType.UnitType:
                    retXml = DictionaryMapper.Instance.GetUnitTypes();
                    break;
                case BusinessObjectType.VatRate:
                    retXml = DictionaryMapper.Instance.GetVatRates();
                    break;
				case BusinessObjectType.Branch:
					retXml = DictionaryMapper.Instance.GetBranches();
					break;
            }

            return retXml;
        }

        /// <summary>
        /// Saves the dictionary to the database. Supports massive modifications.
        /// </summary>
        /// <param name="requestXml">Client request xml containing multiple dictionary entries.</param>
        /// <returns>Xml containing operation result.</returns>
        public XDocument SaveDictionary(XDocument requestXml)
        {
            SessionManager.VolatileElements.ClientRequest = requestXml;
            XDocument modifiedXml = requestXml;

            BusinessObjectType boType = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), ((XElement)modifiedXml.Root.FirstNode).Name.LocalName, true);

            if (boType == BusinessObjectType.ContractorField)
            {
                MassiveBusinessObjectCollection<ContractorField> modifiedCollection = new MassiveBusinessObjectCollection<ContractorField>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetContractorFields();
                MassiveBusinessObjectCollection<ContractorField> originalCollection = new MassiveBusinessObjectCollection<ContractorField>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<ContractorField>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.ContractorRelationType)
            {
                MassiveBusinessObjectCollection<ContractorRelationType> modifiedCollection = new MassiveBusinessObjectCollection<ContractorRelationType>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetContractorRelationTypes();
                MassiveBusinessObjectCollection<ContractorRelationType> originalCollection = new MassiveBusinessObjectCollection<ContractorRelationType>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<ContractorRelationType>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.Country)
            {
                MassiveBusinessObjectCollection<Country> modifiedCollection = new MassiveBusinessObjectCollection<Country>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetCountries();
                MassiveBusinessObjectCollection<Country> originalCollection = new MassiveBusinessObjectCollection<Country>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<Country>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.Currency)
            {
                MassiveBusinessObjectCollection<Currency> modifiedCollection = new MassiveBusinessObjectCollection<Currency>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetCurrencies();
                MassiveBusinessObjectCollection<Currency> originalCollection = new MassiveBusinessObjectCollection<Currency>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<Currency>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.DocumentField)
            {
                MassiveBusinessObjectCollection<DocumentField> modifiedCollection = new MassiveBusinessObjectCollection<DocumentField>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetDocumentFields();
                MassiveBusinessObjectCollection<DocumentField> originalCollection = new MassiveBusinessObjectCollection<DocumentField>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<DocumentField>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.DocumentFieldRelation)
            {
                MassiveBusinessObjectCollection<DocumentFieldRelation> modifiedCollection = new MassiveBusinessObjectCollection<DocumentFieldRelation>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetDocumentFieldRelations();
                MassiveBusinessObjectCollection<DocumentFieldRelation> originalCollection = new MassiveBusinessObjectCollection<DocumentFieldRelation>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<DocumentFieldRelation>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.DocumentNumberComponent)
            {
                MassiveBusinessObjectCollection<DocumentNumberComponent> modifiedCollection = new MassiveBusinessObjectCollection<DocumentNumberComponent>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetDocumentNumberComponents();
                MassiveBusinessObjectCollection<DocumentNumberComponent> originalCollection = new MassiveBusinessObjectCollection<DocumentNumberComponent>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<DocumentNumberComponent>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.DocumentType)
            {
                MassiveBusinessObjectCollection<DocumentType> modifiedCollection = new MassiveBusinessObjectCollection<DocumentType>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetDocumentTypes();
                MassiveBusinessObjectCollection<DocumentType> originalCollection = new MassiveBusinessObjectCollection<DocumentType>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<DocumentType>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.IssuePlace)
            {
                MassiveBusinessObjectCollection<IssuePlace> modifiedCollection = new MassiveBusinessObjectCollection<IssuePlace>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetIssuePlaces();
                MassiveBusinessObjectCollection<IssuePlace> originalCollection = new MassiveBusinessObjectCollection<IssuePlace>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<IssuePlace>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.ItemField)
            {
                MassiveBusinessObjectCollection<ItemField> modifiedCollection = new MassiveBusinessObjectCollection<ItemField>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetItemFields();
                MassiveBusinessObjectCollection<ItemField> originalCollection = new MassiveBusinessObjectCollection<ItemField>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<ItemField>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.ItemRelationAttrValueType)
            {
                MassiveBusinessObjectCollection<ItemRelationAttrValueType> modifiedCollection = new MassiveBusinessObjectCollection<ItemRelationAttrValueType>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetItemRelationAttrValueTypes();
                MassiveBusinessObjectCollection<ItemRelationAttrValueType> originalCollection = new MassiveBusinessObjectCollection<ItemRelationAttrValueType>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<ItemRelationAttrValueType>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.ItemRelationType)
            {
                MassiveBusinessObjectCollection<ItemRelationType> modifiedCollection = new MassiveBusinessObjectCollection<ItemRelationType>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetItemRelationTypes();
                MassiveBusinessObjectCollection<ItemRelationType> originalCollection = new MassiveBusinessObjectCollection<ItemRelationType>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<ItemRelationType>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.ItemType)
            {
                MassiveBusinessObjectCollection<ItemType> modifiedCollection = new MassiveBusinessObjectCollection<ItemType>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetItemTypes();
                MassiveBusinessObjectCollection<ItemType> originalCollection = new MassiveBusinessObjectCollection<ItemType>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<ItemType>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.JobPosition)
            {
                MassiveBusinessObjectCollection<JobPosition> modifiedCollection = new MassiveBusinessObjectCollection<JobPosition>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetJobPositions();
                MassiveBusinessObjectCollection<JobPosition> originalCollection = new MassiveBusinessObjectCollection<JobPosition>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<JobPosition>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.NumberSetting)
            {
                MassiveBusinessObjectCollection<NumberSetting> modifiedCollection = new MassiveBusinessObjectCollection<NumberSetting>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetNumberSettings();
                MassiveBusinessObjectCollection<NumberSetting> originalCollection = new MassiveBusinessObjectCollection<NumberSetting>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<NumberSetting>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.PaymentMethod)
            {
                MassiveBusinessObjectCollection<PaymentMethod> modifiedCollection = new MassiveBusinessObjectCollection<PaymentMethod>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetPaymentMethods();
                MassiveBusinessObjectCollection<PaymentMethod> originalCollection = new MassiveBusinessObjectCollection<PaymentMethod>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<PaymentMethod>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.Unit)
            {
                MassiveBusinessObjectCollection<Unit> modifiedCollection = new MassiveBusinessObjectCollection<Unit>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetUnits();
                MassiveBusinessObjectCollection<Unit> originalCollection = new MassiveBusinessObjectCollection<Unit>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<Unit>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.UnitType)
            {
                MassiveBusinessObjectCollection<UnitType> modifiedCollection = new MassiveBusinessObjectCollection<UnitType>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetUnitTypes();
                MassiveBusinessObjectCollection<UnitType> originalCollection = new MassiveBusinessObjectCollection<UnitType>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<UnitType>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.VatRate)
            {
                MassiveBusinessObjectCollection<VatRate> modifiedCollection = new MassiveBusinessObjectCollection<VatRate>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetVatRates();
                MassiveBusinessObjectCollection<VatRate> originalCollection = new MassiveBusinessObjectCollection<VatRate>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<VatRate>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.Warehouse)
            {
                MassiveBusinessObjectCollection<Warehouse> modifiedCollection = new MassiveBusinessObjectCollection<Warehouse>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetVatRates();
                MassiveBusinessObjectCollection<Warehouse> originalCollection = new MassiveBusinessObjectCollection<Warehouse>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<Warehouse>(modifiedCollection, originalCollection);
            }
            else if (boType == BusinessObjectType.ContainerType)
            {
                MassiveBusinessObjectCollection<ContainerType> modifiedCollection = new MassiveBusinessObjectCollection<ContainerType>();
                modifiedCollection.Deserialize((XElement)modifiedXml.Root.FirstNode);

                XDocument originalXml = DictionaryMapper.Instance.GetContainerTypes();
                MassiveBusinessObjectCollection<ContainerType> originalCollection = new MassiveBusinessObjectCollection<ContainerType>();
                originalCollection.Deserialize((XElement)originalXml.Root.FirstNode);

                modifiedCollection.SetAlternateVersion(originalCollection);

                this.SaveMassiveBusinessObjectCollection<ContainerType>(modifiedCollection, originalCollection);
            }
            else
                throw new InvalidOperationException("Unknown dictionary object.");
            
            return XDocument.Parse("<root>ok</root>");
        }

        /// <summary>
        /// Releases the unmanaged resources used by the <see cref="DictionaryCoordinator"/> and optionally releases the managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void Dispose(bool disposing)
        {
            if (!this.IsDisposed)
            {
                if (disposing)
                {
                    //Dispose only managed resources here
                    SqlConnectionManager.Instance.ReleaseConnection();
                }
            }

            base.Dispose(disposing);
        }
    }
}
