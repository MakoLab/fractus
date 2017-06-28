using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Communication
{
    /// <summary>
    /// Manages creation of <see cref="AppDomain"/>
    /// </summary>
    public interface IDomainCreator
    {
        /// <summary>
        /// Creates the application domain.
        /// </summary>
        /// <returns>Created application domain.</returns>
        AppDomain CreateDomain();
    }
}
