using System;
using System.Collections.Generic;
using System.Reflection;

namespace Makolab.Fractus.Commons.Fetcher
{
    /// <summary>
    /// Class that executes commands for methods.
    /// </summary>
    internal class MethodCommand : ICommand
    {
        /// <summary>
        /// Gets the command text.
        /// </summary>
        /// <value></value>
        public string Text { get; private set; }

        /// <summary>
        /// Command's method name.
        /// </summary>
        private string methodName;

        /// <summary>
        /// List of method parameter types in order.
        /// </summary>
        private List<Type> methodParameterTypes = new List<Type>();

        /// <summary>
        /// List of parameter values in order.
        /// </summary>
        private List<object> methodParameterValues = new List<object>();

        /// <summary>
        /// Initializes a new instance of the <see cref="MethodCommand"/> class.
        /// </summary>
        /// <param name="commandText">The command text.</param>
        public MethodCommand(string commandText)
        {
            this.Text = commandText;
            this.methodName = this.Text.Substring(0, this.Text.IndexOf('('));
            this.ParseParameters();
        }

        /// <summary>
        /// Parses the parameters and stores them in private fields.
        /// </summary>
        private void ParseParameters()
        {
            if (this.Text.Contains("()"))
                return;

            int iFirstBracket = this.Text.IndexOf('(');
            string parameters = this.Text.Substring(iFirstBracket + 1, this.Text.Length - iFirstBracket - 2);

            int iLastPosition = -1;
            string paramType = null;
            string paramValue = null;
            bool wasTypeParsed = false;
            bool wasValueEncapsulated = false;

            for (int i = 0; i < parameters.Length; i++)
            {
                if (!wasTypeParsed)
                {
                    if (parameters[i] == '(')
                        iLastPosition = i;
                    else if (parameters[i] == ')')
                    {
                        paramType = parameters.Substring(iLastPosition + 1, i - iLastPosition - 1);
                        wasTypeParsed = true;
                        iLastPosition = i + 1;

                        if (parameters[iLastPosition] == '"')
                        {
                            wasValueEncapsulated = true;
                            iLastPosition++;
                            i = iLastPosition;
                        }
                    }
                }
                else //parse value
                {
                    if (!wasValueEncapsulated && (parameters[i] == ',' || i == (parameters.Length - 1)))
                    {
                        int len = i - iLastPosition;

                        if (i == (parameters.Length - 1))
                            len++;

                        paramValue = parameters.Substring(iLastPosition, len);
                        wasTypeParsed = false;

                        Type t = Type.GetType(paramType);
                        object val = Convert.ChangeType(paramValue, t);

                        this.methodParameterTypes.Add(t);
                        this.methodParameterValues.Add(val);
                    }
                    else if (wasValueEncapsulated && ((parameters[i] == '"' && parameters[i - 1] != '\\')
                        || i == (parameters.Length - 1)))
                    {
                        int len = i - iLastPosition;

                        paramValue = parameters.Substring(iLastPosition, len);
                        paramValue = paramValue.Replace("\\\"", "\"");

                        wasTypeParsed = false;

                        Type t = Type.GetType(paramType);
                        object val = Convert.ChangeType(paramValue, t);

                        this.methodParameterTypes.Add(t);
                        this.methodParameterValues.Add(val);
                    }
                }
            }
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

            MethodInfo method = parentType.GetMethod(this.methodName, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static | BindingFlags.Instance, null, this.methodParameterTypes.ToArray(), null);

            if (method != null)
                return method.Invoke(parent, this.methodParameterValues.ToArray());
            else
                return null;
        }
    }
}
