package net.expantra.smartypants.utils.reflector
{
	public interface SPMethodList
	{
		function get names():Array;
		function get first():SPMethod;
		function get last():SPMethod;
		function get count():Number;
		function get asArray():Array;
		
		function withAnnotationNamed(name:String):SPMethodList;
	}
}