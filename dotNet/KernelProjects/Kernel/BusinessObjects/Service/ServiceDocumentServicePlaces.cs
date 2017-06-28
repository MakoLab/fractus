
namespace Makolab.Fractus.Kernel.BusinessObjects.Service
{
    internal class ServiceDocumentServicePlaces : BusinessObjectsContainer<ServiceDocumentServicePlace>
    {
        public ServiceDocumentServicePlaces(ServiceDocument parent)
            : base(parent, "serviceDocumentServicePlace")
        {
        }

        public override ServiceDocumentServicePlace CreateNew()
        {
            ServiceDocumentServicePlace obj = new ServiceDocumentServicePlace((ServiceDocument)this.Parent);
            obj.Order = this.Children.Count + 1;
            this.Children.Add(obj);
            return obj;
        }
    }
}
