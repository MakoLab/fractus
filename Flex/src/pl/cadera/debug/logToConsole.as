package pl.cadera.debug {
	import flash.external.ExternalInterface;
	
	/**
	 * Loguje komunikaty do domyslnej konsoli przegladarki (FF:console.log, Opera:opera.postError, IE:6TF0)
	 * @param	...args
	 */
	public function logToConsole(...args):void
	{
		trace(args.join(" "));
		if(ExternalInterface.available)
		{
			//Firebug
			var marshallState:Boolean = ExternalInterface.marshallExceptions;
			ExternalInterface.marshallExceptions = true;
			try //Firefox?
			{
				ExternalInterface.call("console.log", args.join(" "));
			}
			catch (e:Error) 
			{
				try //Opera?
				{
					ExternalInterface.call("opera.postError", args.join(" "));
				}
				catch (e:Error) //WTF?!
				{
					//ExternalInterface.call("alert", "Change your browser for Christ sake!");
				}
			}
			ExternalInterface.marshallExceptions = marshallState;
		}
	}
}