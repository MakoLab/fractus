package com.makolab.components.catalogue.dynamicOperations
{
	public class AddToClipboardOperation extends DynamicOperation
	{
		public override function invokeOperation(operationIndex:int = -1):void
		{
			//<commercialDocumentHeader id_lp="11" id="B879E24B-A08C-415A-A3B2-295445E43911" documentTypeId="44997297-4BAA-4801-86B5-CC2AE23A576C" status="40" fullNumber="3/O1/2009" nazwa_kontrahenta="BIT SOFTWARE" issueDate="2009-09-07T16:26:54"/>
			
			var id:String = this.panel.documentXML.id;
			var documentTypeId:String = this.panel.documentXML.documentTypeId;
			var status:String = this.panel.documentXML.status;
			var fullNumber:String = this.panel.documentXML.number.fullNumber;
			var contractor:String = this.panel.documentXML.contractor.contractor.fullName.length() > 0 ? String(this.panel.documentXML.contractor.contractor.fullName) : "";
			var issueDate:String = this.panel.documentXML.issueDate;
			
			var xml:XML = <commercialDocument id={id} documentTypeId={documentTypeId} status={status} fullNumber={fullNumber} contractor={contractor} issueDate={issueDate} />;
			this.panel.documentList.addToClipboard(xml);
		}
	}
}