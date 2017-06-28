package com.makolab.fractus.view.graph
{
	import flash.display.Graphics;
	
	import org.un.cava.birdeye.ravis.graphLayout.visual.IVisualEdge;
	import org.un.cava.birdeye.ravis.graphLayout.visual.edgeRenderers.BaseEdgeRenderer;

	public class FractusRelationRenderer extends BaseEdgeRenderer
	{
		public function FractusRelationRenderer(g:Graphics)
		{
			super(g);
		}
		
		override public function applyLineStyle(ve:IVisualEdge):void
		{
			if (ve.data.@edgeLabel == '') ve.lineStyle.color = 0xAAAAFF;
			else ve.lineStyle.color = 0x666666;
			super.applyLineStyle(ve);
		}
		
	}
}