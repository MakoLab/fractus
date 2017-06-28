using System;
using System.Reflection;

namespace Makolab.Fractus.Commons.Fetcher
{
    /// <summary>
    /// Class that executes commands for static classes.
    /// </summary>
    internal class StaticClassCommand : ICommand
    {
        /// <summary>
        /// Gets the command text.
        /// </summary>
        /// <value></value>
        public string Text { get; private set; }

        /// <summary>
        /// Starting point assembly.
        /// </summary>
        private Assembly assembly;

        /// <summary>
        /// Initializes a new instance of the <see cref="StaticClassCommand"/> class.
        /// </summary>
        /// <param name="commandText">The command text.</param>
        /// <param name="assembly">Starting point assembly for the command.</param>
        public StaticClassCommand(string commandText, Assembly assembly)
        {
            if (commandText[0] == '{')
                this.Text = commandText.Substring(1, commandText.Length - 2);
            else
                this.Text = commandText;

            this.assembly = assembly;
        }

        /// <summary>
        /// Executes the command using specified parent.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <returns>Object that is a result of execution.</returns>
        public object Execute(object parent)
        {
            if (parent != null)
                throw new ArgumentException("parent must be null.", "parent");
            
            Type t = this.assembly.GetType(this.Text);

            return t;
        }
    }
}
