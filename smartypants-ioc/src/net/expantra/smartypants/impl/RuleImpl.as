package net.expantra.smartypants.impl
{
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;

	import net.expantra.smartypants.InjectorCriteria;
	import net.expantra.smartypants.Provider;
	import net.expantra.smartypants.dsl.InjectorRuleNamed;
	import net.expantra.smartypants.dsl.InjectorRuleRoot;
	import net.expantra.smartypants.dsl.InjectorRuleUnNamed;

    use namespace sp_internal;

	internal class RuleImpl implements InjectorRuleUnNamed, InjectorRuleRoot
	{
        private var injector : InjectorImpl;
        private var name : String;
        private var clazz : Class;

        public function RuleImpl(injector : InjectorImpl)
        {
            this.injector = injector;
        }

        public function named(name : String) : InjectorRuleNamed
        {
            this.name = name;
            return this;
        }

        public function whenAskedFor(clazz : Class) : InjectorRuleUnNamed
        {
            this.clazz = clazz;
            return this;
        }

        [Deprecated(replacement="useValue")]
        /**
        * Sets a value binding
        * @private - deprecated
        */
        public function useInstance(instance : Object) : void
        {
            useValue(instance);
        }

        /**
        * Sets a value binding
        */
        public function useValue(value : Object) : void
        {
            injector.bindInstance(value, new InjectorCriteria(clazz, name));
        }

        /**
        * Sets a class -> impl binding
        */
        public function useClass(implementingClass : Class) : void
        {
            useRuleFor(implementingClass);
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

        public function useSingleton() : void
        {
        	useSingletonOf(clazz);
        }

        public function useRuleFor(existingRuleClass : Class, existingRuleName : String = null) : void
        {
            //First we get our intermediary provider, by way of which we achieve this magic :)
            var provider : Provider;

            if (existingRuleName)
            {
                provider = injector.newRequest().forClass(existingRuleClass).named(existingRuleName).getProvider();
            }
            else
            {
                provider = injector.newRequest().forClass(existingRuleClass).getProvider();
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