package net.expantra.smartypants.utils.reflector
{
	public class DefaultFunctionList implements SPFunctionList
	{
		 //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

		public function DefaultFunctionList(typeDescription:XML)
		{
			this.typeDescription = typeDescription;
		}

  //--------------------------------------------------------------------------
        //
        //  State
        //
        //--------------------------------------------------------------------------
		
		private var typeDescription:XML;
		
		  //--------------------------------------------------------------------------
        //
        //  Public API
        //
        //--------------------------------------------------------------------------

		public function get names():Array
		{
			return null;
		}
		
		public function get first():SPFunction
		{
			return null;
		}
		
		public function get last():SPFunction
		{
			return null;
		}
		
		public function get count():Number
		{
			return 0;
		}
		
		public function get all():Array
		{
			return null;
		}
		
	}
}