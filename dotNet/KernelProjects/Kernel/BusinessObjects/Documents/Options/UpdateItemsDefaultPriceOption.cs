using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.Interfaces;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.Coordinators;

namespace Makolab.Fractus.Kernel.BusinessObjects.Documents.Options
{
	internal class UpdateItemsDefaultPriceOption : IDocumentOption
	{
		public void Execute(Document document)
		{
			CommercialDocument commercialDocument = (CommercialDocument)document;
			if (commercialDocument != null)
			{
				bool hasSystemCurrency = commercialDocument.HasSystemCurrency;
				using (ItemCoordinator coordinator = new ItemCoordinator(false, false))
				{
					List<Item> items = new List<Item>();
					foreach (CommercialDocumentLine line in commercialDocument.Lines)
					{
						Item item = (Item)coordinator.LoadBusinessObject(BusinessObjectType.Item, line.ItemId);
						decimal lineInitialNetPrice = commercialDocument.GetValueInSystemCurrency(line.InitialNetPrice);
						if (item.DefaultPrice != lineInitialNetPrice)
						{
							item.DefaultPrice = lineInitialNetPrice;
							items.Add(item);
						}
					}
					if (items.Count > 0)
					{
						coordinator.SaveLargeQuantityOfBusinessObjects<Item>(false, items.ToArray());
					}
				}
			}
		}

		public XElement Serialize()
		{
			return new XElement(DocumentOptionName.UpdateItemsDefaultPrice);
		}

		public bool ExecuteWithinTransaction
		{
			get { return true; }
		}
	}
}
