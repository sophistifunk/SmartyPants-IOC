package net.expantra.smartypants.impl
{
    import flash.events.IEventDispatcher;
    import flash.utils.getDefinitionByName;

    import mx.collections.XMLListCollection;
    import mx.logging.ILogger;

    import net.expantra.smartypants.Injector;
    import net.expantra.smartypants.InjectorCriteria;
    import net.expantra.smartypants.InjectorRequest;
    import net.expantra.smartypants.InjectorRule;
    import net.expantra.smartypants.Provider;
    import net.expantra.smartypants.impl.live.LiveInjectionManager;
    import net.expantra.smartypants.utils.LoggingUtil;
    import net.expantra.smartypants.utils.Reflection;

    use namespace sp_internal;

    public class InjectorImpl implements Injector
    {
        private var log : ILogger = LoggingUtil.getDefaultLogger(this);

        //--------------------------------------------------------------------------
        //
        //  Internal State
        //
        //--------------------------------------------------------------------------

        //----------------------------------
        //  Bindings
        //----------------------------------

        private var criteriaList : Array = [];
        private var providerList : Array = [];

        //----------------------------------
        //  Manages our live injections
        //----------------------------------

        private var _liveInjectionManager : LiveInjectionManager;

        //--------------------------------------------------------------------------
        //
        //  Public API
        //
        //--------------------------------------------------------------------------

        /**
         * Create an InjectorRequest.
         */
        public function newRequest() : InjectorRequest
        {
            return new RequestImpl(this);
        }

        /**
         * Create an InjectorRule
         */
        public function newRule() : InjectorRule
        {
            return new RuleImpl(this);
        }

        /**
         * Manually request injection into an object
         */
        public function injectInto(targetInstance : Object) : void
        {
            injectIntoWork(targetInstance);
        }

        /**
        * Does actual injection
        */
        private function injectIntoWork(targetInstance : Object) : void
        {
            if (targetInstance == null || targetInstance is Date || Reflection.isSimpleType(targetInstance))
                return;

            if (InjectorRegistry.alreadyInjected(targetInstance))
                return;

            InjectorRegistry.registerInjection(this, targetInstance);

            //Regular injection
            injectValuesIntoFields(targetInstance);

            //Find any [InjectInto] decorations to inject into non-injected values.
            injectIntoExistingMembers(targetInstance);
        }

        /**
        * Set fields
        */
        private function injectValuesIntoFields(targetInstance : Object) : void
        {
            var writeableProperties : XMLListCollection = Reflection.getWriteablePropertyDescriptions(targetInstance);
            var injectionPointList : XMLListCollection = Reflection.filterMembersByMetadataName(writeableProperties, "Inject");

            log.debug("The instance " + targetInstance + " has " + injectionPointList.length + " injection points.");

            var injectionPoint : XML;
            for each(injectionPoint in injectionPointList)
            {
                //Gather some intel...

                var injectionMetadata : XML = injectionPoint..metadata.(name == "Inject")[0];

                var fieldName : * = Reflection.getPropertyName(injectionPoint);

                var fieldType : String = injectionPoint.@type;
                if (fieldType == "*")
                    fieldType = "Object";

                var injectionType : String = injectionMetadata.child("arg").(attribute("key") == "type").attribute("value").toString();
                if (injectionType == "*")
                    injectionType = "Object";

                var injectionName : String = injectionMetadata.child("arg").(attribute("key") == "name").attribute("value").toString();

                var providerInjection : Boolean = Reflection.classExtendsOrImplements(fieldType, Provider);

                var liveInjection : Boolean = injectionMetadata.child("arg").(attribute("key") == "" && attribute("value") == "live").length() > 0;

                //Clean up some string fields. Might not be necessary.

                if (injectionName == "")
                    injectionName = null;

                if (injectionType == "")
                    injectionType = null;

                log.debug("Attempting to inject into " + fieldName + ", which is a " + fieldType
                          + ". injectionType = " + injectionType + ", injectionName = " + injectionName);

                //Get a reference to the injected class type

                var actualClassToInject : Class;

                try
                {
                    actualClassToInject = Class(getDefinitionByName(injectionType ? injectionType : fieldType));
                }
                catch (e : Error)
                {
                    throw new Error("Could not lookup the class " + (injectionType ? injectionType : fieldType)
                                    + ", due to " + e + "\n" + e.getStackTrace());
                }

                var criteria : InjectorCriteria = new InjectorCriteria(actualClassToInject, injectionName);

                //Lookup our value

                var valueToInject : Object = null;

                if (liveInjection)
                {
                    log.debug("This is a live injection");

                    liveInjectionManager.registerDestination(actualClassToInject, injectionName, targetInstance, fieldName);

                    var provider : Provider = lookupProviderForCriteria(criteria);

                    if (provider)
                    {
                        valueToInject = provider.getInstance();
                    }
                    else
                    {
                        log.debug("But there's no provider yet.");
                    }

                }
                else if (providerInjection)
                {
                    log.debug("This is a provider injection");

                    valueToInject = newRequest().forClass(actualClassToInject).named(injectionName).getProvider();
                }
                else
                {
                    log.debug("This is a standard injection");

                    valueToInject = fulfilRequest(criteria);
                }

                //Set the field.

                log.debug("valueToInject = " + valueToInject);

                targetInstance[fieldName] = valueToInject;
            }
        }

        /**
        * Interrogate metadata, and call injectInto() on anything decorated as requesting ig
        */
        private function injectIntoExistingMembers(parentInstance : Object) : void
        {
            var readableProperties : XMLListCollection = Reflection.getReadablePropertyDescriptions(parentInstance);

            //Simple [InjectInto] for instances

            var injectIntoTargets : XMLListCollection = Reflection.filterMembersByMetadataName(readableProperties, "InjectInto");

            var fieldDescription : XML;

            for each (fieldDescription in injectIntoTargets)
            {
                var fieldName : * = Reflection.getPropertyName(fieldDescription);

                log.debug("Found [InjectInto] on field " + fieldName);

                injectIntoWork(parentInstance[fieldName]);
            }

            //And [InjentIntoContents] for arrays, lists, dictionaries, etc

            injectIntoTargets = Reflection.filterMembersByMetadataName(readableProperties, "InjectIntoContents");

            for each (fieldDescription in injectIntoTargets)
            {
                fieldName = Reflection.getPropertyName(fieldDescription);

                log.debug("Found [InjectIntoContents] on field " + fieldName);

                for each (var target : Object in parentInstance[fieldName])
                {
                	injectIntoWork(target);
                }
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Internal API - called by rules to create bindings
        //
        //--------------------------------------------------------------------------

        /**
        * Action a request for an instance
        */
        sp_internal function fulfilRequest(request : InjectorCriteria) : Object
        {
            //Do we have a rule that matches our criteria?
            var provider : Provider = lookupProviderForCriteria(request);

            if (provider)
                return provider.getInstance();

            //No rule matching our request. If there's a name in the request, then we have a fault!
            if (request.forName)
                throw new Error("Could not fulfil the request " + request);

            //We have a valid unbound request for an instance. Attempt to create it!

            var instance : Object = null;

            try
            {
                instance = instantiate(request.forClass);
                injectInto(instance);
            }
            catch (e : Error)
            {
                throw new Error("Could not fulfil the request " + request + " due to " + e + "\n" + e.getStackTrace());
            }

            return instance;
        }

        /**
        * Looks for a matching rule, returns the bound provider, or null if none found
        */
        sp_internal function lookupProviderForCriteria(requestCriteria : InjectorCriteria) : Provider
        {
            function matchingCriteriaFilter(rule : InjectorCriteria) : Boolean
            {
                return InjectorCriteria.match(rule, requestCriteria);
            }

            var matchingCriteria : Array = criteriaList.filter(matchingCriteriaFilter);

            //Search for an exact match first, as they're higher precedence than wildcard

            switch(matchingCriteria.length)
            {
                case 0: //No match
                    return null;

                case 1: //Only one match
                    return matchingCriteria[0];

                case 2: //Two matches. Check if #1 is exact, if not return #0
                    return InjectorCriteria.exactMatch(matchingCriteria[1], requestCriteria) ? matchingCriteria[1]
                                                                                             : matchingCriteria[0];

                default: //Should never happen!
                    throw new Error("Internal error! We should only ever have zero, one, or two matching rules!");
            }
        }

        /**
        * Bind a rule to a provider
        */
        sp_internal function bindProvider(provider : Provider, ruleCriteria : InjectorCriteria) : void
        {
            var existingIndex : Number = findExactMatchIndex(ruleCriteria);

            //Make note of this binding...

            //Updating an existing binding?
            if (existingIndex >= 0)
            {
                //Jah, so replace that record
                criteriaList[existingIndex] = ruleCriteria;
                providerList[existingIndex] = provider;
            }
            else
            {
                //Nah, chuck 'em at the end
                criteriaList.push(ruleCriteria);
                providerList.push(provider);
            }

            //... done.

            //Now, make sure we process the provider. It probably needs to know about the injector

            injectInto(provider);

            //If we're managing any live injection points, tell them about our
            //new rule, in case somebody's listening for it.

            if (_liveInjectionManager)
            {
                _liveInjectionManager.manualUpdateNotification(ruleCriteria, provider);
            }
        }

        /**
        * Bind a rule to an instance (akin to Guice' singleton scope)
        */
        sp_internal function bindInstance(instance : Object, criteria : InjectorCriteria) : void
        {
            bindProvider(new InstanceProvider(instance), criteria);

            //Visit the newly bound instance and inject it with whatever it needs
            injectInto(instance);
        }

        /**
        * Bind a rule to a bindable property chain, the source-half of live injection
        */
        sp_internal function bindPropertyChain(host : IEventDispatcher, chain : Object, criteria : InjectorCriteria) : void
        {
            //Notify our manager (and get the provider)
            var provider : Provider = liveInjectionManager.registerSource(criteria.forClass, criteria.forName, host, chain);

            //Register a normal provider (for non-live injections of the current value of any live rule)
            bindProvider(provider, criteria);
        }

        /**
        * Bind to an implementing class (or subclass, if the criteria class is a proper class rather than an interface)
        */
        sp_internal function bindImpl(implementingClass : Class, criteria : InjectorCriteria) : void
        {
            bindProvider(new FactoryProvider(implementingClass), criteria);
        }

        /**
        * Performs actual instantiation - This is where we'll be doing our constructor injection soon!
        */
        sp_internal function instantiate(clazz : Class) : *
        {
            return new clazz();
        }

        //--------------------------------------------------------------------------
        //
        //  Private API. Helpers and utils we don't think need to be exposed :)
        //
        //--------------------------------------------------------------------------

        /**
        * Looks for an exact name + class criteria match
        *
        * @return an index into the internal stores, or -1 if not found.
        */
        private function findExactMatchIndex(criteria : InjectorCriteria) : Number
        {
            var testee : InjectorCriteria;
            var i : Number;

            for (i = 0; i < criteriaList.length; i++)
            {
                testee = criteriaList[i];

                if (testee.forClass == criteria.forClass && testee.forName == criteria.forName)
                {
                    return i;
                }
            }

            return -1;
        }

        private function get liveInjectionManager() : LiveInjectionManager
        {
            if (!_liveInjectionManager)
                _liveInjectionManager = new LiveInjectionManager();

            return _liveInjectionManager;
        }


    }
}