//using System;
//using System.Collections;
//using System.Reflection;
//using System.Xml;

//namespace Makolab.Fractus.Communication.Ipc.NamedPipes
//{
//    /// <summary>
//    /// Examines the state of objects and call methods using xml notation to define examination request.
//    /// </summary>
//    ////example <property name="Address"><method name="FindOnMap"/></property> calls FindOnMap method on Address property of root object.
//    public class PipeProtocol
//    {
//        private const string TAG_METHOD = "method";
//        private const string TAG_FIELD = "field";
//        private const string TAG_PROPERTY = "property";
//        private const string TAG_ARGUMENT = "arg";
//        private const string TAG_INDEX = "index";
//        private const string TAG_CLASS = "class";
//        private const string ATTRIBUTE_NAME = "name";
//        private const string ATTRIBUTE_TYPE = "type";

//        private object parentObj;

//        /// <summary>
//        /// Initializes a new instance of the <see cref="PipeProtocol"/> class.
//        /// </summary>
//        /// <param name="obj">The root object that starts the examination.</param>
//        public PipeProtocol(object obj)
//        {
//            parentObj = obj;
//        }

//        /// <summary>
//        /// Processes the specified request that examines root object.
//        /// </summary>
//        /// <param name="requestNode">The request</param>
//        /// <returns></returns>
//        public object Process(XmlNode requestNode)
//        {
//            if (requestNode == null)
//                throw new ArgumentNullException("requestNode");

//            object obj = parentObj;

//            foreach (XmlNode child in requestNode.ChildNodes)
//            {
//                if (child.Name.Equals(TAG_METHOD) || child.Name.Equals(TAG_FIELD) || child.Name.Equals(TAG_PROPERTY) || child.Name.Equals(TAG_CLASS))
//                {
//                    object index = null;
//                    ArrayList args = new ArrayList();
//                    string name = null;

//                    foreach (XmlNode grandChild in child.ChildNodes)
//                    {
//                        Type type = null;
//                        foreach (XmlAttribute attribute in grandChild.Attributes)
//                        {
//                            if (attribute.Name.Equals(ATTRIBUTE_TYPE))
//                            {
//                                type = Type.GetType(attribute.Value);
//                            }
//                        }

//                        if (grandChild.Name.Equals(TAG_ARGUMENT))
//                        {
//                            object o = grandChild.InnerXml;

//                            if (type == null || type.Equals(typeof(string)))
//                                args.Add(o.ToString());
//                            else
//                            {
//                                Type[] parseArgType = { typeof(string) };
//                                Object[] argValue = { o };
//                                MethodInfo method = type.GetMethod("Parse", parseArgType);

//                                if (method == null)
//                                    throw new Exception("Method \"Parse(string)\" not found. " +
//                                            "Cannot parse " + o.ToString() + " to " + type.FullName);

//                                args.Add(method.Invoke(type, argValue));
//                            }
//                        }
//                        else if (grandChild.Name.Equals(TAG_INDEX))
//                        {
//                            object o = grandChild.InnerXml;

//                            if (type == null || type.Equals(typeof(string)))
//                                index = o.ToString();
//                            else
//                            {
//                                Type[] parseArgType = { typeof(string) };
//                                Object[] argValue = { o };
//                                MethodInfo method = type.GetMethod("Parse", parseArgType);

//                                if (method == null)
//                                    throw new Exception("Method \"Parse(string)\" not found. " +
//                                            "Cannot parse " + o.ToString() + " to " + type.FullName);

//                                index = method.Invoke(type, argValue);
//                            }
//                            //else if (type.Equals(typeof(Int32)))
//                            //	index = Int32.Parse(grandChild.InnerXml);
//                        }
//                    }

//                    foreach (XmlAttribute attribute in child.Attributes)
//                    {
//                        if (attribute.Name.Equals(ATTRIBUTE_NAME))
//                            name = attribute.Value;
//                    }

//                    if (child.Name.Equals(TAG_METHOD))
//                    {
//                        Type[] types = new Type[args.Count];
//                        int i = 0;

//                        foreach (object o in args)
//                            types[i++] = o.GetType();

//                        MethodInfo method;
//                        Type t = obj as Type;

//                        if (t != null)
//                            method = t.GetMethod(name, types);
//                        else
//                            method = obj.GetType().GetMethod(name, types);
//                        if (method == null)
//                            throw new Exception("Method \"" + name + "\" not found.");

//                        obj = method.Invoke(obj, args.ToArray());
//                    }
//                    else if (child.Name.Equals(TAG_FIELD))
//                    {
//                        FieldInfo field = obj.GetType().GetField(name);

//                        if (field == null)
//                            throw new Exception("Field \"" + name + "\" not found.");

//                        obj = field.GetValue(obj);
//                    }
//                    else if (child.Name.Equals(TAG_PROPERTY))
//                    {
//                        PropertyInfo property = obj.GetType().GetProperty(name);

//                        if (property == null)
//                            throw new Exception("Property \"" + name + "\" not found.");

//                        obj = property.GetValue(obj, null);
//                    }
//                    else if (child.Name.Equals(TAG_CLASS))
//                    {
//                        if (name == null)
//                            throw new Exception("Class name \"" + name + "\" is null.");

//                        obj = Type.GetType("Makolab.Communication.XmlCommunicator." + name, true);
//                    }

//                    if (index != null)
//                    {
//                        obj = obj.GetType().GetProperty("Item").GetValue(obj, new object[] { index });

//                        if (obj == null)
//                            throw new Exception(name + "[" + index + "] is null.");
//                    }
//                }
//            }
//            return obj;
//        }
//    }
//}
