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
    import net.expantra.smartypants.SmartyPants;
    import net.expantra.smartypants.impl.InjectorImpl;

    import tests.support.Injectee;
    import tests.support.SingletonClass;

    public class SmartyPantsTestSuite extends TestCase implements IEventDispatcher
    {
        private var injector : Injector;

        private var _eventDispatcher : IEventDispatcher;

        private function get eventDispatcher() : IEventDispatcher
        {
            if (!_eventDispatcher)
                _eventDispatcher = new EventDispatcher(this);

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

        override public function setUp() : void
        {
            trace();
            trace("---- Begin Test ----");
            trace("Test begin: Status is", SmartyPants.status);
            injector = new InjectorImpl();
        }

        override public function tearDown() : void
        {
            injector = null;

            trace("Teardown Complete: Status is", SmartyPants.status);
            trace("---- End Test ----");
            trace();
        }

        public function testExistence() : void
        {
            assertNotNull("No injector found!", injector);
        }

        public function testSimpleRequests() : void
        {
            var button : * = injector.newRequest().forClass(Button).getInstance();
            var panel : * = injector.newRequest().forClass(Panel).getInstance();

            assertTrue("Got the wrong item for button", button is Button);
            assertTrue("Got the wrong item for panel", panel is Panel);
        }

        public function testSingletonAnnotation() : void
        {
            var instance1 : SingletonClass = injector.newRequest().forClass(SingletonClass).getInstance();
            var instance2 : SingletonClass = injector.newRequest().forClass(SingletonClass).getInstance();
            var provider : Provider = injector.newRequest().forClass(SingletonClass).getProvider();

            assertTrue("instances should be strictly equal!", instance1 === instance2);

            assertTrue("provider must return same instance also", instance1 === provider.getInstance());
        }

        public function testSingletonAnnotationIsIgnoredWhenRulePresent() : void
        {
            injector.newRule().whenAskedFor(SingletonClass).useClass(SingletonClass);

            var instance1 : SingletonClass = injector.newRequest().forClass(SingletonClass).getInstance();
            var instance2 : SingletonClass = injector.newRequest().forClass(SingletonClass).getInstance();

            assertFalse("instances should not be equal!", instance1 == instance2);
        }

        public function testSingletonAnnotationIsIgnoredWhenRulePresent2() : void
        {
            injector.newRule().whenAskedFor(SingletonClass).named("notSingleton").useClass(SingletonClass);

            var instance1 : SingletonClass = injector.newRequest().forClass(SingletonClass).getInstance();
            var instance2 : SingletonClass = injector.newRequest().forClass(SingletonClass).getInstance();
			var instance3 : SingletonClass = injector.newRequest().forClass(SingletonClass).named("notSingleton").getInstance();
			var instance4 : SingletonClass = injector.newRequest().forClass(SingletonClass).named("notSingleton").getInstance();

            assertTrue("instances should be strictly equal!", instance1 === instance2);
            assertFalse("instances should not be equal!", instance1 == instance3);
            assertFalse("instances should not be equal!", instance1 == instance4);
            assertFalse("instances should not be equal!", instance3 == instance4);
        }

        public function testNoRegisteredInjectorForThis() : void
        {
        	var registeredInjector : Injector = SmartyPants.locateInjectorFor(this);

        	assertNull("There should not be a registered injector for this class", registeredInjector);

        	try
        	{
        		SmartyPants.getInjectorFor(this);
        		fail("We should get an exception when we call getInjectorFor(this)");
        	}
        	catch (ignored : *)
        	{
        		//Pass
        	}
        }

        public function testFailureWhenRequestByNameWithoutMatchingRule() : void
        {
            try
            {
                var o : * = injector.newRequest().forClass(SingletonClass).named("nameHasNoRule").getInstance();
                fail("Expecting an exception when trying to get an instance by name without a valid rule");
            }
            catch (ignored : *)
            {
                //Pass
            }
        }

        public function testFailurePopulatingInjecteeWithoutRules() : void
        {
            try
            {
                injector.newRequest().forClass(Injectee).getInstance();
                fail("Injectee requires unresolveable dependencies, so should fail");
            }
            catch (ignored : *)
            {
                //Pass
            }
        }

        public function testAnnotationsForInjectee() : void
        {
            const fooValue : String = "Foo Value " + Math.floor(Math.random() * 99999);

            injector.newRule().whenAskedFor(String).named("foo").useInstance(fooValue);

            var injectee : Injectee = injector.newRequest().forClass(Injectee).getInstance();

            assertEquals("stringNamedFoo not set correctly", fooValue, injectee.stringNamedFoo);
            assertEquals("stringNamedFooProvider not set correctly", fooValue, injectee.stringNamedFooProvider.getInstance());
            assertTrue("injectee.button must be a Button", injectee.button is Button);
            assertTrue("injectee.injector must be the injector", injectee.injector === injector);
        }

    }
}