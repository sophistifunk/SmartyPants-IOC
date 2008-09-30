package net.expantra.smartypants.impl.live
{
    internal class DestinationEntry
    {
        public var magicValue : String;
        public var propertyKey : *;

        public function DestinationEntry(mv : String, pk : *)
        {
            magicValue = mv;
            propertyKey = pk;
        }
    }
}