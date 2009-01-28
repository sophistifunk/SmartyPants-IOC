package net.expantra.smartypants.dsl
{
    import flash.events.IEventDispatcher;

    import net.expantra.smartypants.Provider;

    public interface InjectorRuleNamed
    {
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