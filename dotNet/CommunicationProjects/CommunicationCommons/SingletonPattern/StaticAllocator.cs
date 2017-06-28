namespace Common.Patterns.Singleton
{
    #region Using directives

    using System;
    using System.Reflection;

    #endregion

    /// <summary>
    /// An static threadsafe allocator that creates the object on class loading by the framework.
    /// </summary>
    /// <typeparam name="T">Type of singleton object.</typeparam>
    /// <remarks>The framework specifies that the static constructor is called in an isolated compartment so there is no posibility that multiple threads can access the static constructor.</remarks>
    public class StaticAllocator<T> : Allocator<T> where T : class
    {
        private static readonly T instance;

        #region Constructors
        static StaticAllocator()
        {
            foreach (ConstructorInfo c in typeof(T).GetConstructors())
                if (c.IsPublic)
                    throw new InvalidOperationException(typeof(T).Name + " cannot have a public constructor");

            ConstructorInfo constructor = typeof(T).GetConstructor(BindingFlags.Instance | BindingFlags.NonPublic, null, new Type[0], new ParameterModifier[0]);
            if (constructor == null)
                throw new InvalidOperationException("The object that you want to singleton doesnt have a private/protected constructor so the property cannot be enforced.");

            try
            {
                instance = constructor.Invoke(new object[0]) as T;
            }
            catch (Exception e)
            {
                throw new InvalidOperationException("The StaticSingleton couldnt be constructed, check if the type T has a default constructor", e);
            }
        }

        private StaticAllocator()
        { } 
        #endregion

        /// <summary>
        /// The static allocator Instance property returns the instance created on class loading.
        /// </summary>
        /// <remarks>This means that the singleton is instantiated at the moment in which a class has a reference to that type even if it never calls the Instance method.</remarks>
        public override T Instance
        {
            get { return instance; }
        }
    }
}
