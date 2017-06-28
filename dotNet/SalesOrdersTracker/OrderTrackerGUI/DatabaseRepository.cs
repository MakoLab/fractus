using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using OrderTrackerGUI.Models;
using System.Data.SqlClient;
using System.Data;
using System.Xml.Linq;
using System.Security.Cryptography;
using System.Text;

namespace OrderTrackerGUI
{
    public class DatabaseRepository
    {
        protected string connectionString;
        protected DatabaseHelper db;

        public DatabaseRepository(string connectionString)
        {
            this.connectionString = connectionString;
            this.db = new DatabaseHelper(this);
        }

        #region DatabaseRepository Members

        public SqlConnection GetOpenedConnection()
        {
            SqlConnection c = new SqlConnection(this.connectionString);
            c.Open();
            return c;
        }

        #endregion

        /// <summary>
        /// Validates user login and password
        /// Creates <see cref="User"/> object for logged user
        /// </summary>
        /// <param name="login">The login.</param>
        /// <param name="password">The password.</param>
        /// <returns>
        /// 	<see cref="User"/> object if login is successful; otherwise, <c>null</c>.
        /// </returns>
        public User Login(string login, string password)
        {
            return Login(new User { Login = login, Password = password });
        }

        public User Login(User userToLogin)
        {
			XElement xmlParam = XElement.Parse(
				String.Format(@"<root><login>{0}</login></root>", userToLogin.Login, userToLogin.Password));
			using (SqlDataReader reader = db.ExecuteStoreProcedure("custom.p_SykomatOrdertrackerLogin", 
				db.CreateSqlParameter("xmlValue", SqlDbType.Xml, db.CreateSqlXml(xmlParam))))
            {
				return reader.Read() ? CreateUser(reader, userToLogin) : null;
            }         
        }

		private User CreateUser(SqlDataReader reader, User userToLogin)
		{
			string dbPass = reader.GetString(1);
			dbPass = BitConverter.ToString(new SHA256Managed().ComputeHash(Encoding.UTF8.GetBytes(dbPass)))
					.ToLowerInvariant().Replace("-", String.Empty);
			if (dbPass == null || dbPass != userToLogin.Password)
				return null;
			User user = new User()
			{
				Id = reader.GetGuid(0),
				Login = userToLogin.Login,
				Password = userToLogin.Password
			};
			return user;
		}
    }
}