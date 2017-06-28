
namespace Makolab.Fractus.Kernel.BusinessObjects.Service
{
    internal class ServiceDocumentEmployees : BusinessObjectsContainer<ServiceDocumentEmployee>
    {
        public ServiceDocumentEmployees(ServiceDocument parent)
            : base(parent, "serviceDocumentEmployee")
        {
        }

        public override ServiceDocumentEmployee CreateNew()
        {
            ServiceDocumentEmployee obj = new ServiceDocumentEmployee((ServiceDocument)this.Parent);
            obj.Order = this.Children.Count + 1;
            this.Children.Add(obj);
            return obj;
        }
    }
}
