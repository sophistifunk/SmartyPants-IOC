package net.expantra.smartypants.impl
{
	import flash.utils.getQualifiedClassName;

	import net.expantra.smartypants.Provider;

	/**
	 * A provider that always returns the same instance. Used internally in the Injector, and also useful for testing
	 */
	public class InstanceProvider implements Provider
	{
		private var instance : Object;

		public function InstanceProvider(instance : Object)
		{
			this.instance = instance;
		}

		public function getInstance() : *
		{
			return instance;
		}

        public function toString() : String
        {
        	return "Instance provider for a " + getQualifiedClassName(instance) + " (" + instance + ")";
        }
	}
}