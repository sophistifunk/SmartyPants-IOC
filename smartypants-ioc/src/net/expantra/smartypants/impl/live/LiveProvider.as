package net.expantra.smartypants.impl.live
{
	import net.expantra.smartypants.Provider;

	public class LiveProvider implements Provider
	{
        private var lookupFunction : Function;
        private var magicValue : String;

        public function LiveProvider(lookupFunction : Function, magicValue : String)
        {
            this.lookupFunction = lookupFunction;
            this.magicValue = magicValue;
        }

        public function getInstance() : *
        {
            return lookupFunction(magicValue);
        }

        public function toString() : String
        {
            return "LiveProvider for magic key \"" + magicValue + "\"";
        }
	}
}