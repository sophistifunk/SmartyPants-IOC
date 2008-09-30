package net.expantra.smartypants.impl
{
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;

	import net.expantra.smartypants.InjectorCriteria;
	import net.expantra.smartypants.InjectorRule;
	import net.expantra.smartypants.Provider;

    use namespace sp_internal;

	internal class RuleImpl implements InjectorRule
	{
        private var injector : InjectorImpl;
        private var name : String;
        private var clazz : Class;

        public function RuleImpl(injector : InjectorImpl)
        {
            this.injector = injector;
        }

        public function named(name : String) : InjectorRule
        {
            this.name = name;
            return this;
        }

        public function whenAskedFor(clazz : Class) : InjectorRule
        {
            this.clazz = clazz;
            return this;
        }

        /**
        * Sets a binding
        */
        public function useInstance(instance : Object) : void
        {
            injector.bindInstance(instance, new InjectorCriteria(clazz, name));
        }

        /**
        * Sets a class -> impl binding
        *
        * TODO : implement proper scopes a-la guice? Will we ever really need that though?
        */
        public function useClass(implementingClass : Class) : void
        {
            injector.bindImpl(implementingClass, new InjectorCriteria(clazz, name));
        }

        public function useProvider(provider : Provider) : void
        {
            injector.bindProvider(provider, new InjectorCriteria(clazz, name));
        }

        /**
        * Binds a property chain (acts as Flex data binding)
        */
        public function useBindableProperty(host : IEventDispatcher, chain : Object) : void
        {
            injector.bindPropertyChain(host, chain, new InjectorCriteria(clazz, name));
        }

        public function useSingletonOf(implementingClass : Class) : void
        {
            injector.bindProvider(new SingletonProvider(implementingClass), new InjectorCriteria(clazz, name));
        }

        public function useRuleFor(clazz : Class, named : String = null) : void
        {
            //First we get our intermediary provider, by way of which we achieve this magic :)
            var provider : Provider;

            if (named)
            {
                provider = injector.newRequest().forClass(clazz).named(named).getProvider();
            }
            else
            {
                provider = injector.newRequest().forClass(clazz).getProvider();
            }

            //Now bind this rule, to that new provider!
            injector.bindProvider(provider, new InjectorCriteria(clazz, name));
        }

        //--------------------------------------------------------------------------
        //
        //  Internal API - called by Injector to interrogate the request
        //
        //--------------------------------------------------------------------------

        sp_internal function get forClass() : Class
        {
            return clazz;
        }

        sp_internal function get forName() : String
        {
            if (name && name.length > 0)
                return name;

            return null;
        }

        public function toString() : String
        {
            return "InjectorRule { class = " + getQualifiedClassName(clazz) + ", name = \"" + name + "\" }";
        }


	}
}