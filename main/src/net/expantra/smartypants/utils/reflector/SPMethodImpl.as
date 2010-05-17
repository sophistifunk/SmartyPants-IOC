package net.expantra.smartypants.utils.reflector
{

    internal class SPMethodImpl implements SPMethod
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function SPMethodImpl(methodDescription:XML, owner:SPClass)
        {
            _owner = owner;

            _name = methodDescription.attribute("name");
        }

        //--------------------------------------------------------------------------
        //
        //  Internals
        //
        //--------------------------------------------------------------------------

        private var _name:String;
        private var _owner:SPClass;

        //--------------------------------------------------------------------------
        //
        //  API
        //
        //--------------------------------------------------------------------------

        public function get name():String
        {
            return _name;
        }

    }
}