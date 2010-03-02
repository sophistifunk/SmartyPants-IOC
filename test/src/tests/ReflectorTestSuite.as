package tests
{
	import flexunit.framework.TestCase;
	
	import net.expantra.smartypants.utils.reflector.Reflector;
	
	import tests.support.ReflectionTestClass1;
	
	public class ReflectorTestSuite extends TestCase
	{
		private var reflector:Reflector;
		
		override public function setUp():void
		{
			reflector = new Reflector();
		}
		
		override public function tearDown():void
		{
			reflector = undefined;
		}
		
		public function test_reflectorShouldIdentifySimpleTypesCorrectly():void
		{
			assertTrue("String is a simple type", reflector.isSimpleType("Foo"));
			assertTrue("String is a simple type", reflector.isSimpleType(String));

			assertTrue("Number is a simple type", reflector.isSimpleType(765.23));
			assertTrue("Number is a simple type", reflector.isSimpleType(0x10));
			assertTrue("Number is a simple type", reflector.isSimpleType(Number));
			
			assertTrue("Boolean is a simple type", reflector.isSimpleType(true));
			assertTrue("Boolean is a simple type", reflector.isSimpleType(Boolean));

			assertTrue("Date is a simple type", reflector.isSimpleType(new Date()));
			assertTrue("Date is a simple type", reflector.isSimpleType(Date));
		}
		
		public function test_reflectorShouldListFunctions():void
		{
			var names:Array = reflector.forClass(ReflectionTestClass1).functions.names;
			
			assertTrue("Method1 not found", names.indexOf("method1") >= 0);
			assertTrue("Method2 not found", names.indexOf("method2") >= 0);
			assertTrue("Method3 not found", names.indexOf("method3") >= 0);
			assertTrue("Method4 not found", names.indexOf("method4") >= 0);
			assertTrue("Method5 not found", names.indexOf("method5") >= 0);
			assertTrue("Method6 not found", names.indexOf("method6") >= 0);
		}
	}
}