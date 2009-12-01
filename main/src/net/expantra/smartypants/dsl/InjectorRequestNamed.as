package net.expantra.smartypants.dsl
{
    import net.expantra.smartypants.Provider;

    public interface InjectorRequestNamed
    {
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