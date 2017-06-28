package com.makolab.components.inputComponents
{
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Label;
	import mx.controls.listClasses.ListBase;
	import mx.controls.treeClasses.HierarchicalCollectionView;

	public class OrdinalNumberRenderer extends Label
	{
	
		override public function set data(value:Object):void
		{
			super.data = value;
			if(listData!=null){
				if(listData.owner is ListBase)text = ListBase(listData.owner).dataProvider.getItemIndex(data) + 1;
				else if(listData.owner is AdvancedDataGrid)
					if(!AdvancedDataGrid(listData.owner).dataProvider is HierarchicalCollectionView)
						text = AdvancedDataGrid(listData.owner).dataProvider.getItemIndex(data) + 1;
					else {
						var counter:int = 1;
						text = "";
						for each (var i:XML in AdvancedDataGrid(listData.owner).dataProvider){//.dataProvider.source.source
							if (XML(value)==i) text=counter.toString();
							counter++;
						}
					}
			}
		}
		
	}
}