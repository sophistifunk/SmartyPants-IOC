package net.expantra.smartypants.utils.reflector
{
	import flash.utils.getDefinitionByName;
	
	internal class SPClassImpl implements SPClass
	{
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

		function SPClassImpl(typeDescription:XML, reflector:Reflector)
		{
			this.typeDescription = typeDescription;
			this.reflector = reflector;
			
//			trace(typeDescription.toXMLString());
			
			lookupSuperClass();
			
			_functions = new TypeDescMethodList(typeDescription, this);
		}

        //--------------------------------------------------------------------------
        //
        //  Internals
        //
        //--------------------------------------------------------------------------
		
		private var reflector:Reflector;
		private var _superclass:SPClass;
		private var typeDescription:XML;
		
		private var _functions:TypeDescMethodList;
		
		private function lookupSuperClass():void
		{
			var extendsList:XMLList = typeDescription.factory.extendsClass
			if (extendsList.length() > 0)
			{
				var superName:String = extendsList[extendsList.length() - 1].attribute("type");
				_superclass = reflector.forClass(Class(getDefinitionByName(superName)));
			}
		}
		
		//--------------------------------------------------------------------------
        //
        //  API
        //
        //--------------------------------------------------------------------------
		
		public function get methods():SPMethodList
		{
			return _functions;
		}
		
		public function get superclass():SPClass
		{
			return _superclass;
		}
	}
}