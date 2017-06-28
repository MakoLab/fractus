#region Using directives

using System;
using System.Reflection;

#endregion

namespace Common.Patterns.Singleton
{
    /// <summary>
    /// A lazy allocator that creates the object the first time a reference to the singleton is required, it is thread safe using a lock over the type parameter.
    /// </summary>
    /// <typeparam name="T">Type of singleton object.</typeparam>
    public class LazyAllocator<T> : Allocator<T> where T : class
    {
        /// <summary>
        /// The constructor of the LazyAllocator
        /// </summary>
        private LazyAllocator()
        { }

        private T instance;

        /// <summary>
        /// The instance property creates the singleton object upon the first request.
        /// </summary>
        /// <remarks>The allocator ensure the thread safety using a lock and it enforces the Singleton uniqueness property.</remarks>
        public override T Instance
        {
            get
            {
                if (instance == null)
                {
                    lock (typeof(T))
                    {
                        if (instance == null)
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
                                throw new InvalidOperationException("The LazySingleton couldnt be constructed, check if the type T has a default constructor", e);
                            }
                        }
                    }
                }

                return instance;
            }
        }
    }
}
