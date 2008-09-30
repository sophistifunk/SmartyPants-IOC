package net.expantra.smartypants.impl
{
	import net.expantra.smartypants.Provider;

    use namespace sp_internal;

	public class SingletonProvider implements Provider
	{
        private var impl : Class;
        private var injector : InjectorImpl;
        private var instance : *;

        [Inject]
        sp_internal function set _injector(value : InjectorImpl) : void
        {
            injector = value;
        }

        public function SingletonProvider(impl : Class)
        {
            this.impl = impl;
        }

        public function getInstance() : *
        {
            if (!instance)
            {
                instance = injector.newRequest().forClass(impl).getInstance();
            }

            return instance;
        }

        public function toString() : String
        {
            return "SingletonProvider of " + impl + ", instance = " + instance;
        }


	}
}