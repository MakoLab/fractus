
namespace Makolab.Fractus.Commons.Fetcher
{
    /// <summary>
    /// Provides the capabilities for an object to act as a command.
    /// </summary>
    internal interface ICommand
    {
        /// <summary>
        /// Gets the command text.
        /// </summary>
        string Text { get; }

        /// <summary>
        /// Executes the command using specified parent.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <returns>Object that is a result of execution.</returns>
        object Execute(object parent);
    }
}
