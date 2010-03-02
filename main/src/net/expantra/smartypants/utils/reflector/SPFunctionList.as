package net.expantra.smartypants.utils.reflector
{
	public interface SPFunctionList
	{
		function get names():Array;
		
		function get first():SPFunction;
		function get last():SPFunction;
		function get count():Number;
		function get all():Array;
	}
}