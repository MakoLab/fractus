package com.makolab.components.inputComponents
{
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

	public class GenericValidator extends Validator
	{
		public static const ERROR_WRONG_FORMAT:String = "wrongFormat";
		public static const ERROR_EMPTY_FIELD:String = "emptyField";
		
		// TODO: Etykiety
		/**
		 * Constructor.
		 */
		public function GenericValidator()
		{
			super();
			requiredFieldError = "Pole nie może być puste";
		}
		/**
		 * An XML with validation settings.
		 */
		public var validationRules:XML;
		/**
		 * Determines if a text field can be empty or not.
		 */
		 
		public var wrongFormatError:String = "Nieprawidłowy format wprowadzonej wartości";
		/**
		 * Validates a given string.
		 * Returns an error in an array if exists.
		 */
		 
		public function set regExp(value:String):void
		{
			if (value != null) validationRules = <validationRules><regExp>{value}</regExp></validationRules>;
		}
		public function get regExp():String
		{
			return validationRules ? String(validationRules.regExp) : null;
		}
		
		protected override function doValidation(value:Object):Array
		{
			var result:Array = [];
			var valStr:String = String(value);
			if (value == null || isNaN(value as Number)) valStr = null;
			if ((!validationRules || validationRules.allowEmpty != 1) && required && (valStr == null || valStr.replace(/\s/g, "").length == 0))
			{
				result.push(new ValidationResult(true, null, ERROR_EMPTY_FIELD, requiredFieldError));
			}
			else if (validationRules)
			{
				if (validationRules.regExp && !valStr.match(new RegExp(validationRules.regExp, "i")))
				{
					result.push(new ValidationResult(true, null, ERROR_WRONG_FORMAT, wrongFormatError));
				}
			}
			return result;
		}
	}
}