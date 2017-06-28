package com.makolab.components.inputComponents
{
	import mx.controls.TextInput;
	/**
	 * <code>NIPInput</code> lets a user to enter a NIP.
	 * A user is allowed to enter only alphanumerical characters and "-" unless you change the <code>restrict</code> property.
	 * <code>NIPInput</code> doesn't support the validation.
	 * @see com.makolab.components.inputComponents.NIPEditor
	 */
	public class NIPInput extends TextInput
	{
		public function NIPInput()
		{
			super();
			this.restrict = "a-zA-Z0-9\\-";
		}
		/**
		 * @inheritDoc
		 */
		override public function set restrict(value:String):void
		{
			super.restrict = value;
		}
		
		/**
		 * Contains a NIP without any special characters.
		 */
		public function get strippedNip():String
		{
			var result:String = "";
			var expression:RegExp = /\w/;
			for(var i:int=0;i<this.text.length;i++){
				if(this.text.charAt(i).match(expression))result += this.text.charAt(i);
			}
			return result;
		}
	}
}