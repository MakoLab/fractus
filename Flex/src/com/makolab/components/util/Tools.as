package com.makolab.components.util
{
	import flash.xml.XMLNode;
	
	import mx.controls.DateField;
	
	public class Tools
	{
		public function Tools()
		{
		}
			
		public static const millisecondsPerDay:int = 1000 * 60 * 60 * 24;
		
		/* 
		zwraca dla podanych dat ich różnicę w:
			-milisekundach
			-sekundach
			-minutach
			-godzinach
			-dniach
			-miesiącach (podloga)
			-latach (podloga)
			oraz date bedaca wynikiem roznicy
		w postaci obiektu.
		Jeśli pierwsza data jest późniejsza wartości są ujemne.
		Nie testowałem dokładnie czy miesiące się dobrze liczą.
		tomek
		*/
		public static function datesDifference(date1:Date,date2:Date):Object
		{
			var timeDifference:Number = date1.getTime() - date2.getTime();
			var differenceDate:Date = new Date(timeDifference);
			var object:Object = {};
			object.date = differenceDate;
			object.milliseconds = timeDifference;
			object.seconds = timeDifference / 1000;
			object.minutes = timeDifference / (1000 * 60);
			object.hours = timeDifference / (1000 * 60 * 60);
			object.days = timeDifference / (1000 * 60 * 60 * 24);
			object.years = (differenceDate.fullYear < 1970) ? -(1969 - differenceDate.fullYear) : differenceDate.fullYear - 1970;
			var month12diff:int = (differenceDate.fullYear < 1970) ? -(11 - differenceDate.getMonth()) : differenceDate.getMonth();
			object.months = month12diff + (object.years * 12); 
			
			return object;
		} 

		public static function dateToString(date:Date):String
		{
			return DateField.dateToString(date, "YYYY-MM-DD");
		}
		
		public static function dateToIso(date:Date):String
		{
			return date ? dateToString(date) + 'T' + date.toString().replace(/.*(\d\d:\d\d:\d\d).*/, '$1') : null;
		}
		
		public static function isoToDate(dateStr:String):Date
		{
			if (dateStr == null) return null;
			dateStr = dateStr.replace(/-/g, "/");
			dateStr = dateStr.replace("T", " ");
			dateStr = dateStr.replace("Z", " GMT-0000");
			dateStr = dateStr.replace(/\.\d+$/, '');
			return new Date(Date.parse(dateStr));
		}
		
		public static function round(value:Number, precision:int = 0):Number
		{
			var pow:Number = Math.pow(10, precision);
			return Math.round(pow * Number(value.toPrecision(12))) / pow;
		}
		
		public static function trim(s:String):String
		{
			return s.replace(/^\s*(.*?)\s*$/, "$1");
		}
		
		public static function getSortFunction(dataField:String, dataType:String = 'number'):Function
		{
			var f:Function = function(arg1:Object, arg2:Object):int
			{
				/* 
				if (Number(arg1[dataField]) > Number(arg2[dataField])) return 1;
				else if(Number(arg1[dataField]) < Number(arg2[dataField])) return -1;
				else return 0;
				 */
				var val1:Number = parseFloat(arg1[dataField]), val2:Number = parseFloat(arg2[dataField]);
				// porownanie z NaN zawsze da false wiec dla optymalizacji najpierw rozwazamy przypadki typowe
				if (val1 > val2) return 1; 
				else if (val1 < val2) return -1;
				else if (val1 == val2 || isNaN(val1) == isNaN(val2)) return 0;
				else if (isNaN(val1)) return (val2 < 0 ? 1 : -1);
				else if (isNaN(val2)) return (val1 < 0 ? -1 : 1);
				else return 0;
			}
			return f;
		}
		
		public static function replaceParameters(template:String, parameters:Object):String
		{
			var result:String = template;
			for (var key:String in parameters)
			{
				result = result.replace(new RegExp('{' + key + '}', 'i'), parameters[key]);
			}
			return result;
		}
		
		public static function parseBoolean(o:Object):Boolean
		{
			if (!o) return false;								// null, pusty string, 0, false
			if (o == 'false') return false;						// 'false'
			var num:Number = parseFloat(String(o));
			if (!isNaN(num) && !num) return false;				// '0'
			if (o is XMLList && o.length() == 0) return false;	// pusta lista wartości
			return true;
		}
		
		public static function htmlDecode(s:String):String 
        {                                 
            s=s.split("&amp;").join("&");                 
            s=s.split("&quot;").join("\""); 
            s=s.split("&apos;").join("'");                  
            s=s.split("&lt;").join("<");          
            s=s.split("&gt;").join(">");             
            return s; 
        }
         
        public static function htmlEncode(s:String):String 
        {                                 
            s=s.split("&").join("&amp;");
			s=s.split("\"").join("&quot;");
			s=s.split("'").join("&apos;");
			s=s.split("<").join("&lt;");
			s=s.split(">").join("&gt;");
			return s;
        } 

		public static function isGuid(s:String):Boolean
		{
			return Boolean(s.match(/^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/));
		}
		
		public static function xmlDeleteNodes(child:Object):void
		{
			if (child is XML) xmlDeleteNode(XML(child));
			else if (child is XMLList)
			{
				for each (var x:XML in XMLList(child)) xmlDeleteNode(x);
			}
		}
		
		private static function xmlDeleteNode(node:XML):void
		{
			if (node.parent() === undefined) return;
			delete node.parent().*[node.childIndex()];
		}
		
		public static function setXMLValue(xmlReference:XML, path:String, value:Object, attributeValue:String = null, emptyValues:Array = null, newNodeTemplate:XML = null):XML
		{
			if (!xmlReference || !path) return null;
			if (!emptyValues) emptyValues = [null,""];
			var pathArray:Array = path.split(".");
			var isEmpty:Boolean;
			var i:int = 0;
			if (emptyValues)
				for (i = 0; i < emptyValues.length; i++)
					if (value == emptyValues[i] || (isNaN(Number(value)) && isNaN(Number(emptyValues[i])))) { isEmpty = true; break; };
					
			var xmlNode:XML = getElement(xmlReference,pathArray,attributeValue);
			xmlNode.* = (isEmpty ? "" : value);
			removeEmpties(xmlReference,pathArray);
			
			function getElement(root:XML, pathArray:Array, attributeValue:String):XML
			{
				var node:XML = root;
				if (pathArray.length > 0)
				{
					if (attributeValue && pathArray.length > 1 && String(pathArray[1]).substr(0,1) == "@")
					{
						var xmlList:XMLList = new XMLList();
						if ((root[pathArray[0]] as XMLList).length() > 0) xmlList = root[pathArray[0]].(valueOf()[pathArray[1]] == attributeValue);
						if (xmlList.length() > 0) 
						{
							node = xmlList[0];
						}else{
							var newXML:XML = XML(newNode);
							if (newNodeTemplate)
							{
								newXML = newNodeTemplate.copy();
								newXML[pathArray[1]] = attributeValue;
							}else{
								var newNode:XMLNode = new XMLNode(1,"");
								newNode.nodeName = pathArray[0];
								newNode.attributes[String(pathArray[1]).substr(1)] = attributeValue;
								newXML = XML(newNode);
							}
							root.appendChild(newXML);
							node = newXML;
						}
					}
					else
					{
						var newPathArray:Array = [];
						for (var j:int = 1; j < pathArray.length; j++) newPathArray.push(pathArray[j]);
						if (root[pathArray[0]].length() == 0)
						{
							root[pathArray[0]] = "";
						}
						node = getElement(root[pathArray[0]][0],newPathArray,attributeValue);
					}
				}
				return node;
			}
			
			function removeEmpties(root:XML, pathArray:Array):XML
			{
				if (root && pathArray && pathArray.length > 0)
				{
					var newPathArray:Array = [];
					for (var j:int = 1; j < pathArray.length; j++) newPathArray.push(pathArray[j]);
					
					for (var i:int = root[pathArray[0]].length() - 1; i >= 0;  i--)
					{
						var val:String = XML(removeEmpties(root[pathArray[0]][i],newPathArray)).toString();
						if (val == "") delete root[pathArray[0]][i];
					}
				}
				return root;
			}
			
			if (!isEmpty) return xmlNode;
			return null;
		}

		public static function CSVtoArray(csv:String, delimiter:String = ";"):Array
		{
			var inQuotes:Boolean = false;
			var field:String = "";
			var finalData:Array = new Array();
			finalData.push(new Array());
			var line:int = 0;
			//iterate each character
			for(var i:int = 0; i < csv.length; i++) {
			var c:String = csv.charAt(i);
			var n:String = csv.charAt(i+1);
			var ad:Boolean = false;  
			//if the quote repeats, add the character
			if(inQuotes && c == "\"" && n == "\"") {
				field += c; 
			}
			//if we are inside quotes, add the character
			if(inQuotes && c != "\"") {
				field += c;	
			}	 
			//if we are not inside quotes...
			if(!inQuotes && c != "\"") {
				//if this character is a comma, start a new field
				if(c == delimiter) {
					finalData[line].push(field);
					field = "";
				//if this character is a newline, start a new line
				} else if(c == "\n") {
					finalData[line].push(field);
					finalData.push(new Array());
					line++;
					field = "";
				//if this is not leading or trailing white space, add the character
				} else if(c != " " && c != "\t" && c != "\r") {
					field += c;
				}
			}	  
			//if this is a quote, switch inQuotes
			if(c == "\"") {
				inQuotes = !inQuotes;
			}
		}
		//add last line
		finalData[line].push(field);
		
		/* oryginalny fragment - usuwa ostatni wiersz jesli jego ilosc kolumn jest rozna od pierwszego wiersza - nie nadaje sie 
				//if the last line does not have the same length as the first, remove it
				if(finalData[line].length < finalData[0].length) finalData.pop();
		*/
		
		if((finalData[line].length == 1) && (finalData[line] as Array)[0].length == 0) finalData.pop();		
		//return the resulting array
		
		return finalData;
	}
	
	public static function sortComparePL(obj1:String, obj2:String, caseSensitive:Boolean = false):int {
		if (obj1 == null && obj2 == null) return 0;
		else if (obj1 == null) return -1;
		else if (obj2 == null) return 1;
		var order:String;
		if (caseSensitive) order = "0123456789AaĄąBbCcĆćDdEeĘęFfGgHhIiJjKkLlŁłMmNnŃńOoÓóPpQqRrSsŚśTtUuVvWwXxYyZzŹźŻż";
		else order = "0123456789aąbcćdeęfghijklłmnńoópqrsśtuvwxyzźż";
		var minLen:int
		var posA:int;
		var posB:int;
		if (! isNaN(Number(obj1)) && ! isNaN(Number(obj2))) {
			if (Number(obj1) < Number(obj2)) return -1;
			else if (Number(obj1) > Number(obj2)) return 1;
			else return 0;
		}else{
			minLen = obj1.length < obj2.length ? obj1.length : obj2.length;
			var i:int = 0;
			for(; i < minLen; i++) {
				if (caseSensitive) posA = order.indexOf(obj1.slice(i, i + 1));
				else posA = order.indexOf(obj1.slice(i, i + 1).toLowerCase());
				if (caseSensitive) posB = order.indexOf(obj2.slice(i, i + 1));
				else posB = order.indexOf(obj2.slice(i, i + 1).toLowerCase());
				if (posA < posB) return -1;
				else if(posA > posB) return 1;
			}//end for
			if (obj1.length < obj2.length) return -1;
			else if(obj1.length > obj2.length) return 1;
			else return 0;
		}//end if
	}
		
		
	}
}
