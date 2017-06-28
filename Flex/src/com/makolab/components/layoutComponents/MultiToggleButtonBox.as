package com.makolab.components.layoutComponents
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.ListEvent;
	
	[Event(name="change",type="mx.events.ListEvent")]

	public class MultiToggleButtonBox extends HBox
	{
		public function MultiToggleButtonBox()
		{
			super();
		}

		//----------------------------------
		//  labelField
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for labelField property.
		 */
		private var _labelField:String = "label";
		
		[Bindable("labelFieldChanged")]
		[Inspectable(category="Data", defaultValue="label")]
		
		/**
		 *  The name of the field in the data provider items to display as the label. 
		 *  By default the list looks for a property named <code>label</code> 
		 *  on each item and displays it.
		 *  However, if the data objects do not contain a <code>label</code> 
		 *  property, you can set the <code>labelField</code> property to
		 *  use a different property in the data object. An example would be 
		 *  "FullName" when viewing a set of people names fetched from a database.
		 *
		 *  @default "label"
		 */
		public function get labelField():String
		{
		    return _labelField;
		}
		
		/**
		 *  @private
		 */
		public function set labelField(value:String):void
		{
		    _labelField = value;
		
		    invalidateDisplayList();
		
		    dispatchEvent(new Event("labelFieldChanged"));
		}
		
		private var dataProviderChanged:Boolean;
				
		protected var collection:ICollectionView;
		private var collectionIterator:IViewCursor;

		//----------------------------------
		//  dataProvider
		//----------------------------------
		
		[Bindable("collectionChange")]
		[Inspectable(category="Data", defaultValue="undefined")]
		
		/**
		 *  Set of data to be viewed.
		 *  This property lets you use most types of objects as data providers.
		 *  If you set the <code>dataProvider</code> property to an Array, 
		 *  it will be converted to an ArrayCollection. If you set the property to
		 *  an XML object, it will be converted into an XMLListCollection with
		 *  only one item. If you set the property to an XMLList, it will be 
		 *  converted to an XMLListCollection.  
		 *  If you set the property to an object that implements the 
		 *  IList or ICollectionView interface, the object will be used directly.
		 *
		 *  <p>As a consequence of the conversions, when you get the 
		 *  <code>dataProvider</code> property, it will always be
		 *  an ICollectionView, and therefore not necessarily be the type of object
		 *  you used to  you set the property.
		 *  This behavior is important to understand if you want to modify the data 
		 *  in the data provider: changes to the original data may not be detected, 
		 *  but changes to the ICollectionView object that you get back from the 
		 *  <code>dataProvider</code> property will be detected.</p>
		 * 
		 *  @default null
		 *  @see mx.collections.ICollectionView
		 */
		public function get dataProvider():Object
		{
		    // if we are running a data change effect, return the true
		    // data provider, rather than the ModifiedCollectionView wrapper.
		    //if (actualCollection)
		    //    return actualCollection; 
		        
		    return collection;
		}
		
		/**
		 *  @private
		 */
		public function set dataProvider(value:Object):void
		{
		    if (collection)
		    {
		        collection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
		    }
		
		    if (value is Array)
		    {
		        collection = new ArrayCollection(value as Array);
		    }
		    else if (value is ICollectionView)
		    {
		        collection = ICollectionView(value);
		    }
		    else if (value is IList)
		    {
		        collection = new ListCollectionView(IList(value));
		    }
		    else if (value is XMLList)
		    {
		        collection = new XMLListCollection(value as XMLList);
		    }
		    else if (value is XML)
		    {
		        var xl:XMLList = new XMLList();
		        xl += value;
		        collection = new XMLListCollection(xl);
		    }
		    else
		    {
		        // convert it to an array containing this one item
		        var tmp:Array = [];
		        if (value != null)
		            tmp.push(value);
		        collection = new ArrayCollection(tmp);
		    }
		    // get an iterator for the displaying rows.  The CollectionView's
		    // main iterator is left unchanged so folks can use old DataSelector
		    // methods if they want to
		    //iterator = collection.createCursor();
		    collectionIterator = collection.createCursor(); //IViewCursor(collection);
		
		    // trace("ListBase added change listener");
		    collection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
		
		    //clearSelectionData();
		
		    var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
		    event.kind = CollectionEventKind.RESET;
		    collectionChangeHandler(event);
		    dispatchEvent(event);
		
			dataProviderChanged = true;
		    //itemsNeedMeasurement = true;
		    invalidateProperties();
		    invalidateSize();
		    invalidateDisplayList();
		    dispatchEvent(new Event("dataProviderChanged"));
		}
		
		private var selectedButtonsChanged:int = -1;
		
		private var selectedItemsChanged:Boolean;
		private var _selectedItems:Array;
		[Bindable("selectedItemsChanged")]
		public function set selectedItems(value:Array):void
		{
			if (_selectedItems != value)
			{
				_selectedItems = value;
				selectedItemsChanged = true;
				invalidateProperties();
				dispatchEvent(new Event("selectedItemsChanged"));
			}
		}
		public function get selectedItems():Array
		{
			return _selectedItems;
		}
		
		protected function collectionChangeHandler(event:Event):void
    	{
			// na razie bez bawienia się w kolekcje, aktualizacja tylko wtedy, gdy zmieni się caly dataProvider.
    		//updateChildButtons();
    	}
		
		private function updateChildButtons():void
		{
			this.removeAllChildren();
			if (dataProvider && dataProvider is ICollectionView)
			{
				for each (var item:Object in dataProvider)
				{
					var button:Button = new Button();
					button.label = item[labelField];
					button.data = item;
					button.percentWidth = 100;
					button.percentHeight = 100;
					button.toggle = true;
					button.focusEnabled = false;
					button.addEventListener(MouseEvent.CLICK,buttonClickHandler,false,-1);
					addChild(button);
				}
			}
		}
		
		private function setSelection():void
		{
			var children:Array = this.getChildren();
			for each (var item:Object in selectedItems)
			{
				for (var i:int = 0; i < children.length; i++)
				{
					if (children[i] is Button)
					{
						var b:Button = children[i] as Button;
						if(b.data == item)
							b.selected = true;
						else
							b.selected = false;
					}
				}
			}
		}
		
		private function buttonClickHandler(event:MouseEvent):void
		{
			selectedButtonsChanged = this.getChildIndex(event.target as Button);
			invalidateProperties();
		}
		
		private function setSelectedItems(itemIndex:int):void
		{
			var children:Array = this.getChildren();
			var selected:Array = [];
			for (var i:int = 0; i < children.length; i++)
			{
				if (children[i] is Button)
				{
					var b:Button = children[i] as Button;
					if (b.selected/*  || (event.target == b && !b.selected) */)
						selected.push((children[i] as Button).data);
				}
			}
			_selectedItems = selected;
			
			dispatchEvent(new Event("selectedItemsChanged"));
			dispatchEvent(new ListEvent(ListEvent.CHANGE,false,false,-1,itemIndex,null,children[itemIndex]));
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (dataProviderChanged)
			{
				updateChildButtons();
				dataProviderChanged = false;
			}
			if (selectedItemsChanged)
			{
				setSelection();
				selectedItemsChanged = false;
			}
			if (selectedButtonsChanged > -1)
			{
				setSelectedItems(selectedButtonsChanged);
				selectedButtonsChanged = -1;
			}
		}
	}
}