package com.makolab.components.inputComponents
{
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.ListData;
	import mx.core.IDataRenderer;
	import mx.utils.ObjectUtil;
	
	public class DataObjectManager
	{
		public static function getDataObject(data:Object, listData:Object):Object
		{
			var dataObject:Object;
			
			if (listData && listData is DataGridListData)
				dataObject = data ? data[DataGridListData(listData).dataField] : null;
			else if (listData is ListData && ListData(listData).labelField in data)
				dataObject = data[ListData(listData).labelField];
			else
				dataObject = data;
				
    	    return dataObject;
		}
	}
}