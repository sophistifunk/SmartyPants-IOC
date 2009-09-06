package net.expantra.smartypants.impl
{
    import net.expantra.smartypants.Injector;
    import net.expantra.smartypants.Provider;

    internal class RuleProvider implements Provider
    {
        [Inject]
        /** @private */ public var injector : Injector;

        private var clazz : Class;
        private var name : String;
        private var injectee : Object;

        public function RuleProvider(forClass : Class, name : String, injectee : Object )
        {
            this.clazz = forClass;
            this.name = name;
            this.injectee = injectee;
        }

        public function getInstance() : *
        {
            if (name)
                return injector.newRequest(injectee).forClass(clazz).named(name).getInstance();

            return injector.newRequest(injectee).forClass(clazz).getInstance();
        }
    }
}