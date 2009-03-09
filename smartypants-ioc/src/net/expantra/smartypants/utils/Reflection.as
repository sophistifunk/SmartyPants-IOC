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

        /**
         * Returns a list of all variables and all readable-writeable accessors. These are nodes from describeType()
         */
        public static function getReadWritePropertyDescriptions(instance : *) : XMLList
        {
            var description : XML = sp_describeType(instance).typeDescription;
            return description.descendants().(name() == "variable" || (name() == "accessor" && attribute("access") == "readwrite"));
        }

        /**
         * Returns only members that have the specified metadata
         * @param memberDescriptions
         * @param metadataName
         * @return
         *
         */
        public static function filterMembersByMetadataName(memberDescriptions : XMLList, metadataName : String) : XMLList
        {
            return memberDescriptions.(descendants("metadata").(attribute("name") == metadataName).length() > 0);
        }

        /**
         * Finds functions. Will not find statics if passed a Class.
         * @param instanceOrClass
         * @return
         *
         */
        public static function getFunctions(instanceOrClass : Object) : XMLList
        {
            var desc : XML = sp_describeType(instanceOrClass).typeDescription;
            return instanceOrClass is Class ? desc.factory.method : desc.method;
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

            if (key != null && value == null)
            {
               result = input.(child("arg").(attribute("key") == key).length() > 0);
            }
            else if (value != null && key == null)
            {
                result = input.(child("arg").(attribute("value") == value).length() > 0);
            }
            else if (value != null && key != null)
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
         * Gets class-level metadata nodes from a class at runtime.
         * @param clazz the class to introspect
         * @param metadataName an optional filter. If specified, will only return metadata nodes of that name, if null will return all class-level metadata
         * @return
         *
         */
        public static function getClassMetadata(clazz : Class, metadataName : String = null) : XMLList
        {
            var classMetaData : XMLList = sp_describeType(clazz).typeDescription.factory.metadata;

            if (metadataName)
                return classMetaData.(@name == metadataName);

            return classMetaData;
        }

        /**
         * Returns the content of [ArrayElementType("fully.qualified.name")] as Class. Throws an error if the definition can not be resolved in the context.
         * @param instanceOrClass
         * @param fieldName
         * @return an instance of Class, or null if no [ArrayElementType] annotation was found
         *
         */
        public static function getArrayElementType(instanceOrClass : Object, fieldName : String) : Class
        {
            var propertyDescription : XML = getPropertyDescription(instanceOrClass, fieldName);

            var aetMetadata : XMLList = getMetaDataNodes(propertyDescription, "ArrayElementType");

            if (aetMetadata.length() == 0)
                return null;

            try
            {
                return getDefinitionByName(aetMetadata.child("arg").attribute("value")[0]) as Class;
            }
            catch (e : Error)
            {
                if (e.toString().indexOf("Error #1065:") >= 0)
                {
                    throw new Error("The type \"" + (aetMetadata.child("arg").attribute("value")[0]) + "\" was listed as" +
                                    " [ArrayElementType()] for " + getQualifiedClassName(instanceOrClass) + "." + fieldName +
                                    " but could not be found at run time. Make sure it is correctly spelled, fully-qualified, and being compiled.");
                }
                else
                {
                    throw e;
                }
            }

            throw "This is just here to please the compiler";
        }

        /**
         * Retrieve a property description by name
         * @param instanceOrClass
         * @param fieldName
         * @return
         *
         */
        public static function getPropertyDescription(instanceOrClass : Object, fieldName : String) : XML
        {
            return sp_describeType(instanceOrClass).typeDescription..*.((name() == "variable" || name() == "accessor") && attribute("name") == fieldName)[0];
        }

        /**
         * Determines whether a Class object represents an ActionScript interface or a concrete class
         * @param clazz
         * @return
         */
        public static function isInterface(clazz : Class) : Boolean
        {
            return sp_describeType(clazz).typeDescription.factory.extendsClass.length() == 0;
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
            if(o is Class || o is String)
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