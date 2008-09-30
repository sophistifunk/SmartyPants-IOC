package net.expantra.smartypants.utils
{
    import flash.display.DisplayObject;
    import flash.events.Event;

    [Mixin]
    /**
    * Allows you to set a simple string flag, that will last exactly one frame. Use it when you're getting multiple notifications
    * for something you only want to do once to avoid nasty loops or work duplication.
    */
    public class SingleFrameFlags
    {
        private static var displayRooot : DisplayObject;
        private static var listening : Boolean = false;
        private static var flags : Object = {};

        //For Mixin
        public static function init(root : DisplayObject) : void
        {
            displayRooot = root;
        }

        /**
        * Sets a flag. This will last for the current frame only.
        */
        public static function setFlag(name : String) : void
        {
            flags[name] = true;

            if (!listening)
            {
                displayRooot.addEventListener(Event.ENTER_FRAME, reset);
                listening = true;
            }
        }

        /**
        * Remove a flag if set
        */
        public static function clearFlag(name : String) : void
        {
            if (name in flags)
                delete name[flags];
        }

        /**
        * Query flag
        */
        public static function flagIsSet(name : String) : Boolean
        {
            return (name in flags);
        }

        private static function reset(event : Event = null) : void
        {
            displayRooot.removeEventListener(Event.ENTER_FRAME, reset);
            listening = false;
            flags = {};
        }
    }
}