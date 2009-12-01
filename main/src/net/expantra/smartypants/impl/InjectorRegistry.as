package net.expantra.smartypants.impl
{
    import flash.utils.Dictionary;

    public class InjectorRegistry
    {
        private static const ID_SEED_SEED : Number = 123;
        private static var idSeed : Number = ID_SEED_SEED;

        private const allInjectors : Dictionary = new Dictionary(true);

        //Objects that have been injected into
        private const allInjectees : Dictionary = new Dictionary(true);

        //Objects that have an associated injector (may not have been injected yet though)
        private const allAssociatedObjects : Dictionary = new Dictionary(true);

        private function getInjectorId(injector : InjectorImpl) : Number
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

        private function getInjectorIdForInstance(instance : Object) : Number
        {
            if (instance in allAssociatedObjects)
                return allAssociatedObjects[instance];

            return instance in allInjectees ? allInjectees[instance] : -1;
        }

        /**
         * @private
         * Register the injector <-> injectee relationship (and flag the injection as having begun)
         */
        sp_internal function registerInjection(injector : InjectorImpl, injectee : Object) : void
        {
            allAssociatedObjects[injectee] = getInjectorId(injector);
            allInjectees[injectee] = getInjectorId(injector);
        }

        /**
         * @private
         * Register the injector <-> associated object relationship (does not flag the injection as having begun)
         */
        sp_internal function registerAssociation(injector : InjectorImpl, injectee : Object) : void
        {
            allAssociatedObjects[injectee] = getInjectorId(injector);
        }

        /**
         * @private
         * Has the instance been injected into?
         */
        sp_internal function alreadyInjected(instance : Object) : Boolean
        {
            return instance in allInjectees;
        }

        /**
         * @private
         * Has the instance been associated with an injector?
         */
        sp_internal function hasInjector(instance : Object) : Boolean
        {
            return (instance in allInjectees) || (instance in allAssociatedObjects);
        }

        /**
         * @private
         * Lookup the injector instance for a specific object (if it has been injected into)
         *
         * @return The InjectorImpl responsible, or null if not found.
         */
        sp_internal function getInjectorFor(instance : Object) : InjectorImpl
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
         * @private
         * Notify the registry about the creation of an injector
         * @param instance
         */
        sp_internal function injectorCreated(instance : InjectorImpl) : void
        {
            getInjectorId(instance);
        }

        /**
         * @private
         * Produces some debugging information, used by the test suite.
         * @return
         *
         */
        sp_internal function get status() : String
        {
            var injectorCount : Number = 0;
            var injecteeCount : Number = 0;
            var assosciateCount : Number = 0;

            var minId : Number = Number.MAX_VALUE;
            var maxId : Number = Number.MIN_VALUE;

            for (var obj : * in allInjectors)
            {
                injectorCount++;
                minId = Math.min(minId, allInjectors[obj]);
                maxId = Math.max(maxId, allInjectors[obj]);
            }

            for (obj in allInjectees)
            {
                injecteeCount++;
                minId = Math.min(minId, allInjectees[obj]);
                maxId = Math.max(maxId, allInjectees[obj]);
            }

            for (obj in allAssociatedObjects)
            {
                assosciateCount++;
                minId = Math.min(minId, allAssociatedObjects[obj]);
                maxId = Math.max(maxId, allAssociatedObjects[obj]);
            }

            if (injectorCount == 0)
                return "This registry counts 0 injectors";

            if (injectorCount == 1)
                return "This registry counts 1 injector with " + injecteeCount + " injectees, and "
                   + assosciateCount + " associated Objects. Injector Id is " + minId

            return "This registry counts " + injectorCount + " injectors, " + injecteeCount + " injectees, and "
                   + assosciateCount + " associated Objects. Injector Ids range from " + minId + " to " + maxId;
        }

        /**
         * How many injectors exist?
         */
        sp_internal function get numberOfInjectors() : Number
        {
            var injectorCount : Number = 0;

            for (var obj : * in allInjectors)
            {
                injectorCount++;
            }

            return injectorCount;
        }
    }
}