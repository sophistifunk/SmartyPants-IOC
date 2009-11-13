package net.expantra.smartypants.impl.live
{
	import flash.events.IEventDispatcher;

	internal class Helpers
	{
	    /**
	    * Creates an anonymous function (using the smallest function closure we can manage) that
	    * lets the manager know about changes without a strong reference to our instance.
	    *
	    * The hoops through which we jump in order to (probably in vain) attempt not to leak references ;-)
	    */
	    public static function createNotifierFunction(magicValue : String, host : Object) : Function
	    {
	        return function(ignored : *) : void
	            {
	                var tmp : LiveInjectionUpdatedEvent =
	                   new LiveInjectionUpdatedEvent("updated_" + magicValue, magicValue);

	                IEventDispatcher(host).dispatchEvent(tmp);
	            };
	    }
	}
}