package net.expantra.smartypants.utils.reflector
{

    internal class SimpleSPMethodList implements SPMethodList
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function SimpleSPMethodList()
        {
        }

        //--------------------------------------------------------------------------
        //
        //  Internals
        //
        //--------------------------------------------------------------------------

        private var _names:Array = [];
        private var allMethods:Array = [];

        //--------------------------------------------------------------------------
        //
        //  Protected API
        //
        //--------------------------------------------------------------------------

        protected function addMethod(method:SPMethod):void
        {
            if (_names.indexOf(method.name) == -1)
            {
                _names.push(method.name);
                allMethods.push(method);
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Public API
        //
        //--------------------------------------------------------------------------

        public function get names():Array
        {
            return _names.concat();
        }

        public function get first():SPMethod
        {
            return null;
        }

        public function get last():SPMethod
        {
            return null;
        }

        public function get count():Number
        {
            return 0;
        }

        public function get asArray():Array
        {
            return allMethods.concat();
        }

        public function withAnnotationNamed(name:String):SPMethodList
        {
            var newList:SimpleSPMethodList = new SimpleSPMethodList();
            
            var method:SPMethod;
            
            return newList;
        }

		
    }
}