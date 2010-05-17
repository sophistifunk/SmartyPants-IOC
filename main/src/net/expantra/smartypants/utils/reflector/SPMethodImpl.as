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
            
            var node:XML;
            
            for each (node in methodDescription.metadata)
            {
            	allMetaData.push(String(node.attribute("name")));
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Internals
        //
        //--------------------------------------------------------------------------

        private var _name:String;
        private var _owner:SPClass;
        private var allMetaData:Array = [];

        //--------------------------------------------------------------------------
        //
        //  API
        //
        //--------------------------------------------------------------------------

        public function get name():String
        {
            return _name;
        }
        
        public function hasAnnotationNamed(name:String):Boolean
        {
        	return allMetaData.indexOf(name) >= 0;
        }

    }
}