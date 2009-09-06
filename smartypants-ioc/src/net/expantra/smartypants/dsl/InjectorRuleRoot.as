package net.expantra.smartypants.dsl
{
    public interface InjectorRuleRoot
    {
        /**
        * Adds a target class to the criteria. Currently required
        */
        function whenAskedFor(clazz : Class) : InjectorRuleUnNamed;
    }
}