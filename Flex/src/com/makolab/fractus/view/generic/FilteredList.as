package com.makolab.fractus.view.generic
{
	import mx.collections.ICollectionView;
	import mx.controls.List;

	[Event(name="slotClick", type="warehouseMap.WarehouseSlotEvent")]
	public class FilteredList extends List
	{
		public function FilteredList()
		{
			super();
		}
		
		private var _filterString:String;
		public function set filterString(value:String):void
		{
			if (_filterString != value)
			{
				this._filterString = value;
				this.filterExp = new RegExp(this._filterString, 'i');
				var cv:ICollectionView = this.dataProvider as ICollectionView;
				if (cv)
				{
					if (cv.filterFunction != this.filterFunction) cv.filterFunction = this.filterFunction;
					cv.refresh();	
				}
			}
		}
		public function get filterString():String
		{
			return _filterString;
		}
		
		private var filterExp:RegExp;
		
		public override function set dataProvider(value:Object):void
		{
			super.dataProvider = value;
			ICollectionView(dataProvider).filterFunction = this.filterFunction;
			ICollectionView(dataProvider).refresh();
		}
		
		private function filterFunction(item:Object):Boolean
		{
			if (!filterExp || !labelField) return true;
			return Boolean(String(item[labelField]).match(this.filterExp));
		}
				
	}
}