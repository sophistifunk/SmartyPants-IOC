package net.expantra.smartypants.impl
{
    import flash.utils.Dictionary;

    import mx.automation.codec.AssetPropertyCodec;

    public class InjectorRegistry
    {
        private static var idSeed : Number = 111;

        private static const allInjectors : Dictionary = new Dictionary(true);

        //Objects that have been injected into
        private static const allInjectees : Dictionary = new Dictionary(true);

        //Objects that have an associated injector (may not have been injected yet though)
        private static const allAssociatedObjects : Dictionary = new Dictionary(true);

        private static function getInjectorId(injector : InjectorImpl) : Number
        {
            for (var testee : * in allInjectors)
            {
                if (testee === injector)
                {
                    return allInjectors[testee];
                }
            }

            allInjectors[injector] = ++idSeed;

            return idSeed;
        }

        private static function getInjectorIdForInstance(instance : Object) : Number
        {
            if (instance in allAssociatedObjects)
                return allAssociatedObjects[instance];

            return instance in allInjectees ? allInjectees[instance] : -1;
        }

        /**
        * Register the injector <-> injectee relationship (and flag the injection as having begun)
        */
        sp_internal static function registerInjection(injector : InjectorImpl, injectee : Object) : void
        {
            allAssociatedObjects[injectee] = getInjectorId(injector);
            allInjectees[injectee] = getInjectorId(injector);
        }

        /**
        * Register the injector <-> associated objecy relationship (does not flag the injection as having begun)
        */
        sp_internal static function registerAssociation(injector : InjectorImpl, injectee : Object) : void
        {
            allAssociatedObjects[injectee] = getInjectorId(injector);
        }

        /**
        * Has the instance been injected into?
        */
        sp_internal static function alreadyInjected(instance : Object) : Boolean
        {
            return instance in allInjectees;
        }

        /**
        * Has the instance been associated with an injector?
        */
        sp_internal static function hasInjector(instance : Object) : Boolean
        {
            return (instance in allInjectees) || (instance in allAssociatedObjects);
        }

        /**
        * Lookup the injector instance for a specific object (if it has been injected into)
        *
        * @return The InjectorImpl responsible, or null if not found.
        */
        sp_internal static function getInjectorFor(instance : Object) : InjectorImpl
        {
            var id : Number = getInjectorIdForInstance(instance);

            if (id > 0)
            {
                for (var testee : * in allInjectors)
                {
                    if (allInjectors[testee] == id)
                    {
                        return testee;
                    }
                }
            }

            return null;
        }

        /**
         * Notify the registry about the creation of an injector
         * @param instance
         */
        sp_internal static function injectorCreated(instance : InjectorImpl) : void
        {
            getInjectorId(instance);
        }
    }
}