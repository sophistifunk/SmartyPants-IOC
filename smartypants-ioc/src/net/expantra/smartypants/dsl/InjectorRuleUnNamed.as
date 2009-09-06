package net.expantra.smartypants.dsl
{
    public interface InjectorRuleUnNamed extends InjectorRuleNamed
    {
        /**
         * Adds a name to the criteria.
         *
         * @parameter name A name to add to the criteria. Null (or not called) means "when no name is specified in the request",
         * "*" means "when any or no name is specified in the request". You may have named rules, with a fallback rule named "*".
         */
        function named(name : String) : InjectorRuleNamed;
    }
}