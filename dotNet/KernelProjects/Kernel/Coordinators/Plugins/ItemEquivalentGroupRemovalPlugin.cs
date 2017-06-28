using System;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.BusinessObjects;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators.Plugins
{
    internal class ItemEquivalentGroupRemovalPlugin : Plugin
    {
        private Item businessObject;
        private Guid? groupId;

        protected ItemEquivalentGroupRemovalPlugin(Item businessObject)
        {
            this.businessObject = businessObject;
        }

        public override void OnExecuteLogic(IBusinessObject businessObject)
        {
            Item alternateItem = (Item)this.businessObject.AlternateVersion;

            var relation = alternateItem.Relations.Children.Where(r => r.ItemRelationTypeName == ItemRelationTypeName.Item_EquivalentGroup 
                && r.Status == BusinessObjectStatus.Deleted).FirstOrDefault();

            if (relation != null)
                this.groupId = new Guid(((CustomBusinessObject)relation.RelatedObject).Value.Element("id").Value);
        }

        public override void OnAfterExecuteOperations(IBusinessObject businessObject)
        {
            if (this.groupId == null)
                return;

            ItemMapper mapper = DependencyContainerManager.Container.Get<ItemMapper>();

            XElement xml = mapper.GetItemEquivalents(this.businessObject.Id.Value, this.groupId.Value);

            if (xml.Elements().Count() == 1)
            {
                Item item = (Item)mapper.LoadBusinessObject(BusinessObjectType.Item, new Guid(xml.Element("item").Attribute("id").Value));

                item.Relations.Remove(item.Relations.Children.Where(r => r.ItemRelationTypeName == ItemRelationTypeName.Item_EquivalentGroup).First());

                using (ItemCoordinator c = new ItemCoordinator(false, false))
                {
                    c.SaveBusinessObject(item);
                }
            }
        }

        public static void Initialize(CoordinatorPluginPhase pluginPhase, ItemCoordinator coordinator, Item businessObject)
        {
            if (pluginPhase != CoordinatorPluginPhase.SaveObject)
                return;

            if (businessObject != null && !businessObject.IsNew)
                coordinator.Plugins.Add(new ItemEquivalentGroupRemovalPlugin(businessObject));
        }
    }
}
