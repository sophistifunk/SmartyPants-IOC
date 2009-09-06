package net.expantra.smartypants.impl
{
	import net.expantra.smartypants.Provider;
	import net.expantra.smartypants.dsl.InjectorRequestNamed;

	public class SimpleProvider implements Provider
	{
        private var request : InjectorRequestNamed;

        public function SimpleProvider(request : InjectorRequestNamed)
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