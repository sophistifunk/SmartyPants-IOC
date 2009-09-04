package net.expantra.smartypants.impl.live
{
	import flash.events.Event;

	internal class LiveInjectionUpdatedEvent extends Event
	{
		private var _magicValue : String;

		public function LiveInjectionUpdatedEvent(type:String, magicValue : String)
		{
			super(type);
			_magicValue = magicValue;
		}

		public function get magicValue() : String
		{
			return _magicValue;
		}
	}
}