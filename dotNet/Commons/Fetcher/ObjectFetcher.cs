using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;

namespace Makolab.Fractus.Commons.Fetcher
{
    /// <summary>
    /// Class that feches object using specified command.
    /// </summary>
    public class ObjectFetcher
    {
        /// <summary>
        /// Assembly that called current assembly.
        /// </summary>
        private Assembly callingAssembly;

        /// <summary>
        /// Fetches the specified object from parent.
        /// </summary>
        /// <param name="parent">The parent object that will act as a starting point.</param>
        /// <param name="command">The command that describes what object to fetch.</param>
        /// <returns>Fetched object.</returns>
        public object Fetch(object parent, string command)
        {
            this.callingAssembly = Assembly.GetCallingAssembly();
            ICollection<ICommand> commands = this.ParseCommands(command);
            
            if (commands.Count == 0)
                throw new ArgumentException("No commands.");

            object lastParent = parent;

            foreach (ICommand cmd in commands)
            {
                lastParent = cmd.Execute(lastParent);
            }

            return lastParent;
        }

        /// <summary>
        /// Creates the <see cref="ICommand"/> from the specified command text.
        /// </summary>
        /// <param name="commandText">The command text.</param>
        /// <returns>Created <see cref="ICommand"/>.</returns>
        private ICommand CreateCommand(string commandText)
        {
            if (commandText[0] == '{')
                return new StaticClassCommand(commandText, this.callingAssembly);
            else if (commandText.Contains('('))
                return new MethodCommand(commandText);
            else
                return new FieldPropertyCommand(commandText);
        }

        /// <summary>
        /// Changes the index invocations into method invocations in command.
        /// </summary>
        /// <param name="command">The command to change.</param>
        /// <returns>Changed command.</returns>
        private string ChangeIndexersToMethods(string command)
        {
            StringBuilder sb = new StringBuilder();

            int iLastIndex = 0;
            bool wasOpeningQuotationMark = false;

            for (int i = 0; i < command.Length; i++)
            {
                if (command[i] == '[' && !wasOpeningQuotationMark)
                {
                    sb.Append(command.Substring(iLastIndex, i - iLastIndex));
                    sb.Append(".get_Item(");
                    iLastIndex = i + 1;
                }
                else if (command[i] == ']' && !wasOpeningQuotationMark)
                {
                    sb.Append(command.Substring(iLastIndex, i - iLastIndex));
                    sb.Append(")");
                    iLastIndex = i + 1;
                }
                else if (command[i] == '"' && command[i - 1] != '\\' && !wasOpeningQuotationMark)
                    wasOpeningQuotationMark = true;
                else if (command[i] == '"' && command[i - 1] != '\\' && wasOpeningQuotationMark)
                    wasOpeningQuotationMark = false;
            }

            if (iLastIndex < command.Length)
            {
                sb.Append(command.Substring(iLastIndex, command.Length - iLastIndex));
            }

            return sb.ToString();
        }

        /// <summary>
        /// Parses the commands and returns a collection of <see cref="ICommand"/>.
        /// </summary>
        /// <param name="command">The command to parse.</param>
        /// <returns>Collection of parsed <see cref="ICommand"/>.</returns>
        private ICollection<ICommand> ParseCommands(string command)
        {
            List<ICommand> commands = new List<ICommand>();

            int iLastIndex = -1;
            bool wasOpeningBracket = false;
            bool wasClosingBracket = false;

            command = this.ChangeIndexersToMethods(command);

            for (int i = 0; i <= command.Length; i++)
            {
                if (i == command.Length || command[i] == '.')
                {
                    if (wasOpeningBracket == false || (wasClosingBracket == true && 
                        (i == command.Length || command[i] == '.' && ((command[i-1] == ')' || command[i-1] == ']') || command[i-1] == '}'))))
                    {
                        string commandText = command.Substring(iLastIndex + 1, i - iLastIndex - 1);
                        ICommand cmd = this.CreateCommand(commandText);
                        commands.Add(cmd);
                        iLastIndex = i;
                        wasClosingBracket = false;
                        wasOpeningBracket = false;
                    }
                }
                else if (command[i] == '(' || command[i] == '{')
                    wasOpeningBracket = true;
                else if (command[i] == ')' || command[i] == '}')
                    wasClosingBracket = true;
            }

            return commands;
        }
    }
}
