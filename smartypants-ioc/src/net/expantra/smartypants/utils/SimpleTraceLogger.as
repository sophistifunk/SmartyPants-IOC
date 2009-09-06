package net.expantra.smartypants.utils
{
    import flash.events.EventDispatcher;

    import mx.logging.ILogger;
    import mx.logging.LogEventLevel;

    internal class SimpleTraceLogger extends EventDispatcher implements ILogger
    {
        private var name : String;

        private static var levelNames : Array;

        public function SimpleTraceLogger(name : String)
        {
            this.name = name;

            if (!levelNames)
            {
                levelNames = [];
                levelNames[LogEventLevel.DEBUG] = "Debug";
                levelNames[LogEventLevel.ERROR] = "Error";
                levelNames[LogEventLevel.FATAL] = "Fatal";
                levelNames[LogEventLevel.INFO] = "Info";
                levelNames[LogEventLevel.WARN] = "Warn";
            }
        }

        public function get category() : String
        {
            return name;
        }

        public function log(level : int, message : String, ...parameters) : void
        {
            logWork(level, message, parameters);
        }

        private function logWork(level : int, message : String, parameters : Array) : void
        {
            //Build message

            var i : Number = 0;

            message = "[" + levelNames[level] + " / " + category + " ] " + message;

            for (i = 0; i < parameters.length; i++)
            {
                message = message.replace("{" + i + "}", parameters[i]);
            }

            //Splat
            trace(message);
        }

        public function debug(message : String, ...parameters) : void
        {
            logWork(LogEventLevel.DEBUG, message, parameters);
        }

        public function error(message : String, ...parameters) : void
        {
            logWork(LogEventLevel.ERROR, message, parameters);
        }

        public function fatal(message : String, ...parameters) : void
        {
            logWork(LogEventLevel.FATAL, message, parameters);
        }

        public function info(message : String, ...parameters) : void
        {
            logWork(LogEventLevel.INFO, message, parameters);
        }

        public function warn(message : String, ...parameters) : void
        {
            logWork(LogEventLevel.WARN, message, parameters);
        }
    }
}