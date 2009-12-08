package tests
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import flexunit.framework.TestCase;
	
	import mx.containers.Panel;
	import mx.controls.Button;
	
	import net.expantra.smartypants.Injector;
	import net.expantra.smartypants.Provider;
	import net.expantra.smartypants.impl.InjectorImpl;
	import net.expantra.smartypants.impl.sp_internal;
	
	import tests.support.Host;
	import tests.support.Injectee;
	import tests.support.InjecteeTheSecond;
	import tests.support.NameSpaceInjectionTarget;
	import tests.support.SingletonClass;
	import tests.support.SomeClass;
	import tests.support.SomeSubClass;
	use namespace sp_internal;

	public class SmartyPantsTestSuite extends TestCase implements IEventDispatcher
	{
		private var injector:Injector;

		private var _eventDispatcher:IEventDispatcher;

		private function get eventDispatcher():IEventDispatcher
		{
			if (!_eventDispatcher)
				_eventDispatcher=new EventDispatcher(this);

			return _eventDispatcher;
		}

		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}

		public function dispatchEvent(event:Event):Boolean
		{
			return eventDispatcher.dispatchEvent(event);
		}

		public function hasEventListener(type:String):Boolean
		{
			return eventDispatcher.hasEventListener(type);
		}

		public function willTrigger(type:String):Boolean
		{
			return eventDispatcher.willTrigger(type);
		}

		override public function setUp():void
		{
			injector=new InjectorImpl();
		}

		override public function tearDown():void
		{
		}

		public function test_InjectorShouldExist():void
		{
			assertNotNull("No injector found!", injector);
		}

		public function test_SimpleRequestsShouldWork():void
		{
			var button:*=injector.newRequest(this).forClass(Button).getInstance();
			var panel:*=injector.newRequest(this).forClass(Panel).getInstance();

			assertTrue("Got the wrong item for button", button is Button);
			assertTrue("Got the wrong item for panel", panel is Panel);
		}

		public function test_SingletonAnnotationShouldHonoured():void
		{
			var instance1:SingletonClass=injector.newRequest(this).forClass(SingletonClass).getInstance();
			var instance2:SingletonClass=injector.newRequest(this).forClass(SingletonClass).getInstance();
			var provider:Provider=injector.newRequest(this).forClass(SingletonClass).getProvider();

			assertTrue("instances should be strictly equal!", instance1 === instance2);
			assertTrue("provider must return same instance also", instance1 === provider.getInstance());
		}

		public function test_BindingSelfToSelfShouldFail():void
		{
			try
			{
				injector.newRule().whenAskedFor(SingletonClass).useClass(SingletonClass);
				fail("Should not be able to bind SingletonClass to itself");
			}
			catch (expected:Error)
			{
				//...
			}

			var instance1:SingletonClass=injector.newRequest(this).forClass(SingletonClass).getInstance();
			var instance2:SingletonClass=injector.newRequest(this).forClass(SingletonClass).getInstance();

			assertTrue("instances should be equal!", instance1 == instance2);
		}

		public function test_SingletonAnnotationShouldWorkWithRules():void
		{
			injector.newRule().whenAskedFor(SingletonClass).named("stillASingleton").useClass(SingletonClass);

			var instance1:SingletonClass=injector.newRequest(this).forClass(SingletonClass).getInstance();
			var instance2:SingletonClass=injector.newRequest(this).forClass(SingletonClass).getInstance();
			var instance3:SingletonClass=injector.newRequest(this).forClass(SingletonClass).named("stillASingleton").getInstance();
			var instance4:SingletonClass=injector.newRequest(this).forClass(SingletonClass).named("stillASingleton").getInstance();

			assertTrue("instances should be strictly equal!", instance1 === instance2);
			assertTrue("instances should be strictly equal!", instance1 === instance3);
			assertTrue("instances should be strictly equal!", instance1 === instance4);
		}
		
		public function test_SingletonAnnotationShouldBeOverrideable():void
		{
			injector.newRule().whenAskedFor(SingletonClass).named("stillASingleton").createInstanceOf(SingletonClass);

			var instance1:SingletonClass=injector.newRequest(this).forClass(SingletonClass).getInstance();
			var instance2:SingletonClass=injector.newRequest(this).forClass(SingletonClass).getInstance();
			var instance3:SingletonClass=injector.newRequest(this).forClass(SingletonClass).named("stillASingleton").getInstance();
			var instance4:SingletonClass=injector.newRequest(this).forClass(SingletonClass).named("stillASingleton").getInstance();

			assertTrue("instances should be strictly equal!", instance1 === instance2);
			assertTrue("instances should not be equal!", instance1 != instance3);
			assertTrue("instances should not be equal!", instance1 != instance4);
			assertTrue("instances should not be equal!", instance3 != instance4);
		}

		public function test_RequestByNameWithoutMatchingRuleShouldFail():void
		{
			try
			{
				var o:*=injector.newRequest(this).forClass(SingletonClass).named("nameHasNoRule").getInstance();
				fail("Expecting an exception when trying to get an instance by name without a valid rule");
			}
			catch (ignored:*)
			{
				//Pass
			}
		}

		public function test_PopulatingInjecteeWithoutEnoughRulesShouldFail():void
		{
			try
			{
				injector.newRequest(this).forClass(Injectee).getInstance();
				fail("Injectee requires unresolveable dependencies, so should fail");
			}
			catch (ignored:*)
			{
				//Pass
			}
		}

		public function test_BasicAnnotationsForInjecteeShouldWork():void
		{
			const fooValue:String="Foo Value " + Math.floor(Math.random() * 99999);

			injector.newRule().whenAskedFor(String).named("foo").useValue(fooValue);
			injector.newRule().whenAskedFor(String).named("purple").useValue(null);
			injector.newRule().whenAskedFor(Number).named("meaningOfLife").useValue(null);

			var injectee:Injectee=injector.newRequest(this).forClass(Injectee).getInstance();

			assertEquals("stringNamedFoo not set correctly", fooValue, injectee.stringNamedFoo);
			assertEquals("stringNamedFooProvider not set correctly", fooValue, injectee.stringNamedFooProvider.getInstance());
			assertTrue("injectee.button must be a Button", injectee.button is Button);
			assertTrue("injectee.injector must be the injector", injectee.injector === injector);
		}

		public function test_LiveBindingsShouldWork():void
		{
			const fooValue:String="Foo Value " + Math.floor(Math.random() * 99999);
			const fooValue2:String="Foo Value2 " + Math.floor(Math.random() * 99999);
			const fooValue3:String="Foo Value3 " + Math.floor(Math.random() * 99999);

			injector.newRule().whenAskedFor(String).named("foo").useValue(fooValue);
			injector.newRule().whenAskedFor(String).named("purple").useValue(null);
			injector.newRule().whenAskedFor(Number).named("meaningOfLife").useValue(null);

			var injectee:Injectee=injector.newRequest(this).forClass(Injectee).getInstance();

			assertNull("String1 should be null initially", injectee.l1);
			assertNull("String2 should be null initially", injectee.l2);

			var host:Host=new Host();

			injector.newRule().whenAskedFor(String).named("live1").useValue(fooValue2);

			assertEquals("Value should be updated", fooValue2, injectee.l1);

			injector.newRule().whenAskedFor(String).named("live2").useBindableProperty(host, "string1");
			assertNull("String2 should still be null", injectee.l2);

			host.string1=fooValue3;
			assertEquals("Value should be foo3", fooValue3, injectee.l2);

			host.string1=fooValue2;
			assertEquals("Value should be foo2", fooValue2, injectee.l2);
		}

		public function test_PostConstructFunctionShouldBeExecuted():void
		{
			injector.newRule().whenAskedFor(String).named("foo").useValue("fooValue");
			injector.newRule().whenAskedFor(String).named("purple").useValue(null);
			injector.newRule().whenAskedFor(Number).named("meaningOfLife").useValue(null);

			var injectee:Injectee=injector.newRequest(this).forClass(Injectee).getInstance();

			assertTrue("PostConstruct function was not called", injectee.setupWasCalled);
			assertEquals("Wrong injector value passed to injectee.setup()", injector, injectee.setupInjector);
		}

		public function test_InjectIntoAnnotationShouldWork():void
		{
			const str:String="Purple's a fruit";
			const liff:Number=42;
			injector.newRule().whenAskedFor(String).named("purple").useValue(str);
			injector.newRule().whenAskedFor(Number).named("meaningOfLife").useValue(liff);
			injector.newRule().whenAskedFor(String).named("foo").useValue(null);

			var injectee:Injectee=injector.newRequest(this).forClass(Injectee).getInstance();

			assertEquals("[InjectInto] failed for subInjectee.isPurple", str, injectee.subInjectee.isPurple);
			assertEquals("Somebody call the mice!", liff, injectee.subInjectee.adamsConstant);
		}

		public function test_InjectIntoContentsAnnotationShouldWork():void
		{
			const str:String="Purple's a fruit";
			const liff:Number=42;
			injector.newRule().whenAskedFor(String).named("purple").useValue(str);
			injector.newRule().whenAskedFor(Number).named("meaningOfLife").useValue(liff);
			injector.newRule().whenAskedFor(String).named("foo").useValue(null);

			var injectee:Injectee=injector.newRequest(this).forClass(Injectee).getInstance();

			assertEquals("[InjectInto] failed for subInjectees[0].isPurple", str, injectee.subInjectees[0].isPurple);
			assertEquals("[InjectInto] failed for subInjectees[1].isPurple", str, injectee.subInjectees[1].isPurple);
			assertEquals("[InjectInto] failed for subInjectees[2].isPurple", str, injectee.subInjectees[2].isPurple);
			assertEquals("[InjectInto] failed for subInjectees[3].isPurple", str, injectee.subInjectees[3].isPurple);
			assertEquals("[InjectInto] failed for subInjectees[4].isPurple", str, injectee.subInjectees[4].isPurple);
			assertEquals("Somebody call the mice!", liff, injectee.subInjectees[0].adamsConstant);
			assertEquals("Somebody call the mice! - 2", liff, injectee.subInjectees[1].adamsConstant);
			assertEquals("Somebody call the mice! - 3", liff, injectee.subInjectees[2].adamsConstant);
			assertEquals("Somebody call the mice! - 4", liff, injectee.subInjectees[3].adamsConstant);
			assertEquals("Somebody call the mice! - 5", liff, injectee.subInjectees[4].adamsConstant);
		}

		public function test_RuleErasureShouldWork():void
		{
			injector.newRule().whenAskedFor(String).named("teddy").useValue("bear");
			var shouldBeBear:String=injector.newRequest(this).forClass(String).named("teddy").getInstance();

			injector.newRule().whenAskedFor(String).named("teddy").useValue("Roosevelt");
			var shouldBeRoosevelt:String=injector.newRequest(this).forClass(String).named("teddy").getInstance();

			injector.newRule().whenAskedFor(String).named("teddy").defaultBehaviour();
			var shouldBeNull:String;

			try
			{
				shouldBeNull=injector.newRequest(this).forClass(String).named("teddy").getInstance();
				fail("Should have gotten an exception trying to find injection for String named \"teddy\".");
			}
			catch (e:*)
			{
				;
			}

			assertEquals("Bouncing here and there and everywhere!", "bear", shouldBeBear);
			assertEquals("The president has left the building", "Roosevelt", shouldBeRoosevelt);
			assertNull("Should not have a value once the rule has been removed!", shouldBeNull);
		}

		public function test_LiveInjectionPointsShouldFallBackOnDefaultRule():void
		{
			var injectee2:InjecteeTheSecond=injector.newRequest(this).forClass(InjecteeTheSecond).getInstance();

			var originalValue:String=injectee2.someInstance.identifyingValue;

			injector.newRule().whenAskedFor(SomeClass).useClass(SomeSubClass);

			var secondValue:String=injectee2.someInstance.identifyingValue;

			assertTrue("originalValue and secondValue should be different", originalValue != secondValue);
			assertEquals("originalValue was incorrect", "From SomeClass", originalValue);
			assertEquals("secondValue was incorrect", "From SomeSubClass", secondValue);
		}
		
		public function test_InjectNamespaceShouldBeSupported():void
		{
			var injectee:NameSpaceInjectionTarget = injector.newRequest(this).forClass(NameSpaceInjectionTarget).getInstance();
			
			assertTrue("A button should have been created and injected into injectee", injectee.shouldBeAButton is Button);
		}
	}
}