package net.expantra.smartypants.dsl
{
    import flash.events.IEventDispatcher;

    import net.expantra.smartypants.Provider;

    public interface InjectorRuleNamed
    {
        /**
         * Binds an implementing class. If class is decorated with [Singleton] it will be bound as a singleton, otherwise will be instantiated for every request.
         */
        function useClass(implementingClass : Class) : void;

        [Deprecated(replacement="useValue")]
        /**
         * Deprecated, use "useValue" instead
         * @private - deprecated
         */
        function useInstance(instance : Object) : void;

        /**
         * Binds a value
         */
        function useValue(value : Object) : void;

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