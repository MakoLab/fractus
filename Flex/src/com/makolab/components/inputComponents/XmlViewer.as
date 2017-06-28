package com.makolab.components.inputComponents
{
	import mx.controls.TextArea;

	public class XmlViewer extends TextArea
	{
		public function XmlViewer()
		{
			super();
		}
		private var _xmlSource:XML  ;
		
		public function set xmlSource(value:XML):void
		{	
			_xmlSource = value;
			this.htmlText = htmlDrzewoXML(value.toXMLString());
		}
		public function get xmlSource():XML
		{
			return _xmlSource;
		}
		
		public function htmlDrzewoXML(xmlS:String):String
		{	
			var xmlSHtml:String = xmlS;
			//generowanie tekstu ze znacznikami html
			xmlSHtml=xmlSHtml.replace(/(\r)/g,"");
			xmlSHtml=xmlSHtml.replace(/</g,"&lt;").replace(/>/g,"&gt;");
			xmlSHtml=xmlSHtml.replace(/=".*?"/g, setColor(true, "FF3366")+"$&"+setColor(false) );
			xmlSHtml=xmlSHtml.replace(/" *&gt;/g, setColor(true) + "\"/&gt;" + setColor(false) ).replace(/" *\/&gt;/g, setColor()+"\"/&gt;" + setColor(false));
			xmlSHtml=xmlSHtml.replace(/&lt;\//g, setColor(true) + "&lt;/" + setColor(false) ).replace(/\/&gt;/g, setColor()+"/&gt;" + setColor(false));
			xmlSHtml=xmlSHtml.replace(/&lt;/g, setColor(true) + "&lt;" + setColor(false) ).replace(/&gt;/g, setColor()+ "&gt;" + setColor(false));
			//return setColor(true, "003DF5") + xmlSHtml +setColor(false);
			return  xmlSHtml ;
		}	
		
		public function setColor(poczatek:Boolean=true, color:String = "0000ff", bold:Boolean = false):String
		{
			var returnStr:String ="";	
			if(poczatek==true){
				returnStr += "<font color=\"#"+color+"\">";
				if(bold) returnStr += "<b>";
			}
			else{
				if(bold) returnStr += "</b>";
				returnStr += "</font>"; 
			}
			return returnStr;
		}	
					
	}
}