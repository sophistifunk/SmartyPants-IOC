package net.expantra.smartypants.impl
{
	import flash.utils.getQualifiedClassName;

	import net.expantra.smartypants.InjectorCriteria;
	import net.expantra.smartypants.Provider;
	import net.expantra.smartypants.dsl.InjectorRequestNamed;
	import net.expantra.smartypants.dsl.InjectorRequestRoot;
	import net.expantra.smartypants.dsl.InjectorRequestUnNamed;

    use namespace sp_internal;

	internal class RequestImpl implements InjectorRequestRoot, InjectorRequestUnNamed
	{
        //--------------------------------------------------------------------------
        //
        //  Internal State
        //
        //--------------------------------------------------------------------------

        private var injector : InjectorImpl;
        private var _forClass : Class;
        private var _forName : String;

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function RequestImpl(injector : InjectorImpl)
        {
            this.injector = injector;
        }

        //--------------------------------------------------------------------------
        //
        //  Public API
        //
        //--------------------------------------------------------------------------

        public function forClass(clazz : Class) : InjectorRequestUnNamed
        {
            _forClass = clazz;
            return this;
        }

        /**
        * Include a name in the query
        */
        public function named(name : String) : InjectorRequestNamed
        {
            _forName = name;
            return this;
        }

        /**
        * Request an instance (now)
        */
        public function getInstance() : *
        {
            return injector.fulfilRequest(new InjectorCriteria(this._forClass, this._forName));
        }

        /**
        * Request provider (to get instance(s) later)
        */
        public function getProvider() : Provider
        {
            return new SimpleProvider(this);
        }

        public function toString() : String
        {
            return "InjectorRequest { class = " + getQualifiedClassName(_forClass) + ", name = \"" + _forName + "\" }";
        }


	}
}