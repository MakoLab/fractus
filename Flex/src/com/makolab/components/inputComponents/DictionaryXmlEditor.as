package com.makolab.components.inputComponents
{
	import com.makolab.fractus.model.ModelLocator;
	
	import flash.events.Event;
	
	import mx.containers.VBox;
	import mx.controls.Label;

	public class DictionaryXmlEditor extends VBox
	{
		private var _data:Object;
		public var error:Boolean;
		/**
		 * Lets you pass a value to the editor.
		 * @see #data
		 */
		[Bindable]
		public var dataObject:Object;
		
		public var dictionaryType:String;
		/**
		 * If set to "Edit" the editor fields will be filled out with assigned to <code>dataObject</code> values. If set to "Add" you creates a blank editor instance.
		 */
		public var action:String;
		public static const EDIT:String = "Edit";
		public static const ADD:String = "Add";
		
		private var _valId:int=0;
		[Bindable]
		public var dictConfig:XML = ModelLocator.getInstance().configManager.getXML("dictionaries.configuration");
		/**
		 * Constructor.
		 */
		public function DictionaryEditor()	
		{
			
		}
		/**
		 * Lets you pass a value to the editor.
		 * the <code>data</code> property doesn't change while editing values in editor. The value of <code>data</code> is copied to <code>dataObject</code>. To read modified values use <code>dataObject</code> property.
		 * @see #dataObject
		 */
		[Bindable]
		override public function set data(value:Object):void
		{
			_data = value;
			if(value)	{
				dataObject = value;
				createNewEditor();
			}			
		}
		
		override public function get data():Object	
		{
			return _data;
		}
		private function createNewEditor():void
		{
			this.removeAllChildren();
			
			var lab:Label;
			var ta:ExTextArea;
			var vb:VBox=new VBox();
			lab = new Label();
			lab.width = 100;
			lab.text="XML:";
		
			ta=new ExTextArea();
			ta.width=580;
			ta.height=400;
			ta.text=String(data) ;
			ta.addEventListener(Event.CHANGE,changeHandler);										
			
			vb.addChild(lab);
			vb.addChild(ta);
			this.addChild(vb);
		}
			private function changeHandler(event:Event, addValidator:Boolean = false):void	
		{
				try{
					this.dataObject = XML(event.currentTarget.text);
				}
				catch(e:TypeError)
				{
					this.dataObject = event.currentTarget.text;
				}
					//this.dataObject = (event.currentTarget.text)//XML
			
		}
	}
}