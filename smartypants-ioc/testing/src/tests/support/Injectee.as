package tests.support
{
    import mx.controls.Button;

    import net.expantra.smartypants.Injector;
    import net.expantra.smartypants.Provider;

    public class Injectee
    {
        [Inject]
        public var injector : Injector;

        [Inject]
        public var button : Button;

        [Inject(name="foo")]
        public var stringNamedFoo : String;

        [Inject(type="String", name="foo")]
        public var stringNamedFooProvider : Provider;

        [Inject(name="live1", live)]
        public var l1 : String;

        [Inject(name="live2", live)]
        public var l2 : String;
    }
}