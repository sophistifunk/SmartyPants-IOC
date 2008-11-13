package net.expantra.smartypants
{
	import flash.utils.getQualifiedClassName;

    /**
     * Simply a type-safe package for rule / request criteria
     */
    public class InjectorCriteria
    {
        public var forClass : Class;
        public var forName : String;

        public function InjectorCriteria(forClass : Class, forName : String = null)
        {
            this.forClass = forClass;
            this.forName = forName;
        }

        /**
        * True if the forName specified is a wildcard. NB: False for no name specified
        */
        public function get wildcard() : Boolean
        {
        	return forName == "*";
        }

        public function toString() : String
        {
        	return (forClass != null ? getQualifiedClassName(forClass) : "unspecified class") +
        	       (forName != null ? " named \"" + forName + "\"" : " with no name");
        }

        /**
         * Returns true if the request criteria satisfy the rule criteria, wildcard is used
         */
        public static function match(rule : InjectorCriteria, request : InjectorCriteria) : Boolean
        {
            return rule.forClass === request.forClass ? (rule.forName == request.forName || rule.wildcard ) : false;
        }

        /**
         * Returns true if the request criteria exactly satisfy the rule criteria, wildcards not used
         */
        public static function exactMatch(rule : InjectorCriteria, request : InjectorCriteria) : Boolean
        {
            return rule.forClass === request.forClass && rule.forName == request.forName;
        }


    }
}