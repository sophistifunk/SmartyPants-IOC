package net.expantra.smartypants.impl.live
{
    import flash.events.IEventDispatcher;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;

    import mx.binding.utils.ChangeWatcher;
    import mx.logging.ILogger;

    import net.expantra.smartypants.InjectorCriteria;
    import net.expantra.smartypants.Provider;
    import net.expantra.smartypants.impl.sp_internal;
    import net.expantra.smartypants.utils.LoggingUtil;
    import net.expantra.smartypants.utils.SingleFrameFlags;
    use namespace sp_internal;

    /**
    * Keeps track of Live injections. Deserves to be its own class, agnabbit.
    */
    public class LiveInjectionManager
    {
        private var log : ILogger = LoggingUtil.getDefaultLogger(this);

        //--------------------------------------------------------------------------
        //
        //  Internal state
        //
        //--------------------------------------------------------------------------

        /**
        * Maps hostEventDistpatcher -> Array of SourceEntry objects
        */
        private var sources : Dictionary;

        /**
        * Maps destinationObject -> Array of destinationEntry objects
        */
        private var destinations : Dictionary;

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function LiveInjectionManager()
        {
            sources = new Dictionary(true);
            destinations = new Dictionary(true);
        }

        //--------------------------------------------------------------------------
        //
        //  "public" API
        //
        //--------------------------------------------------------------------------

        sp_internal function registerSource(forClass : Class, forName : String, host : Object, chain : Object) : Provider
        {
            log.debug("Registering updating source for class " + getQualifiedClassName(forClass) + ", named \"" + forName + "\", host is \"" + host + "\"");

            //Magicvalue is our identifier for a class + name combo
            var magicValue : String = getMagicValue(forClass, forName);

            //Remove any existing source for this name/class pair
            removeSource(magicValue);

            //We don't do this inline, because we want the smallest scope closure possible to cut down on memory use while our listener is alive
            var notifierFunction : Function = Helpers.createNotifierFunction(magicValue, host);

            //Our chain watcher
            var watcher : ChangeWatcher = ChangeWatcher.watch(host, chain, notifierFunction);

            //Make sure we don't double-up on event listeners
            var dispatcher : IEventDispatcher = IEventDispatcher(host);

            var eventType : String = "updated_" + magicValue;

            dispatcher.removeEventListener(eventType, receiveUpdateEvent, false);
            dispatcher.addEventListener(eventType, receiveUpdateEvent, false, 0, true); //Use weak reference

            addSourceEntry(host, new SourceEntry(magicValue, watcher));

            return new LiveProvider(this.getCurrentValue, magicValue);
        }

        sp_internal function registerDestination(forClass : Class, forName : String, destination : Object, propertyKey : *) : void
        {
            log.debug("Registering destination for class " + getQualifiedClassName(forClass) +
                ", name =\"" + forName + "\" into \"" + propertyKey + "\" on a " + getQualifiedClassName(destination));

            var magicValue : String = getMagicValue(forClass, forName);

            addDestinationEntry(destination, new DestinationEntry(magicValue, propertyKey));
        }

        /**
        * Called by the injector whenever a rule is updated, so we can go through and notify anything that's listening for this key.
        * This allows live Injections to be notified of non-live normal injector rules, but only when the rule is created of course!
        */
        sp_internal function manualUpdateNotification(criteria : InjectorCriteria, provider : Provider) : void
        {
            updateTargets_work(getMagicValue(criteria.forClass, criteria.forName), null, provider);
        }

        /**
        * Gets the current value for a magicValue key - used only by LiveProvider!
        */
        sp_internal function getCurrentValue(magicValue : String) : *
        {
            var entry : SourceEntry = getSourceEntry(magicValue);
            return entry ? entry.changeWatcher.getValue() : null;
        }

        //--------------------------------------------------------------------------
        //
        //  Private API and helper functions
        //
        //--------------------------------------------------------------------------

        /**
        * Adds a source
        */
        private function addSourceEntry(host : Object, entry : SourceEntry) : void
        {
            if (!(host in sources))
                sources[host] = [];

            sources[host].push(entry);
        }

        /**
        * Adds a destination record
        */
        private function addDestinationEntry(destination : Object, entry : DestinationEntry) : void
        {
            if (!(destination in destinations))
                destinations[destination] = [];

            destinations[destination].push(entry);
        }

        /**
        * When passed a key, returns the SourceEntry should it exist
        */
        private function getSourceEntry(magicValue : String) : SourceEntry
        {
            var hostEntry : Array;
            var entry : SourceEntry;

            for each (hostEntry in sources)
            {
                for each (entry in hostEntry)
                {
                    if (entry.magicValue == magicValue)
                        return entry;
                }
            }

            return null;
        }

        /**
        * When passed a key, returns the host object
        */
        private function getHost(magicValue : String) : Object
        {
            var host : Object;
            var entry : SourceEntry;

            for (host in sources)
            {
                for each (entry in sources[host])
                {
                    if (entry.magicValue == magicValue)
                       return host;
                }
            }

            return null;
        }

        /**
        * Find any listeners for this key and re-set their injected field!
        *
        * If provider != null, newValue is ignored!
        */
        private function updateTargets_work(magicValue : String, newValue : *, provider : Provider = null) : void
        {
            log.debug("Updating listeners for " + magicValue);


            throw("UPDATE THIS CODE!");

            try
            {
                var destination : Object;
                var entry : DestinationEntry;

                for (destination in destinations)
                {
                    entry = destinations[destination];

                    if (entry.magicValue == magicValue)
                    {
                        destination[entry.propertyKey] = provider ? provider.getInstance() : newValue;
                    }
                }
            }
            catch (err : *)
            {
                log.error("When updating listeners, I got an error. Who knows how many got what they need?" + err);
            }
        }

        /**
        * Triggered by the anonymous handler function in changewatchers. This is how we avoid a hard reference from the source object to
        * this manager. That wouldn't be *too* bad, as it's the reverse we're really trying to avoid. But we're trying to be as loose
        * as possible with this class, so we might as well. It's only a 1-frame delay.
        */
        private function receiveUpdateEvent(event : LiveInjectionUpdatedEvent) : void
        {
            var magicValue : String = event["magicValue"];

            if (!magicValue || magicValue.length == 0)
                return;

            //Make sure we only bother about this once per frame. On a long chain,
            //or for something with many bindale events it may get called many
            //times per magicvalue per frame, and we don't wanna waste time!

            if (SingleFrameFlags.flagIsSet(magicValue))
                return;

            SingleFrameFlags.setFlag(magicValue);

            log.debug("Received notice that " + magicValue + " has updated!");

            var entry : SourceEntry = getSourceEntry(magicValue);

            if (entry)
                updateTargets_work(magicValue, entry.changeWatcher.getValue());
            else
                log.error("Weird. Couldn't find a source entry for magicValue \"" + magicValue + "\"");
        }

        //Todo - put more thought into this perhaps...
        private function getMagicValue(forClass : Class, forName : String) : String
        {
            var magic : String = getQualifiedClassName(forClass);

            if (forName && forName != "")
                magic += "." + forName;

            return magic.replace(/[^a-zA-Z0-9.]/g, "_");
        }

        private function removeSource(magicValue : String) : void
        {
            var entry : SourceEntry = getSourceEntry(magicValue);

            if (!entry)
                return;

            //Turn off the changewatcher. Removes all host -> watcher references.
            entry.changeWatcher.unwatch();

            var host : Object = getHost(magicValue);
            var dispatcher : IEventDispatcher = host as IEventDispatcher;

            if (dispatcher)
            {
                //Remove the "i'm updated" listener, since it was the watcher function that triggered it.
                dispatcher.removeEventListener("updated_" + magicValue, receiveUpdateEvent);
            }

            //Just make doubly sure we're throwing out all references we can think of :)
            entry.changeWatcher = null;
            entry.magicValue = null;

            delete sources[host];
        }
    }
}




