package net.expantra.smartypants.utils.reflector
{
    import flash.utils.Dictionary;
    import flash.utils.describeType;
    import flash.utils.getQualifiedClassName;

    /**
     * Reflection api with caching, but no statics. Marked as <code>[Singleton]</code> though, so
     * third parties can just inject one and get the cache benefits. No Flex dependencies.
     * @author josh
     */
    [Singleton]
    public class Reflector
    {
        //--------------------------------------------------------------------------
        //
        //  Static consts
        //
        //--------------------------------------------------------------------------

//		public static const TYPE_VOID:* = {};
//		public static const TYPE_ANY:* = {};

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        public function Reflector(cacheEnabled:Boolean = true)
        {
        	this.cacheEnabled = cacheEnabled;
        	
        	if (cacheEnabled)
        	{ 
            	typeDescriptionCache = new Dictionary(true);
            	reflectorObjectCache = new Dictionary(true);
         	}
        }

        //--------------------------------------------------------------------------
        //
        //  Internal Caches
        //
        //--------------------------------------------------------------------------

		private var cacheEnabled:Boolean;
        private var typeDescriptionCache:Dictionary;
        private var reflectorObjectCache:Dictionary

        //--------------------------------------------------------------------------
        //
        //  Public API
        //
        //--------------------------------------------------------------------------

        private const simpleTypes:Array = [getQualifiedClassName(String), getQualifiedClassName(Number), getQualifiedClassName(Boolean), getQualifiedClassName(uint),
                                           getQualifiedClassName(int), getQualifiedClassName(Date)];

        /**
         * Is this a simple type (or null)?
         */
        public function isSimpleType(testee:*):Boolean
        {
            if (testee === null || testee === undefined)
                return true;

            return simpleTypes.indexOf(getQualifiedClassName(testee)) >= 0;
        }
        
        /**
         * Get a query object for a specific class 
         * @param clazz a Class instance (eg: Number, Button, ArrayCollection, etc....)
         * @return the root of the query DSL.
         */
        public function forClass(clazz:Class):SPClass
        {
        	if (!cacheEnabled)
        	{
        		return createReflectorDSLForClass(clazz);
        	}
        	
        	if (!(clazz in reflectorObjectCache))
        	{
        		reflectorObjectCache[clazz] = createReflectorDSLForClass(clazz);
        	}
        	
        	return reflectorObjectCache[clazz];
        }

        //--------------------------------------------------------------------------
        //
        //  Internals
        //
        //--------------------------------------------------------------------------

        protected function typeDescriptionFor(clazz:Class):XML
        {
        	var desc:XML;
        	
        	if (!cacheEnabled)
        	{
        		return describeType(clazz);
        	}
        	
        	if (!(clazz in typeDescriptionCache))
        	{
        		typeDescriptionCache[clazz] = describeType(clazz);
        	}
        		
        	return typeDescriptionCache[clazz];   	
        }
        
        protected function createReflectorDSLForClass(clazz:Class):SPClass
        {
        	return new SPClassImpl(typeDescriptionFor(clazz), this);
        }

    }
}