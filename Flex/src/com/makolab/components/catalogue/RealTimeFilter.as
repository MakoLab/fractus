package com.makolab.components.catalogue
{
	import mx.collections.ICollectionView;
	
	/**
	 * Class responsible for real-time filtering of search results.
	 */
	public class RealTimeFilter
	{
		public function RealTimeFilter()
		{
		}
		
		/**
		 * Array of RegExp objects matched against the item.
		 */
		protected var filterArray:Array;
		
		/**
		 * Array of fields that should be taken into account when selecting visible items.
		 * Eg. <code>['@shortName', '@code']</code>
		 */
		public var filterFields:Array;
		
		/**
		 * Initializez <code>filterFields</code> property based on given column list.
		 */
		public function setFilterFields(columns:XMLList):void
		{
			var fields:Array = [];
			for each (var x:XML in columns.(valueOf().@filter == 1)) fields.push(String(x.@field));
			filterFields = fields.length > 0 ? fields : null;
			updateCollectionFilterFunction();
		}
		
		/**
		 * Call this function whenever the user changes text used to filter the results.
		 * The collection is refreshed after calling this function according to new criteria.
		 */
		public function setFilterText(text:String):void
		{
			if (text) {
				filterArray = [];
				var words:Array = text.split(/\s+/g);
				for each (var i:String in words) filterArray.push(new RegExp(i.toUpperCase(), "i"));
			}
			else filterArray = null;
			if (_collection && filterFields) _collection.refresh();
		}
		
		/**
		 * Assign a reference to this function to <code>filterFunction</code> property of your control.
		 */
		public function filterFunction(item:Object):Boolean
		{
			if (!item) return false;
			if (!filterFields) return true;
			if(filterArray)
			if((filterArray[0] as RegExp).source=="*") return true;
			var a:Array = [];
			for each (var i:String in filterFields) a.push(item[i]);
			var txt:String = a.join().toUpperCase();
			if (!txt || !filterArray) return true;
			for each (var re:RegExp in filterArray) 
				if (!txt.match(re)) return false;
			return true;
		}
		
		private var _collection:ICollectionView;
		public function set collection(value:ICollectionView):void
		{
			if (_collection && _collection.filterFunction == this.filterFunction) _collection.filterFunction = null;
			_collection = value;
			updateCollectionFilterFunction();
		}
		public function get collection():ICollectionView
		{
			return _collection;
		}
		
		private function updateCollectionFilterFunction():void
		{
			var enableFilter:Boolean = Boolean(this.filterFields);
			if (enableFilter && _collection) _collection.filterFunction = this.filterFunction;
			else if (!enableFilter && _collection && _collection.filterFunction == this.filterFunction) _collection.filterFunction = null;
		}
	}
}