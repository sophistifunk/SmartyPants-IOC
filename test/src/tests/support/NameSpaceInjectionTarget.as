package tests.support
{
    import mx.controls.Button;

    import net.expantra.smartypants.inject;

    public class NameSpaceInjectionTarget
    {
        inject var shouldBeAButton:Button;

        public function get shouldBeAButton():*
        {
            return inject::shouldBeAButton;
        }
    }
}