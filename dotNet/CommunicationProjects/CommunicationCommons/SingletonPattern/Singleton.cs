#region Using directives

using System;
using System.Reflection;

#endregion

namespace Common.Patterns.Singleton
{
    /// <summary>
    /// The Singleton implementation, it resorts to the allocator to enforce the creation policy.
    /// </summary>
    /// <typeparam name="T">Type of singleton object.</typeparam>
    /// <typeparam name="TAllocator">The type of the allocator.</typeparam>
    /// <remarks>
    /// Depending on the allocator selected the creation policy will change, it is up to the designer to use the creation policy that better represent the needs of the whole system.<br/>
    /// It is a very good idea to inherit from Singleton with a default allocator to simplify the type definition for the application developers, but it is not a requirement. The library already provides LazySingleton and StaticSingleton as standard types, so you can use them instead of the full descriptive version.<br/>For more information about Allocator Policies and Generic Singletons please refer to the "Modern C++ Design: Generic Programming and Design Patterns Applied" from Andrei Alexandrescu.
    /// </remarks>
    public class Singleton< T, TAllocator > : IDisposable 
        where T : class
        where TAllocator : Allocator< T >
    {
        /// <summary>
        /// Allocator of singleton object.
        /// </summary>
        protected static readonly Allocator<T> Allocator;

        /// <summary>
        /// The protected parameterless constructor used to not allow the creation of multiple Singleton classes. This property must be enforced by the singleton users.
        /// </summary>
        static Singleton()
        {
            ConstructorInfo constructor = typeof(TAllocator).GetConstructor(BindingFlags.Instance | BindingFlags.NonPublic, null, new Type[0], new ParameterModifier[0]);
            if (constructor == null)
                throw new InvalidOperationException("The allocator that you want to create doesnt have a private/protected constructor.");

            try
            {
                Allocator = constructor.Invoke(new object[0]) as Allocator<T>;
            }
            catch (Exception e)
            {
                throw new InvalidOperationException("The Singleton Allocator couldnt be constructed, check if the type Allocator has a default constructor", e);
            }
        }

        /// <summary>
        /// The Singleton implementation of the Instance method defer the creation policy to its allocator, so this method just delegate the Instance retrieval to the Instance method of the allocator.
        /// </summary>
        public static T Instance 
        {
            get { return Allocator.Instance; }
        }

        /// <summary>
        /// The standard Dispose pattern.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (disposing) Allocator.Dispose();
        }
    }
}
