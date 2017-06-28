package com.makolab.components.layoutComponents.footerDataGrid
{
import flash.display.DisplayObject;
import mx.controls.DataGrid;
import mx.core.IUIComponent;
import mx.core.EdgeMetrics;
import mx.styles.ISimpleStyleClient;

public class FooterDataGrid extends DataGrid
{

	public function FooterDataGrid()
	{
		super();
	}

	override public function get borderMetrics():EdgeMetrics
	{
		return (border as FooterBorder).borderMetrics;
	}

	override protected function createBorder():void
	{
        if (!border)
        {
            var borderClass:Class = FooterBorder;

            border = new borderClass();

            if (border is IUIComponent)
                IUIComponent(border).enabled = enabled;
            if (border is ISimpleStyleClient)
                ISimpleStyleClient(border).styleName = this;

            // Add the border behind all the children.
            addChildAt(DisplayObject(border), 0);

            invalidateDisplayList();
        }
	}

}

}