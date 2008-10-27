package net.expantra.smartypants.utils
{
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    import mx.collections.XMLListCollection;
    import mx.utils.DescribeTypeCache;

    public class Reflection
    {
        /**
         * Returns a list of all variables and all writeable accessors. These are nodes from describeType()
         */
        public static function getWriteablePropertyDescriptions(instance : *) : XMLListCollection
        {
            var xml : XML = DescribeTypeCache.describeType(instance).typeDescription;

            var resultList : XMLListCollection;
            var node : XML;

            resultList = new XMLListCollection(xml..accessor.(@access != "readonly"));

            var tmp : XMLList = xml..variable;

            for each (node in tmp)
            {
                resultList.addItem(node);
            }

            return resultList;
        }

        /**
         * Returns a list of all variables and all readable accessors. These are nodes from describeType()
         */
        public static function getReadablePropertyDescriptions(instance : *) : XMLListCollection
        {
            var xml : XML = DescribeTypeCache.describeType(instance).typeDescription;

            var resultList : XMLListCollection;
            var node : XML;

            resultList = new XMLListCollection(xml..accessor.(@access != "writeonly"));

            var tmp : XMLList = xml..variable;

            for each (node in tmp)
            {
                resultList.addItem(node);
            }

            return resultList;
        }

        public static function filterMembersByMetadataName(memberDescriptions : XMLListCollection, metadataName : String) : XMLListCollection
        {
            return new XMLListCollection(memberDescriptions.source.(descendants("metadata").(attribute("name") == metadataName).length() > 0));
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
        * Given a property description node, returns the name or qname required to index it using []
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
        * Filters metadata on key and value. If only one of key or value parameters is non-null, filters only on that field
        */
        public static function filterMetadataByArguments(input : XMLList, key : String = null, value : String = null) : XMLList
        {
            if (!key && !value)
            {
                return input;
            }

            if (key && !value)
            {
               return input.(arg.(@key == key));
            }

            if (value && !key)
            {
                return input.(arg.(@value == value));
            }

            return input.(arg.(@key == key && @value == value));
        }

        /**
        * Returns true if the class in question extends or implements the class provided
        */
        public static function classExtendsOrImplements(classOrClassName : *, superclass : Class) : Boolean
        {
            var superclassName : String = getQualifiedClassName(superclass);

            if (classOrClassName is String)
            {
                try
                {
                    classOrClassName = getDefinitionByName(classOrClassName);
                }
                catch (e : Error)
                {
                    throw new Error("The class name " + classOrClassName + " is not valid because of " + e + "\n" + e.getStackTrace());
                }
            }

            if (!(classOrClassName is Class))
            {
                throw new Error("The parameter classOrClassName must be a valid Class instance or fully qualified class name.");
            }

            if (classOrClassName == superclass)
                return true;

            var factoryDescription : XML = DescribeTypeCache.describeType(classOrClassName).typeDescription.factory[0];

            return (factoryDescription.children().(name() == "implementsInterface" || name() == "extendsClass").(attribute("type") == superclassName).length() > 0)
        }
    }
}