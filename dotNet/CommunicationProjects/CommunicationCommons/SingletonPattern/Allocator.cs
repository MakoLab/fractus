namespace Common.Patterns.Singleton
{
    #region Using directives

    using System;

    #endregion

    /// <summary>
    /// The allocator is the object that is able to create the real instance of the Singleton and the one that handles the creation policy.
    /// </summary>
    /// <typeparam name="T">Type of singleton object.</typeparam>
    /// <remarks>
    /// Allocators are special objects that must have default parameterless constructors and the assembly that contains them must have private reflection security permissions.<br/>
    /// For more information about Allocator Policies and Generic Singletons please refer to the "Modern C++ Design: Generic Programming and Design Patterns Applied" from Andrei Alexandrescu.
    /// </remarks>
    public abstract class Allocator<T> : IDisposable ////where T : class
    {
        /// <summary>
        /// The parameterless protected Constructor.
        /// </summary>
        protected Allocator()
        { }

        /// <summary>
        /// The property returns the only instance of the Singleton Object in question.
        /// </summary>
        /// <remarks>This property implementation must enforce the Single Object property of Singletons throwing an exception.</remarks>
        public abstract T Instance { get; }

        /// <summary>
        /// The implementation of the IDisposable interface.
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
        protected virtual void Dispose(bool disposing) { }
    }
}
