package net.expantra.smartypants
{
	import flash.events.IEventDispatcher;

    public interface InjectorRule
    {
        /**
         * Adds a name to the criteria.
         *
         * @parameter name A name to add to the criteria. Null (or not called) means "when no name is specified in the request",
         * "*" means "when any or no name is specified in the request". You may have named rules, with a fallback rule named "*".
         */
        function named(name : String) : InjectorRule;

        /**
        * Adds a target class to the criteria. Currently required
        */
        function whenAskedFor(clazz : Class) : InjectorRule;

        /**
         * Binds an implementor
         */
        function useClass(implementingClass : Class) : void;

        /**
         * Binds an instance (as Singleton)
         */
        function useInstance(instance : Object) : void;

        /**
         * Binds an implementor as a (lazy) Singleton
         */
        function useSingletonOf(implementingClass : Class) : void;

        /**
         * A shortcut: whenAskedFor(Foo).useSingleton() is the same as whenAskedFor(Foo).useSingletonOf(Foo)
         */
        function useSingleton() : void;

        /**
         * Binds to an existing rule
         */
        function useRuleFor(clazz : Class, named : String = null) : void;

        /**
        * Binds a provider
        */
        function useProvider(provider : Provider) : void;

        /**
        * Binds a property chain (acts as Flex data binding)
        */
        function useBindableProperty(host : IEventDispatcher, chain : Object) : void;
    }
}