package net.expantra.smartypants.dsl
{
    public interface InjectorRequestUnNamed extends InjectorRequestNamed
    {
        /**
         * Adds a name to the criteria
         */
        function named(name : String) : InjectorRequestNamed;
    }
}