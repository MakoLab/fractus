package com.makolab.components.inputComponents
{
	public interface IFormBuilderComponent
	{
		
		/**
		 * Perform component content validation.
		 *  
		 * @return null if no error was found or Error messages, separated with \n. 
		 * 
		 */
		function validate():Object;
		
		function commitChanges():void;
		
		function reset():void;
	}
}