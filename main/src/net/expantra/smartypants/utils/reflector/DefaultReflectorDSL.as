package net.expantra.smartypants.utils.reflector
{
	public class DefaultReflectorDSL implements ReflectorDSL
	{
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

		function DefaultReflectorDSL(typeDescription:XML)
		{
			this.typeDescription = typeDescription;
		}

        //--------------------------------------------------------------------------
        //
        //  Internals
        //
        //--------------------------------------------------------------------------
		
		private var typeDescription:XML;
		
		public function get functions():SPFunctionList
		{
			return new DefaultFunctionList(typeDescription);
		}
	}
}