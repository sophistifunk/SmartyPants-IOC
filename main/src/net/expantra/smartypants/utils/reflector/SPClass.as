package net.expantra.smartypants.utils.reflector
{
	public interface SPClass
	{
		function get methods():SPMethodList;
//		function get name():String;
		function get superclass():SPClass;
	}
}