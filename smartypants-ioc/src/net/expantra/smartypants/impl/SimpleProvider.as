package net.expantra.smartypants.impl
{
	import net.expantra.smartypants.InjectorRequest;
	import net.expantra.smartypants.Provider;

	public class SimpleProvider implements Provider
	{
        private var request : InjectorRequest;

        public function SimpleProvider(request : InjectorRequest)
        {
            this.request = request;
        }

        public function getInstance() : *
        {
            return request.getInstance();
        }

        public function toString() : String
        {
            return "SimpleProvider for " + request;
        }
	}
}