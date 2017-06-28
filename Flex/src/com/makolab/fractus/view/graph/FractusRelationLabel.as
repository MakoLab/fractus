package com.makolab.fractus.view.graph
{
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.controls.LinkButton;
	
	import org.un.cava.birdeye.ravis.components.renderers.edgeLabels.BaseEdgeLabelRenderer;

	public class FractusRelationLabel extends BaseEdgeLabelRenderer
	{
		protected override function getDetails(e:Event):void
		{
			Alert.show(String(this.data.data.toXMLString()));
		}
		
		protected override function initLinkButton():LinkButton
		{
			var lb:LinkButton = super.initLinkButton();
			lb.width = 150;
			return lb;
		}
		
	}
}