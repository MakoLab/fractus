using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Interfaces;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Managers;

namespace Makolab.Fractus.Kernel.Coordinators.Logic
{
	internal abstract class DocumentLogic<DocumentType> where DocumentType : Document
	{
		#region Properties

		protected DocumentMapper Mapper { get; set; }
		protected DocumentCoordinator Coordinator { get; set; }
		protected DocumentType Document { get; set; }

		#endregion

		#region Methods

		protected virtual void CheckDateDifference()
		{
			if (Document.AlternateVersion != null)
			{
				Document alternate = (Document)Document.AlternateVersion;

				if (Document.IssueDate > alternate.IssueDate) //zmieniono date na przyszlosc
					Document.IssueDate = new DateTime(Document.IssueDate.Year, Document.IssueDate.Month, Document.IssueDate.Day, 0, 0, 0, 0);
				else if (Document.IssueDate < alternate.IssueDate)
					Document.IssueDate = new DateTime(Document.IssueDate.Year, Document.IssueDate.Month, Document.IssueDate.Day, 23, 59, 59, 500);
			}
		}

		protected void LoadAndSetAlternateVersion()
		{
			if (!Document.IsNew)
			{
				IBusinessObject alternateBusinessObject = this.Mapper.LoadBusinessObject(Document.BOType, Document.Id.Value);
				Document.SetAlternateVersion(alternateBusinessObject);
			}
		}

		protected void UpdateStatus()
		{
			Document.UpdateStatus(true);

			if (Document.AlternateVersion != null)
				Document.AlternateVersion.UpdateStatus(false);
		}

		protected abstract void ExecuteCustomLogic();

		protected void ExecuteDocumentOptions(bool withinTransaction = false)
		{
			foreach (IDocumentOption option
				in Document.DocumentOptions.Where(docOption => docOption.ExecuteWithinTransaction == withinTransaction))
			{
				option.Execute(Document);
			}
		}

		protected abstract void ExecuteCustomLogicDuringTransaction();

		protected abstract void ValidateDuringTransaction();

		protected void SaveChanges(XDocument operations)
		{
			Document.SaveChanges(operations);

			if (Document.AlternateVersion != null)
				Document.AlternateVersion.SaveChanges(operations);
		}

		protected void SaveRelations(XDocument operations)
		{
			Document.SaveRelations(operations);

			if (Document.AlternateVersion != null)
				((Document)Document.AlternateVersion).SaveRelations(operations);
		}

		protected void CommitOrRollbackTransaction()
		{
			//Custom validation
			this.Mapper.ExecuteOnCommitValidationCustomProcedure(Document);

			if (this.Coordinator.CanCommitTransaction)
			{
				if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
					SqlConnectionManager.Instance.CommitTransaction();
				else
					SqlConnectionManager.Instance.RollbackTransaction();
			}
		}

		#endregion
	}
}
