package net.expantra.smartypants.utils
{
	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;

	public class LoggingUtil
	{
        private static const badLogNameChars : RegExp = /[\[\]\~\$\^\&\\(\)\{\}\+\?\/=`!@#%,:;'"<>\s]+/g;

        private static var setupCompleted : Boolean = false;
        private static var normalTarget : TraceTarget;

		/**
		 * Replace this function from a [Mixin] if you want to hook my logging into your logging :)
		 */
        public static var getDefaultLogger : Function = _getDefaultLogger;

        private static function _getDefaultLogger(forInstance : Object) : ILogger
        {
        	var id : String = getQualifiedClassName(forInstance);
        	id = id.replace(badLogNameChars, ".");
        	return setup(Log.getLogger(id));
        }

        private static function setup(log : ILogger) : ILogger
        {
        	if (!setupCompleted)
        	{
        		normalTarget = new TraceTarget();
		        normalTarget.level = LogEventLevel.ALL;
		        normalTarget.includeCategory = false;
		        normalTarget.includeDate = false;
		        normalTarget.includeLevel = true;
		        normalTarget.includeTime = false;
		        normalTarget.filters = ["net.expantra.*"];
        		setupCompleted = true;
        	}

        	normalTarget.addLogger(log);
        	return log;
        }


	}
}