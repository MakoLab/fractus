namespace Common.Patterns.Singleton
{
    /// <summary>
    /// A LazySingleton implementation using a LazyAllocator just to simplify the syntax of the Singleton inheritance.
    /// </summary>
    public class LazySingleton<T> : Singleton<T, LazyAllocator<T>> where T : class
    { }
}
