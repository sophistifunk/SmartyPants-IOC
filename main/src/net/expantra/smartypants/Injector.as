package net.expantra.smartypants
{
    import net.expantra.smartypants.dsl.InjectorRequestRoot;
    import net.expantra.smartypants.dsl.InjectorRuleRoot;

    public interface Injector
    {
        /**
         * Create an InjectorRequest, which must be completed with getInstance() or 
         * getProvider() to take effect.
         */
        function newRequest(injectee:Object):InjectorRequestRoot;

        /**
         * Create an InjectorRule, which must be completed with one of the useXXXX() 
         * methods to take effect.
         */
        function newRule():InjectorRuleRoot;

        /**
         * Manually request injection into an object, for bootstrapping and other edge cases 
         * where you want injection but can't rely on the injector to create your instance.
         */
        function injectInto(targetInstance:Object):void;

        /**
         * Does the injector currently have an explicit rule for this key?
         * @param clazz a class
         * @param named the optional "name" part of the key
         * @return true if a matching explicit rule is found, otherwise false.
         */
        function hasExplicitRuleFor(clazz:Class, named:String = null):Boolean;
    }
}