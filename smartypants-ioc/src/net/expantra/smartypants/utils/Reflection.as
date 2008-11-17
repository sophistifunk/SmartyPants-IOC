package net.expantra.smartypants.utils
{
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import mx.utils.DescribeTypeCacheRecord;

    /**
     * Reflection utils. todo: Better documentation is required here before 1.0!
     *
     * @author josh@gfunk007.com
     *
     */
    public class Reflection
    {
        /**
         * Part of our reimpl of DescribeTypeCache
         */
        private static var typeCache : Object = {};

        /**
         * Returns a list of all variables and all writeable accessors. These are nodes from describeType()
         */
        public static function getWriteablePropertyDescriptions(instance : *) : XMLList
        {
            var description : XML = sp_describeType(instance).typeDescription;
            return description.descendants().(name() == "variable" || (name() == "accessor" && attribute("access") != "readonly"));
        }

        /**
         * Returns a list of all variables and all readable accessors. These are nodes from describeType()
         */
        public static function getReadablePropertyDescriptions(instance : *) : XMLList
        {
            var description : XML = sp_describeType(instance).typeDescription;
            return description.descendants().(name() == "variable" || (name() == "accessor" && attribute("access") != "writeonly"));
        }

        public static function filterMembersByMetadataName(memberDescriptions : XMLList, metadataName : String) : XMLList
        {
            return memberDescriptions.(descendants("metadata").(attribute("name") == metadataName).length() > 0);
        }

        /**
        * Is this a simple type (or null)?
        */
        public static function isSimpleType(testee : *) : Boolean
        {
            const simpleTypes : Array = [getQualifiedClassName(String),
                                         getQualifiedClassName(Number),
                                         getQualifiedClassName(Boolean),
                                         getQualifiedClassName(uint),
                                         getQualifiedClassName(int)];

            if (testee == null) //undefined and void should both return true to "== null"
                return true;

            return simpleTypes.indexOf(getQualifiedClassName(testee)) >= 0;
        }

        /**
        * Given a property description node, returns the String name or qname required to index it using []
        */
        public static function getPropertyName(propertyDescription : XML) : *
        {
            return "@uri" in propertyDescription ?
                   new QName(propertyDescription.@uri, propertyDescription.@name) :
                   String(propertyDescription.@name);
        }

        /**
        * Given a property description node, returns the Class instance for its type.
        */
        public static function resolvePropertyType(propertyDescription : XML) : Class
        {
            var className : String = propertyDescription.@type;

            return className == "*" ? Object : Class(getDefinitionByName(className));
        }

        /**
        * Given a property description node and an optional metadata name, returns a list of metadata description nodes
        */
        public static function getMetaDataNodes(propertyDescription : XML, metaDataName : String = null) : XMLList
        {
            return metaDataName ? (propertyDescription..metadata.(attribute("name") == metaDataName)) :
                                  (propertyDescription..metadata);
        }

        /**
        * Given a list of metadata descriptions, returns all that have a matching key and/or value argument combination
        *
        * @param key the key to match for. If null, matches on value only
        * @param value the value to match for. If null, matches on key only
        */
        public static function filterMetadataByArguments(input : XMLList, key : String = null, value : String = null) : XMLList
        {
            var result : XMLList = input;

            if (key && !value)
            {
               result = input.(child("arg").(attribute("key") == key).length() > 0);
            }
            else if (value && !key)
            {
                result = input.(child("arg").(attribute("value") == value).length() > 0);
            }
            else if (value && key)
            {
                result = input.(child("arg").(attribute("key") == key && attribute("value") == value).length() > 0);
            }

            return result;
        }

        /**
        * Returns true if the class in question extends or implements the class provided
        */
        public static function classExtendsOrImplements(classOrClassName : *, superclass : Class) : Boolean
        {
            var superclassName : String = getQualifiedClassName(superclass);

            var actualClass : Class;

            if (classOrClassName is Class)
            {
                actualClass = Class(classOrClassName);
            }
            else if (classOrClassName is String)
            {
                try
                {
                    actualClass = Class(getDefinitionByName(classOrClassName));
                }
                catch (e : Error)
                {
                    throw new Error("The class name " + classOrClassName + " is not valid because of " + e + "\n" + e.getStackTrace());
                }
            }

            if (!actualClass)
            {
                throw new Error("The parameter classOrClassName must be a valid Class instance or fully qualified class name.");
            }

            if (actualClass == superclass)
                return true;

            var factoryDescription : XML = sp_describeType(actualClass).typeDescription.factory[0];

            return (factoryDescription.children().(name() == "implementsInterface" || name() == "extendsClass").(attribute("type") == superclassName).length() > 0)
        }

        /**
         * Reimplements mx.utils.DescribeTypeCache because of https://bugs.adobe.com/jira/browse/SDK-18073
         * I'll pull it when it's no-longer needed. Might be a while :)
         * @param o
         * @return
         *
         */
        public static function sp_describeType(o : *) : DescribeTypeCacheRecord
        {
            var className : String;
            var cacheKey : String;

            if (o is String)
                cacheKey = className = o;
            else
                cacheKey = className = getQualifiedClassName(o);

            //Need separate entries for describeType(Foo) and describeType(myFoo)
            if(o is Class)
                cacheKey += "$";

            if (cacheKey in typeCache)
            {
                return typeCache[cacheKey];
            }
            else
            {
                if (o is String)
                    o = getDefinitionByName(o);

                var typeDescription : XML = flash.utils.describeType(o);
                var record : DescribeTypeCacheRecord = new DescribeTypeCacheRecord();
                record.typeDescription = typeDescription;
                record.typeName = className;
                typeCache[cacheKey] = record;

                return record;
            }
        }
    }
}