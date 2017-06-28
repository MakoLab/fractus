package com.makolab.components.inputComponents
{
	import mx.controls.TextInput;
	public class RegExpEditor  extends TextInput
{
        [Bindable]
        public var validateFunction : Function;
        [Bindable]
        public var regExpReplace :RegExp = /([^0-9]*)/gi;
        [Bindable]
        public var regExpReplaceTo : String = ""
        
        private var _dataObject:String;
           
        public function set dataObject(value:Object):void
        {
            _dataObject = validate(String(value));
            text =_dataObject;  
         }
        public function get dataObject():Object
        {
            _dataObject= validate(String(text));
            text = _dataObject;
            return _dataObject;
        }
       public function set value(val:Object):void
       {
       	
       }
       public function get value():Object
       {
       	return validate(text);
       }
        public override function set data(value:Object):void
        {	
        	super.data = value;
        	dataObject = DataObjectManager.getDataObject(data, listData);
        }
       
        public function RegExpEditor()
        {
            super();
            setStyle("textAlign", "right");
        }
        private function validate(value:String):String
		{
			if (validateFunction != null) return validateFunction(value);
			
			var s:String = value.toString();
			s = s.replace(regExpReplace, regExpReplaceTo);		

			return  s
		}
    }
}


