package net.expantra.smartypants.impl
{
    import flash.utils.Dictionary;

    public class InjectorRegistry
    {
        private static var idSeed : Number = 111;

        private static const allInjectors : Dictionary = new Dictionary(true);
        private static const allInjectees : Dictionary = new Dictionary(true);

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
            return instance in allInjectees ? allInjectees[instance] : -1;
        }

        /**
        * Register the injector <-> injectee relationship
        */
        sp_internal static function registerInjection(injector : InjectorImpl, injectee : Object) : void
        {
            allInjectees[injectee] = getInjectorId(injector);
        }

        /**
        * Has the instance been injected into?
        */
        sp_internal static function alreadyInjected(instance : Object) : Boolean
        {
        	return instance in allInjectees;
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
    }
}