package net.expantra.smartypants
{
    import net.expantra.smartypants.dsl.InjectorRequestRoot;
    import net.expantra.smartypants.dsl.InjectorRuleRoot;

    public interface Injector
    {
        /**
         * Create an InjectorRequest.
         */
        function newRequest() : InjectorRequestRoot;

        /**
         * Create an InjectorRule
         */
        function newRule() : InjectorRuleRoot;

        /**
         * Manually request injection into an object
         */
        function injectInto(targetInstance : Object) : void;
    }
}