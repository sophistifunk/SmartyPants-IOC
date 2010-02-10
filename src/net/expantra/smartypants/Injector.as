package net.expantra.smartypants
{
    import net.expantra.smartypants.dsl.InjectorRequestRoot;
    import net.expantra.smartypants.dsl.InjectorRuleRoot;

    public interface Injector
    {
        /**
         * Create an InjectorRequest.
         */
        function newRequest(injectee:Object):InjectorRequestRoot;

        /**
         * Create an InjectorRule
         */
        function newRule():InjectorRuleRoot;

        /**
         * Manually request injection into an object
         */
        function injectInto(targetInstance:Object):void;

        /**
         * Does the injector currently have an explicit rule for this key?
         * @param clazz
         * @param named
         * @return true if a matching explicit rule is found, otherwise false.
         */
        function hasExplicitRuleFor(clazz:Class, named:String = null):Boolean;
    }
}