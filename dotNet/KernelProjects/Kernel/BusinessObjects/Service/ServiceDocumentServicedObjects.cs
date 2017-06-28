
namespace Makolab.Fractus.Kernel.BusinessObjects.Service
{
    internal class ServiceDocumentServicedObjects : BusinessObjectsContainer<ServiceDocumentServicedObject>
    {
        public ServiceDocumentServicedObjects(ServiceDocument parent)
            : base(parent, "serviceDocumentServicedObject")
        {
        }

        public override ServiceDocumentServicedObject CreateNew()
        {
            ServiceDocumentServicedObject obj = new ServiceDocumentServicedObject((ServiceDocument)this.Parent);
            obj.Order = this.Children.Count + 1;
            this.Children.Add(obj);
            return obj;
        }
    }
}
