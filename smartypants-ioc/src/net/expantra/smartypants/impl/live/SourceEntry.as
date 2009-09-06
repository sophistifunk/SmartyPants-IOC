package net.expantra.smartypants.impl.live
{
	import mx.binding.utils.ChangeWatcher;

    internal class SourceEntry
    {
        public var magicValue : String;
        public var changeWatcher : ChangeWatcher;

        public function SourceEntry(mv : String, cw : ChangeWatcher)
        {
            magicValue = mv;
            changeWatcher = cw;
        }
    }
}