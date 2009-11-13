package net.expantra.smartypants.utils
{
	import flash.utils.getQualifiedClassName;
    import net.expantra.smartypants.impl.sp_internal;
	import mx.logging.ILogger;

	public class SPLoggingUtil
	{
        private static const badLogNameChars : RegExp = /[\[\]\~\$\^\&\\(\)\{\}\+\?\/=`!@#%,:;'"<>\s]+/g;

		/**
		 * Replace this function from a [Mixin] if you want to hook my logging into your logging :)
		 * Should point to a Function of signatre <code>f(name : String) : ILogger</code>
		 */
        sp_internal static var getDefaultLoggerWorkFunction : Function = __getDefaultLoggerWork;

        /**
         * Logger lookup function. String->ILogger lookup is via sp_internal::getDefaultLoggerWorkFunction so you can
         * inject your own function from a [Mixin] (frame 1) function, so SP logs through your logging system.
         * @param instanceOrName instance of a class (or a class itself), or any String name.
         * @return ILogger
         */
        public static function getDefaultLogger(instanceOrName : Object) : ILogger
        {
        	var id : String = instanceOrName is String ? instanceOrName as String
        	                                           : getQualifiedClassName(instanceOrName);

        	//Sanity check.
        	id = id.replace(badLogNameChars, ".");

        	return sp_internal::getDefaultLoggerWorkFunction(id);
        }

        private static function __getDefaultLoggerWork(name : String) : ILogger
        {
            return new SimpleTraceLogger(name);
        }
	}
}