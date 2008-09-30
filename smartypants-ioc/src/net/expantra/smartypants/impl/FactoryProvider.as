package net.expantra.smartypants.impl
{
	import net.expantra.smartypants.Provider;
	import net.expantra.smartypants.sp_injector;

    import net.expantra.smartypants.impl.sp_internal;

    use namespace sp_internal;

	public class FactoryProvider implements Provider
	{
        private var impl : Class;
        private var injector : InjectorImpl;

        [Inject]

        sp_injector function set _injector(value : InjectorImpl) : void
        {
            injector = value;
        }

        public function FactoryProvider(impl : Class)
        {
            this.impl = impl;
        }

        public function getInstance() : *
        {
            //Create
            var instance : Object = injector.newRequest().forClass(impl).getInstance();

            //Inject. Note that injector.instantiate will not inject fields, nor into member instances.
            injector.injectInto(instance);

            return instance;
        }

        public function toString() : String
        {
            return "FactoryProvider of " + impl;
        }
	}
}