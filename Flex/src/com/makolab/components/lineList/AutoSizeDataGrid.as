package com.makolab.components.lineList
{
	import mx.collections.ICollectionView;
	import mx.controls.DataGrid;

	public class AutoSizeDataGrid extends DataGrid
	{
		public var autoHeight:Boolean = true;
		
		public var maxRows:int = 15;
		
		override protected function measure():void
		{
			super.measure();
			if (autoHeight) measuredHeight = getHeight();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			try
			{
				super.updateDisplayList(unscaledWidth, unscaledHeight);
				if (autoHeight && measuredHeight != getHeight()) invalidateSize();
			}
			catch(e:Error)
			{
				trace("wystapil glupi wyjatek w kodzie adobe: " + e.toString());
			}
		}
		
		protected function getHeight():Number
		{
			if (!dataProvider) return headerHeight;
			var rows:int = ICollectionView(dataProvider).length;
			if (maxRows > 0 && rows > maxRows) rows = maxRows;
			return rows * rowHeight + headerHeight + borderMetrics.top + borderMetrics.bottom;
		}
	}
}