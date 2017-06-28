package com.makolab.components.layoutComponents
{
	import flash.display.DisplayObject;
	
	import mx.containers.FormItem;
	import mx.containers.Tile;
	import mx.containers.TileDirection;
	import mx.controls.Label;
	import mx.core.EdgeMetrics;
	import mx.core.IInvalidating;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.styles.StyleManager;

	public class TileForm extends Tile
	{
		private var cellHeight:Number;
		private var cellWidth:Number;
		
	    /**
	     *  @private
	     */
	    private var measuredLabelWidth:Number;
	    
		public function TileForm()
		{
			super();
		}
		
		/**
	     *  The maximum width, in pixels, of the labels of the FormItems containers in this Form.
	     */
	    public function get maxLabelWidth():Number
	    {
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var child:DisplayObject = getChildAt(i);
	            if (child is FormItem)
	            {
	                var itemLabel:Label = FormItem(child).itemLabel;
	                if (itemLabel)
	                    return itemLabel.width;
	            }
	        }
	        
	        return 0;
	    }
		
		override protected function measure():void
		{
			super.measure();
			
			calculateLabelWidth();
			var i:int;
			
			// TODO dorobic okreslenie innej szerokosc labela w kazdej kolumnie.
			for (var c:int = 0; c < numChildren; c++)
			{
				var child:DisplayObject = getChildAt(c);
				if(child is FormItem)
				{
					FormItem(child).itemLabel.measuredWidth = measuredLabelWidth + 6; // + 6px bo labelWidth FormItema albo measuredWidth Texta jakos zle sie liczy. 
					FormItem(child).invalidateSize();
				}
			}
			
			var preferredWidth:Number;
	        var preferredHeight:Number;
	        var minWidth:Number;
	        var minHeight:Number;	
	
	        // Determine the size of each tile cell and cache the values
	        // in cellWidth and cellHeight for later use by updateDisplayList().
	        findCellSize();
	
	        // Min width and min height are large enough to display a single child.
	        minWidth = cellWidth;
	        minHeight = cellHeight;
	
	        // Determine the width and height necessary to display the tiles
	        // in an N-by-N grid (with number of rows equal to number of columns).
	        var n:int = numChildren;
	
	        // Don't count children that don't need their own layout space.
	        var temp:int = n;
	        for (i = 0; i < n; i++)
	        {
	            if (!IUIComponent(getChildAt(i)).includeInLayout)
	                temp--;
	        }
	        n = temp;
	
	        if (n > 0)
	        {
	            var horizontalGap:Number = getStyle("horizontalGap");
	            var verticalGap:Number = getStyle("verticalGap");
	            
	            var majorAxis:Number;
	            
	            //if (direction == TileDirection.HORIZONTAL && isNaN(explicitWidth)) explicitWidth = measuredWidth;
	            //if (direction == TileDirection.VERTICAL && isNaN(explicitHeight)) explicitHeight = measuredHeight;
	
	            // If an explicit dimension or flex is set for the majorAxis,
	            // set as many children as possible along the axis.
	            if (direction == TileDirection.HORIZONTAL)
	            {
	                var unscaledExplicitWidth:Number = isNaN(width) ? measuredWidth / Math.abs(scaleX) : width / Math.abs(scaleX);
	                if (!isNaN(unscaledExplicitWidth))
	                {
	                    // If we have an explicit height set,
	                    // see how many children can fit in the given height:
	                    // majorAxis * (cellWidth + horizontalGap) - horizontalGap == unscaledExplicitWidth
	                    majorAxis = Math.floor((unscaledExplicitWidth + horizontalGap) /
	                                           (cellWidth + horizontalGap));
	                }
	            }
	            else
	            {
	                var unscaledExplicitHeight:Number = isNaN(height) ? measuredHeight / Math.abs(scaleY) : height / Math.abs(scaleY);
	                if (!isNaN(unscaledExplicitHeight))
	                {
	                    // If we have an explicit height set,
	                    // see how many children can fit in the given height:
	                    // majorAxis * (cellHeight + verticalGap) - verticalGap == unscaledExplicitHeight
	                    majorAxis = Math.floor((unscaledExplicitHeight + verticalGap) /
	                                           (cellHeight + verticalGap));
	                }
	            }
	
	            // Finally, if majorAxis still isn't defined, use the
	            // square root of the number of children.
	            if (isNaN(majorAxis))
	            {
	                majorAxis = Math.ceil(Math.sqrt(n));
	            	/* var columns:int = Math.floor(this.measuredWidth / cellWidth);
					var rows:int = Math.ceil(this.getChildren().length / columns);
					height = tileHeight * rows + Number(this.getStyle("verticalGap")) * rows; */
	            }
	
	            // Even if there's not room, force at least one cell
	            // on each row/column.
	            if (majorAxis < 1)
	                majorAxis = 1;
	
	            var minorAxis:Number = Math.ceil(n / majorAxis);
	
	            if (direction == TileDirection.HORIZONTAL)
	            {
	                preferredWidth = majorAxis * cellWidth +
	                                 (majorAxis - 1) * horizontalGap;
	
	                preferredHeight = minorAxis * cellHeight +
	                                  (minorAxis - 1) * verticalGap;
	                                  
	                preferredHeight = 0;
		            for (i = 0; i < minorAxis; i++)
		            {
		            	preferredHeight += getRowHeight((i + 1),majorAxis);
		            	preferredHeight += verticalGap;
		            }
	            }
	            else
	            {
	                preferredWidth = minorAxis * cellWidth +
	                                 (minorAxis - 1) * horizontalGap;
	
	                preferredHeight = majorAxis * cellHeight +
	                                  (majorAxis - 1) * verticalGap;
	                                  
	                preferredWidth = 0;
		            for (i = 0; i < majorAxis; i++)
		            {
		            	preferredWidth += getColumnWidth((i + 1),minorAxis);
		            	preferredWidth += horizontalGap;
		            }
	            }
	        }
	        else
	        {
	            preferredWidth = minWidth;
	            preferredHeight = minHeight;
	        }
	
	        var vm:EdgeMetrics = viewMetricsAndPadding;
	        var hPadding:Number = vm.left + vm.right;
	        var vPadding:Number = vm.top + vm.bottom;
	        
	        // Add padding for margins and borders.
	        minWidth += hPadding;
	        preferredWidth += hPadding;
	        minHeight += vPadding;
	        preferredHeight += vPadding;
	
	        measuredMinWidth = Math.ceil(minWidth);
	        measuredMinHeight = Math.ceil(minHeight);
	        measuredWidth = Math.ceil(preferredWidth);
	        measuredHeight = Math.ceil(preferredHeight);
		}
		
	    private function findCellSize():void
	    {
	        // If user explicitly supplied both a tileWidth and
	        // a tileHeight, then use those values.
	        var widthSpecified:Boolean = !isNaN(tileWidth);
	        var heightSpecified:Boolean = !isNaN(tileHeight);
	        if (widthSpecified && heightSpecified)
	        {
	            cellWidth = tileWidth;
	            cellHeight = tileHeight;
	            return;
	        }
	
	        // Reset the max child width and height
	        var maxChildWidth:Number = 0;
	        var maxChildHeight:Number = 0;
	        
	        // Loop over the children to find the max child width and height.
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var child:IUIComponent = IUIComponent(getChildAt(i));
	
	            if (!child.includeInLayout)
	                continue;
	            
	            var width:Number = child.getExplicitOrMeasuredWidth();
	            if (width > maxChildWidth)
	                maxChildWidth = width;
	            
	            var height:Number = child.getExplicitOrMeasuredHeight();
	            if (height > maxChildHeight) 
	                maxChildHeight = height;
	        }
	        
	        // If user explicitly specified either width or height, use the
	        // user-supplied value instead of the one we computed.
	        cellWidth = widthSpecified ? tileWidth : maxChildWidth;
	        cellHeight = heightSpecified ? tileHeight : maxChildHeight;
	    }
		    
	    /**
	     *  @private
	     */
	    private function invalidateLabelWidth():void
	    {
	        // We only need to invalidate the label width
	        // after we've been initialized.
	        if (!isNaN(measuredLabelWidth) && initialized)
	        {
	            measuredLabelWidth = NaN;
	
	            // Need to invalidate the size of all children
	            // to make sure they respond to the label width change.
	            var n:int = numChildren;
	            for (var i:int = 0; i < n; i++)
	            {
	                var child:IUIComponent = IUIComponent(getChildAt(i));
	                if (child is IInvalidating)
	                    IInvalidating(child).invalidateSize();
	            }
	        }
	    }
	        
	    /**
	     *  @private
	     */
	    private function calculateLabelWidth():Number
	    {
	        // See if we've already calculated it.
	        if (!isNaN(measuredLabelWidth))
	            return measuredLabelWidth;
	
	        var labelWidth:Number = 0;
	        var labelWidthSet:Boolean = false;
	
	        // Determine best label width.
	        var n:int = numChildren;
	        for (var i:int = 0; i < n; i++)
	        {
	            var child:DisplayObject = getChildAt(i);
	
	            if (child is FormItem)
	            {
	            	var w:Number = child["itemLabel"].measuredWidth;
	                labelWidth = Math.max(labelWidth,
	                                      (child as FormItem).itemLabel.measuredWidth);
					// only set measuredLabelWidth yet if we have at least one FormItem child
					labelWidthSet = true;
	            }
	        }
	
			if (labelWidthSet)
	        	measuredLabelWidth = labelWidth;
	
	        return labelWidth;
	    }

	    /**
	     *  @private
	     */
	    override public function styleChanged(styleProp:String):void
	    {
	        // Check to see if this is one of the style properties
	        // that is known to affect layout.
	        if (!styleProp ||
	            styleProp == "styleName" ||
	            StyleManager.isSizeInvalidatingStyle(styleProp))
	        {
	            invalidateLabelWidth();
	        }
	
	        super.styleChanged(styleProp);
	    }
	    
	    private function getRowHeight(row:int,columns:int):Number
	    {
	        var childIndex:int;
	    	var rowHeight:Number = 0;
	        var n:int = numChildren;
	        var rowChildren:Array = new Array();
            if (row > 0) {
            	
                var firstInRow:int = columns * (row - 1);
                var lastInRow:int = Math.min(n - 1,(columns * (row) - 1));
			
				for (childIndex = firstInRow; childIndex < lastInRow + 1; childIndex++)
				{
					rowChildren.push(getChildAt(childIndex));
					rowHeight = Math.max(rowHeight,(getChildAt(childIndex) as UIComponent).includeInLayout ? getChildAt(childIndex).height : 0);
				}
            }else{
            	rowHeight = 0;
            }
            //trace(getChildAt(row).toString() + ": " + rowHeight + ": " + getChildAt(row).height.toString());
            return rowHeight;
	    }
	    
	    private function getColumnWidth(column:int,rows:int):Number
	    {
	        var childIndex:int;
	    	var columnWidth:Number = 0;
	        var n:int = numChildren;
            if (column > 0) {
                var firstInColumn:int = rows * (column - 1);
                var lastInColumn:int = Math.min(n - 1,(rows * (column) - 1));
			
				for (childIndex = firstInColumn; childIndex < lastInColumn + 1; childIndex++)
				{
					columnWidth = Math.max(columnWidth,(getChildAt(childIndex) as UIComponent).includeInLayout ? getChildAt(childIndex).width : 0);
				}
            }else{
            	columnWidth = 0;
            }
            
            return columnWidth;
	    }
	    
	    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	
	        // The measure function isn't called if the width and height of
	        // the Tile are hard-coded. In that case, we compute the cellWidth
	        // and cellHeight now.
	        if (isNaN(cellWidth) || isNaN(cellHeight))
	            findCellSize();
	        
	        var vm:EdgeMetrics = viewMetricsAndPadding;
	        
	        var paddingLeft:Number = getStyle("paddingLeft");
	        var paddingTop:Number = getStyle("paddingTop");
	
	        var horizontalGap:Number = getStyle("horizontalGap");
	        var verticalGap:Number = getStyle("verticalGap");
	       
	        var horizontalAlign:String = getStyle("horizontalAlign");
	        var verticalAlign:String = getStyle("verticalAlign");
	
	        var xPos:Number = paddingLeft;
	        var yPos:Number = paddingTop;
	
	        var xOffset:Number;
	        var yOffset:Number;
	        
	        var n:int = numChildren;
	        var i:int;
	        var childIndex:int;
	        var child:IUIComponent;
	        
	        if (direction == TileDirection.HORIZONTAL)
	        {
	            var xEnd:Number = Math.ceil(unscaledWidth) - vm.right;
	            
	            var columns:int = Math.floor((xEnd + horizontalGap) /
	                                           (cellWidth + horizontalGap));
				if (columns < 0) columns = 1;
	
	            for (i = 0; i < n; i++)
	            {
	                child = IUIComponent(getChildAt(i));
	
	                if (!child.includeInLayout)
	                    continue;
	                
	                var row:int = Math.floor(i / columns);
	                var rowHeight:Number = getRowHeight(row,columns);
					
	                // Start a new row?
	                if (xPos + cellWidth > xEnd)
	                {
	                    // Only if we have not just started one...
	                    if (xPos != paddingLeft)
	                    {
	                        yPos += (rowHeight + verticalGap);
	                        xPos = paddingLeft;
	                    }
	                }
	                
	                setChildSize(child); // calls child.setActualSize()
	
	                // Calculate the offsets to align the child in the cell.
	                xOffset = Math.floor(calcHorizontalOffset(
	                    child.width, horizontalAlign));
	                yOffset = Math.floor(calcVerticalOffset(
	                    child.height, verticalAlign));
	                            
	                child.move(xPos + xOffset, yPos + yOffset);
	
	                xPos += (cellWidth + horizontalGap);
	            }
	        }
	        else
	        {
	            var yEnd:Number = Math.ceil(unscaledHeight) - vm.bottom;
				
				var rows:int = Math.floor((xEnd + horizontalGap) /
	                                           (cellWidth + horizontalGap));
				if (rows < 0) rows = 1;
				
	            for (i = 0; i < n; i++)
	            {
	                child = IUIComponent(getChildAt(i));
	
	                if (!child.includeInLayout)
	                    continue;
	                    
	                var column:int = Math.floor(i / columns);
	                var columnWidth:Number = getColumnWidth(column,rows);
	                if (column > 0) {
		                var firstInColumn:int = rows * (column - 1);
		                var lastInColumn:int = Math.min(n,(rows * (column) - 1));
					
						for (childIndex = firstInColumn; childIndex < lastInColumn + 1; childIndex++)
						{
							columnWidth = Math.max(columnWidth,getChildAt(childIndex).width);
						}
	                }else{
	                	columnWidth = 0;
	                }
	
	                // Start a new column?
	                if (yPos + cellHeight > yEnd)
	                {
	                    // Only if we have not just started one...
	                    if (yPos != paddingTop)
	                    {
	                        xPos += (columnWidth + horizontalGap);
	                        yPos = paddingTop;
	                    }
	                }
	                
	                setChildSize(child); // calls child.setActualSize()
	
	                // Calculate the offsets to align the child in the cell.
	                xOffset = Math.floor(calcHorizontalOffset(
	                    child.width, horizontalAlign));
	                yOffset = Math.floor(calcVerticalOffset(
	                    child.height, verticalAlign));
	            
	                child.move(xPos + xOffset, yPos + yOffset);
	
	                yPos += (cellHeight + verticalGap);
	            }
	        }
	
	        // Clear the cached cell size, because if a child's size changes
	        // it will be invalid. These cached values are only used to
	        // avoid recalculating in updateDisplayList() the same values
	        // that were just calculated in measure().
	        // They should not persist across invalidation/validation cycles.
	        // (An alternative approach we tried was to clear these
	        // values in an override of invalidateSize(), but this gets called
	        // called indirectly by setChildSize() and child.move() inside
	        // the loops above. So we had to save and restore cellWidth
	        // and cellHeight around these calls in the loops, which is ugly.)
	        cellWidth = NaN;
	        cellHeight = NaN;
	        
	        invalidateSize();
	    }
    
	    private function setChildSize(child:IUIComponent):void
	    {
	        var childWidth:Number;
	        var childHeight:Number;
	        var childPref:Number;
	        var childMin:Number;
	
	        if (child.percentWidth > 0)
	        {
	            // Set child width to be a percentage of the size of the cell.
	            childWidth = Math.min(cellWidth,
	                                  cellWidth * child.percentWidth / 100);
	        }
	        else
	        {
	            // The child is not flexible, so set it to its preferred width.
	            childWidth = child.getExplicitOrMeasuredWidth();
	
	            // If an explicit tileWidth has been set on this Tile,
	            // then the child may extend outside the bounds of the tile cell.
	            // In that case, we'll honor the child's width or minWidth,
	            // but only if those values were explicitly set by the developer,
	            // not if they were implicitly set based on measurements.
	            if (childWidth > cellWidth)
	            {
	                childPref = isNaN(child.explicitWidth) ?
	                            0 :
	                            child.explicitWidth;
	
	                childMin = isNaN(child.explicitMinWidth) ?
	                           0 :
	                           child.explicitMinWidth;
	
	                childWidth = (childPref > cellWidth ||
	                              childMin > cellWidth) ?
	                             Math.max(childMin, childPref) :
	                             cellWidth;
	            }
	        }
	
	        if (child.percentHeight > 0)
	        {
	            childHeight = Math.min(cellHeight,
	                                   cellHeight * child.percentHeight / 100);
	        }
	        else
	        {
	            childHeight = child.getExplicitOrMeasuredHeight();
	
	            if (childHeight > cellHeight)
	            {
	                childPref = isNaN(child.explicitHeight) ?
	                            0 :
	                            child.explicitHeight;
	
	                childMin = isNaN(child.explicitMinHeight) ?
	                           0 :
	                           child.explicitMinHeight;
	
	                childHeight = (childPref > cellHeight ||
	                               childMin > cellHeight) ?
	                               Math.max(childMin, childPref) :
	                               cellHeight;
	            }
	        }
	
	        child.setActualSize(childWidth, childHeight);
	    }
	    
	    private function calcHorizontalOffset(width:Number,
                                              horizontalAlign:String):Number
	    {
	        var xOffset:Number;
	
	        if (horizontalAlign == "left")
	            xOffset = 0;
	
	        else if (horizontalAlign == "center")
	            xOffset = (cellWidth - width) / 2;
	
	        else if (horizontalAlign == "right")
	            xOffset = (cellWidth - width);
	
	        return xOffset;
    	}

	    /**
	     *  @private
	     *  Compute how much adjustment must occur in the y direction
	     *  in order to align a component of a given height into the cell.
	     */
	    private function calcVerticalOffset(height:Number,
	                                            verticalAlign:String):Number
	    {
	        var yOffset:Number;
	
	        if (verticalAlign == "top")
	            yOffset = 0;
	
	        else if (verticalAlign == "middle")
	            yOffset = (cellHeight - height) / 2;
	
	        else if (verticalAlign == "bottom")
	            yOffset = (cellHeight - height);
	
	        return yOffset;
	    }
	}
}