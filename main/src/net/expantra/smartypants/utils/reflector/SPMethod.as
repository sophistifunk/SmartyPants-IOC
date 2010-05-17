package net.expantra.smartypants.utils.reflector
{
	public interface SPMethod
	{
		function get name():String;
		function hasAnnotationNamed(name:String):Boolean;
	}
}