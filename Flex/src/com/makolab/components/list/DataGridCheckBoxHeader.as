package com.makolab.components.list
{
	import mx.controls.CheckBox;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.Application;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.ILayoutManagerClient;
	import mx.styles.IStyleClient;

	/**
	 *  Dispatched when the <code>data</code> property changes.
	 *
	 *  <p>When you use a component as an item renderer,
	 *  the <code>data</code> property contains the data to display.
	 *  You can listen for this event and update the component
	 *  when the <code>data</code> property changes.</p>
	 * 
	 *  @eventType mx.events.FlexEvent.DATA_CHANGE
	 */
	[Event(name="dataChange", type="mx.events.FlexEvent")]
	
	public class DataGridCheckBoxHeader extends CheckBox
								  implements IDataRenderer,
								  IDropInListItemRenderer, ILayoutManagerClient,
								  IListItemRenderer, IStyleClient
	{
		public function DataGridCheckBoxHeader()
		{
			super();
		}

		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
	
	    /**
	     *  @private
	     */
		private var invalidatePropertiesFlag:Boolean = false;
		
	    /**
	     *  @private
	     */
		private var invalidateSizeFlag:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
	
	    //----------------------------------
	    //  data
	    //----------------------------------
	
	    /**
	     *  @private
	     */
	    private var _data:Object;
	
		[Bindable("dataChange")]
	
	    /**
		 *  The implementation of the <code>data</code> property as 
		 *  defined by the IDataRenderer interface.
		 *
		 *  The value is ignored.  Only the listData property is used.
		 *  @see mx.core.IDataRenderer
	     */
	    override public function get data():Object
	    {
	        return _data;
	    }
	    
		/**
		 *  @private
		 */
		override public function set data(value:Object):void
		{
			_data = value;
	
			dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
	
	    //----------------------------------
	    //  listData
	    //----------------------------------
	
		/**
		 *  @private
		 */
		private var _listData:DataGridListData;
	
		[Bindable("dataChange")]
		
		/**
		 *  The implementation of the <code>listData</code> property as 
		 *  defined by the IDropInListItemRenderer interface.
		 *  The text of the renderer is set to the <code>label</code>
		 *  property of the listData.
		 *
		 *  @see mx.controls.listClasses.IDropInListItemRenderer
		 */
		override public function get listData():BaseListData
		{
			return _listData;
		}
	
		/**
		 *  @private
		 */
		override public function set listData(value:BaseListData):void
		{
			_listData = DataGridListData(value);
			if (nestLevel && !invalidatePropertiesFlag)
			{
				/* Application.application.l layoutManager.invalidateProperties(this);
				invalidatePropertiesFlag = true;
				UIComponent.layoutManager.invalidateSize(this);
				invalidateSizeFlag = true; */
			}
		}
	}
}