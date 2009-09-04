package tests.support
{
    public class SubInjectee
    {
        [Inject(name="purple")]
        public var isPurple : String;

        [Inject(name="meaningOfLife")]
        public var adamsConstant : Number;
    }
}