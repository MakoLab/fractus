using System;
using System.Xml.Linq;

namespace Makolab.Fractus.Kernel.MethodInputParameters
{
    internal class GetHeadersIdForWarehouseLinesResponse
    {
        public Guid LineId { get; set; }
        public Guid WarehouseDocumentHeaderId { get; set; }
        public Guid DocumentTypeId { get; set; }

        public GetHeadersIdForWarehouseLinesResponse(XElement line)
        {
            this.LineId = new Guid(line.Attribute("id").Value);
            this.WarehouseDocumentHeaderId = new Guid(line.Attribute("warehouseDocumentHeaderId").Value);
            this.DocumentTypeId = new Guid(line.Attribute("documentTypeId").Value);
        }
    }
}
