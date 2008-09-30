package net.expantra.smartypants
{
	public interface InjectorRequest
	{
        /**
         * Adds a name to the criteria
         */
        function named(name : String) : InjectorRequest;

        /**
        * Adds a target class to the criteria. Currently required
        */
        function forClass(clazz : Class) : InjectorRequest;

        /**
         * Returns actual instance
         */
        function getInstance() : *;

        /**
         * Returns a provider to be called later
         */
        function getProvider() : Provider;
	}
}