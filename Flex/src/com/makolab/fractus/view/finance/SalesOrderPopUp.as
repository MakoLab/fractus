package com.makolab.fractus.view.finance
{
	import com.makolab.fractus.commands.SearchCommand;
	import com.makolab.fractus.model.LanguageManager;
	import com.makolab.fractus.view.documents.documentControls.InfoLinkButton;
	
	import mx.controls.PopUpButton;
	import mx.events.DropdownEvent;
	import mx.events.ListEvent;
	import mx.rpc.events.ResultEvent;

	[Event(name="salesOrderSelect", type="com.makolab.fractus.view.finance.SalesOrderEvent")]
	public class SalesOrderPopUp extends PopUpButton
	{
		[Bindable]
		public var contractorId:String;
		
		public function SalesOrderPopUp()
		{
			super();
			this.addEventListener(DropdownEvent.OPEN, openHandler);
			this.openAlways = true;
			LanguageManager.bindLabel(this, 'label', 'finance.selectSalesOrder');
			this.popUp = new SalesOrderGrid();
			this.popUp.width = 500;
			this.popUp.height = 200;
			this.popUp.addEventListener(ListEvent.ITEM_CLICK, itemClickHandler);
		}
		
		protected function openHandler(event:DropdownEvent):void
		{
			loadData();
		}
		
		protected function itemClickHandler(event:ListEvent):void
		{
			if(!(event.itemRenderer is InfoLinkButton))
			{
				var item:XML = event.itemRenderer.data as XML;
				var sevent:SalesOrderEvent = SalesOrderEvent.createEvent(SalesOrderEvent.SALESORDER_SELECT);
				sevent.salesOrderId = item.@id;
				dispatchEvent(sevent);
			}
		}
		
		protected function loadData():void
		{
			var requestXml:XML = <searchParams type="CommercialDocument">
								  <pageSize>200</pageSize>
								  <page>1</page>
								  <columns>
								    <column field="id" column="commercialDocumentId"/>
								    <column field="fullNumber"/>
								    <column field="issueDate" sortOrder="1" sortType="DESC"/>
								    <column field="contractor" column="fullName" relatedObject="contractor"/>
								    <column field="grossValue"/>
								  </columns>
								  <query/>
								  <filters>
								    <column field="status">60,40,20</column>
								    <column field="documentCategory">13</column>
								  </filters>
								  <groups/>
								</searchParams>;
			
			var cmd:SearchCommand = new SearchCommand(SearchCommand.DOCUMENTS, requestXml);
			cmd.addEventListener(ResultEvent.RESULT, this.setSalesOrders, false, 0, true);
			cmd.execute();
		}
		
		protected function setSalesOrders(event:ResultEvent):void
		{
			SalesOrderGrid(this.popUp).dataProvider = XML(event.result).*;
		}
	}
}