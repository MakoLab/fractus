package com.makolab.fractus.view.graph {
	
	import assets.IconManager;
	
	import com.makolab.fractus.model.document.DocumentTypeDescriptor;
	import com.makolab.fractus.view.documents.DocumentRenderer;
	import flash.events.Event;
	import mx.controls.Image;
	import mx.controls.LinkButton;
	import mx.core.UIComponent;
	
	import org.un.cava.birdeye.ravis.components.renderers.nodes.IconNodeRenderer;
	
	/**
	 * This a basic icon itemRenderer for a node. 
	 * Images are sourced by directory path and file name.
	 * Based on icons by Paul Davey aka Mattahan (http://mattahan.deviantart.com/).
	 * All rights reserved. 
	 * */
	public class FractusDocumentTypeIconRenderer extends IconNodeRenderer  {

		override protected function initComponent(e:flash.events.Event):void {
			
			var img:UIComponent;

			/* initialize the upper part of the renderer */
			initTopPart();
			
			/* add an icon as specified in the XML, this should
			 * be checked */
			img = new Image();			
			//Image(img).source = DynamicAssetsInjector.currentIconAssetClassRef[new DocumentTypeDescriptor(this.data.data.@documentTypeId).iconDocumentListName];
			Image(img).source = IconManager.getIcon(""+new DocumentTypeDescriptor(this.data.data.@documentTypeId).iconDocumentListName);
			//img.toolTip = this.data.data.@name; // needs check
			this.addChild(img);
						
			/* now add the filters to the circle */
			reffects.addDSFilters(img);
			 
			/* now the link button */
			initLinkButton();
		}
			
		override protected function initLinkButton():LinkButton
		{
			var lb:LinkButton = super.initLinkButton();
			lb.width = 200;
			return lb;
		}
		
		override protected function getDetails(e:flash.events.Event):void
		{
			DocumentRenderer.showWindow(this.data.data.@desc, this.data.data.@documentId);
		}
		
	}
}