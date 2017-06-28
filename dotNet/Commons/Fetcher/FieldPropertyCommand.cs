using System;
using System.Reflection;

namespace Makolab.Fractus.Commons.Fetcher
{
    /// <summary>
    /// Class that executes commands for fields and properties.
    /// </summary>
    internal class FieldPropertyCommand : ICommand
    {
        /// <summary>
        /// Gets the command text.
        /// </summary>
        public string Text { get; private set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="FieldPropertyCommand"/> class.
        /// </summary>
        /// <param name="commandText">The command text.</param>
        public FieldPropertyCommand(string commandText)
        {
            this.Text = commandText;
        }

        /// <summary>
        /// Executes the command using specified parent.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <returns>Object that is a result of execution.</returns>
        public object Execute(object parent)
        {
            if (parent == null)
                throw new ArgumentException("parent cannot be null.", "parent");

            Type parentType = parent as Type;

            if (parentType == null)
                parentType = parent.GetType();

            FieldInfo field = parentType.GetField(this.Text, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static | BindingFlags.Instance);

            if (field != null)
                return field.GetValue(parent);

            PropertyInfo property = parentType.GetProperty(this.Text, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static | BindingFlags.Instance);

            if (property != null)
                return property.GetValue(parent, null);

            return null;
        }
    }
}
