package net.expantra.smartypants.dsl
{
    public interface InjectorRequestRoot
    {
        /**
        * Adds a target class to the criteria. Currently required
        */
        function forClass(clazz : Class) : InjectorRequestUnNamed;
    }
}