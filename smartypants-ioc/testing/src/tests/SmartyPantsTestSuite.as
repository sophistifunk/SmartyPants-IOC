package tests
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.system.System;

    import flexunit.framework.TestCase;

    import mx.containers.Panel;
    import mx.controls.Button;

    import net.expantra.smartypants.Injector;
    import net.expantra.smartypants.Provider;
    import net.expantra.smartypants.SmartyPants;
    import net.expantra.smartypants.impl.InjectorImpl;
    import net.expantra.smartypants.impl.sp_internal;

    import tests.support.Host;
    import tests.support.Injectee;
    import tests.support.SingletonClass;
    use namespace sp_internal;

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
            SmartyPants.singleInjectorMode = true; //Return to the default
            injector = new InjectorImpl();
        }

        override public function tearDown() : void
        {
            injector = undefined;
            System.gc();

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

        public function testMultipleInjectorMode() : void
        {
            SmartyPants.singleInjectorMode = false;

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

        public function testSingleInjectorMode() : void
        {
            var injector : Injector = SmartyPants.locateInjectorFor(this);

            assertNotNull("There be a 'registered' injector for this class", injector);

            injector = SmartyPants.getInjectorFor(this);

            assertNotNull("There be a fetchable injector for this class", injector);
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

        public function testLiveBindings() : void
        {
            const fooValue : String = "Foo Value " + Math.floor(Math.random() * 99999);
            const fooValue2 : String = "Foo Value2 " + Math.floor(Math.random() * 99999);
            const fooValue3 : String = "Foo Value3 " + Math.floor(Math.random() * 99999);

            injector.newRule().whenAskedFor(String).named("foo").useInstance(fooValue);
            var injectee : Injectee = injector.newRequest().forClass(Injectee).getInstance();

            assertNull("String1 should be null initially", injectee.l1);
            assertNull("String2 should be null initially", injectee.l2);

            var host : Host = new Host();

            injector.newRule().whenAskedFor(String).named("live1").useInstance(fooValue2);

            assertEquals("Value should be updated", fooValue2, injectee.l1);

            injector.newRule().whenAskedFor(String).named("live2").useBindableProperty(host, "string1");
            assertNull("String2 should still be null", injectee.l2);

            host.string1 = fooValue3;
            assertEquals("Value should be foo3", fooValue3, injectee.l2);

            host.string1 = fooValue2;
            assertEquals("Value should be foo2", fooValue2, injectee.l2);
        }

        public function testPostConstruct() : void
        {
            injector.newRule().whenAskedFor(String).named("foo").useInstance("fooValue");
            var injectee : Injectee = injector.newRequest().forClass(Injectee).getInstance();

            assertTrue("PostConstruct function was not called", injectee.setupWasCalled);
            assertEquals("Wrong injector value passed to injectee.setup()", injector, injectee.setupInjector);
        }
    }
}