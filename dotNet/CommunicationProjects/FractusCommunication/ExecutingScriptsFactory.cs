
namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Makolab.Commons.Communication;
    using Makolab.Fractus.Communication.Scripts;
    using System.Xml.Linq;
    using Makolab.Fractus.Kernel.Managers;
    using System.Data.SqlClient;
    using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;
    using Makolab.Fractus.Kernel.Mappers;

    /// <summary>
    /// Factory class creating objects that processes communication scripts.
    /// </summary>
    public class ExecutingScriptsFactory : IExecutingScriptsFactory
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ExecutingScriptsFactory"/> class.
        /// </summary>
        public ExecutingScriptsFactory()
        {
            this.ExecutionController = new ExecutionController(false, null);
        }

        /// <summary>
        /// Gets or sets the unit of work.
        /// </summary>
        /// <value>The unit of work.</value>
        public IUnitOfWork UnitOfWork { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether execution occurres in headquarter branch or not.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this branch is headquarter; otherwise, <c>false</c>.
        /// </value>
        public bool IsHeadquarter { get; set; }

        /// <summary>
        /// Gets or sets the local transaction id of generated outgoing packages.
        /// </summary>
        /// <value>The local transaction id.</value>
        public Guid LocalTransactionId { get; set; }

        /// <summary>
        /// Creates object responsible for processing package of specified type.
        /// </summary>
        /// <param name="packageType">Type of the package to processed.</param>
        /// <param name="xmlPackage">The XML package to process.</param>
        /// <returns>Created package processing object.</returns>
        public IExecutingScript CreateScript(string packageType, XDocument xmlPackage)
        {
            if (packageType == null) throw new ArgumentNullException("packageType");

            CommunicationPackageType packageTypeVal;
            try
            {
                packageTypeVal = (CommunicationPackageType)Enum.Parse(typeof(CommunicationPackageType), packageType);
            }
            catch (ArgumentException)
            {
                packageTypeVal = CommunicationPackageType.Unknown;
            }
            IExecutingScript script = null;
            switch (packageTypeVal)
            {
                case CommunicationPackageType.ComplaintDocumentSnapshot:
                    script = new ComplaintDocumentSnapshot(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.Configuration:
                    script = new ConfigurationScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.ContractorSnapshot:
                    script = new ContractorScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.ContractorRelations:
                    script = new ContractorRelationsScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.ContractorGroupMembership:
                    script = new ContractorGroupMembershipScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.DictionaryPackage:
                    script = new DictionarySnapshotScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.FileDescriptor:
                    script = new FileDescriptorScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.FinancialReport:
                    script = new FinancialReportScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.FinancialDocumentSnapshot:
                    script = new FinancialDocumentScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.InventoryDocumentSnapshot:
                    script = new InventoryDocumentScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.ItemSnapshot:
                    script = new ItemSnapshotScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.ItemRelation:
                    script = new ItemRelationScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.ItemUnitRelation:
                    script = new ItemUnitRelationScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.ItemGroupMembership:
                    script = new ItemGroupMembershipScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.CommercialDocumentSnapshot:
                    script = new CommercialDocumentScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.CommercialDocumentSnapshotEx:
                    script = new CommercialDocumentExScript(this.UnitOfWork, this.ExecutionController, this.IsHeadquarter);
                    break;
                case CommunicationPackageType.Series:
                    script = new SeriesScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.CommercialWarehouseValuation:
                    script = new CommercialWarehouseValuation(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.CommercialWarehouseRelation:
                    script = new CommercialWarehouseRelation(UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.DocumentRelation:
                    script = new DocumentRelationScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.IncomeOutcomeRelation:
                    script = new IncomeOutcomeRelation(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.Payment:
                    script = new PaymentScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.WarehouseDocumentValuation:
                    script = new WarehouseDocumentValuation(this.UnitOfWork, this.ExecutionController, this.IsHeadquarter);
                    break;
                //TODO !! aktualnie WZk dotykajaca mmki bedzie traktowana jak by nie miala nic wspolnego z mmka
                //     czyli nie zostanie przeslana do oddzialu docelowego
                case CommunicationPackageType.WarehouseDocumentSnapshot:
                    if (xmlPackage.Root.Element("warehouseDocumentLine").Elements("entry").All(row => row.Element("isDistributed").Value.Equals("1")))
                    {
                        DocumentType docType = DictionaryMapper.Instance.GetDocumentType(new Guid(xmlPackage.Root.Element("warehouseDocumentHeader")
                            .Element("entry").Element("documentTypeId").Value));
                        if (docType.DocumentCategory != Makolab.Fractus.Kernel.Enums.DocumentCategory.IncomeWarehouseCorrection && docType.DocumentCategory != Makolab.Fractus.Kernel.Enums.DocumentCategory.OutcomeWarehouseCorrection)
                        {
                            script = new ShiftDocumentSnapshot(this.UnitOfWork, this.ExecutionController, this.IsHeadquarter);
                        }
                        else script = new WarehouseDocumentSnapshot(this.UnitOfWork, this.ExecutionController, this.IsHeadquarter);  
                    }
                    else script = new WarehouseDocumentSnapshot(this.UnitOfWork, this.ExecutionController, this.IsHeadquarter);                    
                    break;
                case CommunicationPackageType.WarehouseStock:
                    script = new WarehouseStockScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.UnrelateCommercialDocument:
                    script = new UnrelateCommercialDocumentScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.UnrelateWarehouseDocumentForOutcome:
                    script = new UnrelateWarehouseDocumentForOutcomeScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.UnrelateWarehouseDocumentForIncome:
                    script = new UnrelateWarehouseDocumentForIncomeScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.ShiftDocumentStatus:
                    script = new ShiftDocumentStatusScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.PriceRule:
                    script = new PriceRuleScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.PriceRuleList:
                    script = new PriceRuleListScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.Custom:
                    script = new CustomScript(this.UnitOfWork, this.ExecutionController);
                    break;
                case CommunicationPackageType.Unknown:
                case CommunicationPackageType.Other:
                default:
                    script = new NullScript();
                    break;
            }
            script.LocalTransactionId = this.LocalTransactionId;
            return script;
        }

        /// <summary>
        /// Gets or sets the changeset buffer.
        /// </summary>
        /// <value>The changeset buffer.</value>
        public ExecutionController ExecutionController { get; set; }
    }
}
