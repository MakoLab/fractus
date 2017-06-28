package com.makolab.components.layoutComponents.footerDataGrid
{
import flash.display.Shape;
import flash.display.DisplayObject;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.DataGrid;
import mx.core.EdgeMetrics;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.skins.Border;

import mx.core.mx_internal;
use namespace mx_internal;

public class FooterBorder extends UIComponent
{

	public function FooterBorder()
	{
		super();
	}

	protected var border:IFlexDisplayObject;

	protected var overlay:Shape;

	protected var dataGrid:DataGrid;

	/**
	 *  create the actual border here
	 */
	override protected function createChildren():void
	{
		var borderClass:Class = (parent as DataGrid).getStyle("borderSkin");
		border = new borderClass() as IFlexDisplayObject;
		(border as Border).styleName = styleName;	// delegate styles
		addChild(DisplayObject(border));

		dataGrid = parent as DataGrid;

		overlay = new Shape();
		addChild(overlay);
	}

	/**
	 *	lay it out
	 */
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		overlay.graphics.clear();

		border.setActualSize(w, h);
		var bm:EdgeMetrics = (border as Border).borderMetrics;

		// destroy the old children
		while (numChildren > 2)
			removeChildAt(2);

		// make new ones
		var cols:Array = dataGrid.columns;
		var firstCol:int = dataGrid.horizontalScrollPosition;

		var colIndex:int = 0;
		var n:int = cols.length;
		var i:int = 0;
		while (colIndex < firstCol)
		{
			// find first visible column;
			if (cols[i++].visible)
				colIndex ++;
		}
		
		var vm:EdgeMetrics = dataGrid.viewMetrics;
        var lineCol:uint = dataGrid.getStyle("verticalGridLineColor");
        var vlines:Boolean = dataGrid.getStyle("verticalGridLines");
		overlay.graphics.lineStyle(1, lineCol);

		var xx:Number = vm.left;
		var yy:Number = h - bm.bottom - dataGrid.rowHeight;
		while (xx < w - vm.right)
		{
			var col:DataGridColumn = cols[i++];

			if (col is FooterDataGridColumn)
			{
				var fdgc:FooterDataGridColumn = col as FooterDataGridColumn;
				fdgc.footerColumn.owner = fdgc.owner;
				var renderer:IListItemRenderer = (fdgc.footerColumn.itemRenderer) ? 
														fdgc.footerColumn.itemRenderer.newInstance() :
														dataGrid.itemRenderer.newInstance();
				renderer.styleName = fdgc.footerColumn;
				if (renderer is IDropInListItemRenderer)
				{
					IDropInListItemRenderer(renderer).listData = new DataGridListData((fdgc.footerColumn.labelFunction != null) ? fdgc.footerColumn.labelFunction(col) 
																						: fdgc.footerColumn.headerText, 
															fdgc.dataField, i - 1, null, 
															dataGrid, -1);
				}
				renderer.data = fdgc;
				addChild(DisplayObject(renderer));
				renderer.x = xx;
				renderer.y = yy;
				renderer.setActualSize(col.width - 1, dataGrid.rowHeight);
				if (vlines)
				{
					overlay.graphics.moveTo(xx + col.width, yy);
					overlay.graphics.lineTo(xx + col.width, h - bm.bottom);
				}
			}
			xx += col.width;
		}
        lineCol = dataGrid.getStyle("horizontalGridLineColor");
        if (dataGrid.getStyle("horizontalGridLines"))
		{
			overlay.graphics.lineStyle(1, lineCol);
			overlay.graphics.moveTo(vm.left, yy);
			overlay.graphics.lineTo(w - vm.right, yy);
		}
	}

	/**
	 *  factor in the footer
	 */
	public function get borderMetrics():EdgeMetrics
	{
		var em:EdgeMetrics = (border as Border).borderMetrics.clone();
		em.bottom += dataGrid.rowHeight;
		return em;
	}

}

}