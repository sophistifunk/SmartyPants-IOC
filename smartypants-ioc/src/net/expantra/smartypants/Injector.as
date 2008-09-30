package net.expantra.smartypants
{
    public interface Injector
    {
        /**
         * Create an InjectorRequest.
         */
        function newRequest() : InjectorRequest;

        /**
         * Create an InjectorRule
         */
        function newRule() : InjectorRule;

        /**
         * Manually request injection into an object
         */
        function injectInto(targetInstance : Object) : void;
    }
}