package net.expantra.smartypants
{
    import mx.core.IMXMLObject;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;

    import net.expantra.smartypants.Injector;
    import net.expantra.smartypants.SmartyPants;

    public class RequestInjection implements IMXMLObject
    {
        public function initialized(document : Object, id : String) : void
        {
            var uic : UIComponent = document as UIComponent;

            if (!uic)
               throw new Error("The InjectOnCreationComplete MXML tag should only be used in subclasses of UIComponent");

            uic.addEventListener(FlexEvent.CREATION_COMPLETE, cc, false, 0, true);
        }

        private function cc(event : FlexEvent) : void
        {
            var injector : Injector = SmartyPants.getOrCreateInjectorFor(event.target);
            injector.injectInto(event.target);
        }
    }
}