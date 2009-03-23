package net.expantra.smartypants
{
	import flash.display.DisplayObject;

	import mx.core.Application;

	import net.expantra.smartypants.dsl.InjectorRequestUnNamed;
	import net.expantra.smartypants.dsl.InjectorRuleUnNamed;
	import net.expantra.smartypants.impl.InjectorImpl;
	import net.expantra.smartypants.impl.InjectorRegistry;
	import net.expantra.smartypants.impl.sp_internal;

    use namespace sp_internal;

    /**
    * The main entry-point to the API
    */
	public class SmartyPants
	{
        //--------------------------------------------------------------------------
        //
        //  Public API
        //
        //--------------------------------------------------------------------------

        /**
         * Looks for an injector for a specified instance
         *
         * @return the Injector that SmartyPants thinks should handle this object, or null if none was found
         */
        public static function locateInjectorFor(instance : Object) : Injector
        {
            if (singleInjectorMode)
                return singleInjector;

            //See if we've already injected this object
            if (injectorRegistry.hasInjector(instance))
                return injectorRegistry.getInjectorFor(instance);

            //If not, we'll next try travelling up the display tree (to make it easier to inject into MXML objects)
            if (instance is DisplayObject && instance.parent)
                return locateInjectorFor(instance.parent);

            return null;
        }

        /**
         * Looks for an injector for a specified instance
         *
         * @return the Injector that SmartyPants thinks should handle this object, or throws an error if none found (fail-fast)
         */
        public static function getInjectorFor(instance : Object) : Injector
        {
            var result : Injector = locateInjectorFor(instance);

            if (!result)
                throw new Error("Could not find an injector for " + instance);

            return result;
        }

        /**
         * Looks for an injector for a specified instance, or will create one if a suitable injector can't be found
         */
        public static function getOrCreateInjectorFor(instance : Object) : Injector
        {
            var injector : Injector = locateInjectorFor(instance);

            if (!injector)
            {
                injector = new InjectorImpl();
                injectorRegistry.registerAssociation(injector as InjectorImpl, instance); //Ties the injector to the instance without requiring actual injection
            }

            return injector;
        }

        /**
         * Looks up or creates an injector, then calls injector.injectInto(). Good for injecting into components on CREATION_COMPLETE
         */
        public static function injectInto(instance : Object) : void
        {
        	getOrCreateInjectorFor(instance).injectInto(instance);
        }

        //--------------------------------------------------------------------------
        //
        //  Single-injector public API
        //
        //--------------------------------------------------------------------------

        private static var _singleInjectorMode : Boolean = true;
        private static var _singleInjector : Injector;

        /**
         * Controls the single-injector mode. Single-injector mode is the default behaviour.
         */
        public static function set singleInjectorMode(value : Boolean) : void
        {
            if (value == _singleInjectorMode)
                return;

            //We can't go back to single-injector mode if there's multiple injectors referenced at the moment!
            if (value == true && injectorRegistry.numberOfInjectors > 1)
            {
                throw new Error("Cannot return to single-injector mode if multiple injectors exist: " + injectorRegistry.status);
            }

            _singleInjectorMode = value;
        }

        public static function get singleInjectorMode() : Boolean
        {
            return _singleInjectorMode;
        }

        private static function get singleInjector() : Injector
        {
            if (!singleInjectorMode)
                return null;

            if (!_singleInjector)
                _singleInjector = new InjectorImpl();

            return _singleInjector;
        }

        /**
         * Register a new rule. Requires SmartyPants to be in single-injector mode (the default behaviour)
         * @param requestedClass
         * @return
         */
        public static function whenAskedFor(requestedClass : Class) : InjectorRuleUnNamed
        {
            if (!singleInjector)
                throw new Error("SmartyPants.whenAskedFor() requires SmartyPants-IOC to be in single-injector mode");

            return singleInjector.newRule().whenAskedFor(requestedClass);
        }

        /**
         * Make a request. Requires SmartyPants to be in single-injector mode (the default behaviour)
         * @param requestedClass
         * @return
         */
        public static function forClass(requestedClass : Class) : InjectorRequestUnNamed
        {
            if (!singleInjector)
                throw new Error("SmartyPants.forClass() requires SmartyPants-IOC to be in single-injector mode");

            return singleInjector.newRequest().forClass(requestedClass);
        }

        //--------------------------------------------------------------------------
        //
        //  Internal API
        //
        //--------------------------------------------------------------------------

        private static var _registry : InjectorRegistry;

        sp_internal static function get injectorRegistry() : InjectorRegistry
        {
            if (!_registry)
                _registry = new InjectorRegistry();

            return _registry;
        }

        sp_internal static function get status() : String
        {
        	return injectorRegistry.status;
        }
	}
}