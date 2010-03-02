package tests.support
{
	public class ReflectionTestClass1
	{
		public function ReflectionTestClass1()
		{
		}

		public function method1():void
		{
			;
		}
		
		public function method2():String
		{
			return "a value";
		}
		
		public function method3(param1:String, param2:int):void
		{
			;
		}

		public function method4(param1:String, param2:*):void
		{
			;
		}
		
		public function method5(param1:String, param2:int = 4):void
 		{
			;
		}

		public function method6(param1:String, ...rest):void
 		{
			;
		}
	}
}