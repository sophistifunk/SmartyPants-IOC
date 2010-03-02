package net.expantra.smartypants.dsl
{
    import flash.events.IEventDispatcher;

    import net.expantra.smartypants.Provider;

    public interface InjectorRuleNamed
    {
        /**
         * Binds an implementing class. Shorcut for useRuleFor(implementingClass, null)
         */
        function useClass(implementingClass:Class):void;

        /**
         * Binds an implementing class. Unlike useClass(), createInstanceOf() does not go through any more rules, and [Singleton] annotation
         * will be ignored.
         */
        function createInstanceOf(implementingClass:Class):void;

        /**
         * Binds an existing value
         * <b>NB:</b> As of 2.x, the value you specify will not be injected into or modified in any way by
         * SmartyPants-IOC. To mimic the old behaviour, call <code>Injector.injectInto(value)</code> before
         * using value in the rule.
         */
        function useValue(value:Object):void;

        /**
         * Binds an implementor as a (lazy) Singleton
         */
        function useSingletonOf(implementingClass:Class):void;

        /**
         * A shortcut: whenAskedFor(Foo).useSingleton() is the same as whenAskedFor(Foo).useSingletonOf(Foo)
         */
        function useSingleton():void;

        /**
         * Binds to an existing rule
         */
        function useRuleFor(clazz:Class, named:String = null):void;

        /**
         * Binds a provider
         */
        function useProvider(provider:Provider):void;

        /**
         * Binds a property chain (acts as Flex data binding)
         */
        function useBindableProperty(host:IEventDispatcher, chain:Object):void;

        /**
         * Revert to default behaviour - will remove any existing rule that matches these criteria, for this injector
         * context and its children only.
         */
        function defaultBehaviour():void;
    }
}