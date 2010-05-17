package net.expantra.smartypants.utils.reflector
{

    internal class TypeDescMethodList extends SimpleSPMethodList implements SPMethodList
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function TypeDescMethodList(typeDescription:XML, owner:SPClass)
        {
            this.typeDescription = typeDescription;
            this.owner = owner;

            var node:XML;
            var parentMethod:SPMethod;

            for each (node in typeDescription.factory.method)
            {
                processNode(node);
            }

            // Bring in methods from super, if they're not overloaded in this class
            if (owner.superclass)
            {
                for each (parentMethod in owner.superclass.methods.asArray)
                {
                    addMethod(parentMethod);
                }
            }

            trace("Methods:", names);
        }

        //--------------------------------------------------------------------------
        //
        //  Internals
        //
        //--------------------------------------------------------------------------

        private var typeDescription:XML;
        private var owner:SPClass;

        //--------------------------------------------------------------------------
        //
        //  Internals
        //
        //--------------------------------------------------------------------------

        private function processNode(node:XML):void
        {
//            trace("process function node")
//            trace(node.toXMLString());
//            trace();

            addMethod(new SPMethodImpl(node, owner));
        }
    }
}