using System;
using Microsoft.IdentityModel.Claims;

namespace Makolab.Fractus.Kernel.HelperObjects
{
    /// <summary>
    /// Class representing logged user. Contains his ID and permissions.
    /// </summary>
    public class User
    {
        /// <summary>
        /// Current user id
        /// </summary>
        private Guid userId;

        /// <summary>
        /// Gets current user id
        /// </summary>
        public Guid UserId
        { get { return this.userId; } }

		public string UserName { get; set; }

        public Guid BranchId { get; set; }

        public Guid CompanyId { get; set; }

        public string PermissionProfile { get; set; }

        public IClaimsPrincipal Principal { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="User"/> class.
        /// </summary>
        /// <param name="userId">User id</param>
        public User(Guid userId)
        {
            this.userId = userId;
        }
    }
}
