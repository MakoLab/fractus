namespace Makolab.Fractus.Communication.Scripts
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Linq;
    using Makolab.Commons.Communication;

    /// <summary>
    /// Empty script implementing NullObject pattern created when communication package type is unrecognized.
    /// </summary>
    public class NullScript : ExecutingScript
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="NullScript"/> class.
        /// </summary>
        public NullScript() : base(null) { }

        /// <summary>
        /// Executes the communication package.
        /// </summary>
        /// <param name="communicationPackage">The communication package to execute.</param>
        /// <returns>
        /// 	<c>true</c> if execution succeeded; otherwise, <c>false</c>
        /// </returns>
        public override bool ExecutePackage(ICommunicationPackage communicationPackage)
        {
            this.Log.Error("Unknown xml type = " + Environment.NewLine + communicationPackage.XmlData.Content + Environment.NewLine);
            return false;
        }

    }
}
