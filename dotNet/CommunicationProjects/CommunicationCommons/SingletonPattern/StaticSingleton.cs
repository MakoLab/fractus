namespace Common.Patterns.Singleton
{
    /// <summary>
    /// An StaticSingleton using an StaticAllocator used just to simplify the inheritance syntax.
    /// </summary>
    public class StaticSingleton<T> : Singleton<T, StaticAllocator<T>> where T : class
    { }

}
