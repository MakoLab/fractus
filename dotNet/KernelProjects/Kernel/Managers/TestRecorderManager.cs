//REFACTORINDICATOR
//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text;
//using Makolab.Fractus.Kernel.Mappers;
//using Makolab.Fractus.Kernel.Managers.Logging;

//namespace Makolab.Fractus.Kernel.Managers
//{
//    public class TestRecorderManager
//    {
//        private static readonly TestRecorderManager _Instance = new TestRecorderManager();

//        public static TestRecorderManager Instance { get { return _Instance; } }

//        public void LogTestStep()
//        {
//            try
//            {
//                string command = SessionManager.VolatileElements.ClientCommand;
//                if (ConfigurationMapper.Instance.TestStepsLoggingEnabled
//                    && ConfigurationMapper.Instance.TestStepsLoggedCommands.Contains(command)
//                    && SqlConnectionManager.TestDbInstance.ConnectionString != null)
//                {
//                    try
//                    {
//                        SqlConnectionManager.TestDbInstance.InitializePrivilegedConnection(3);
//                        SqlConnectionManager.TestDbInstance.BeginTransaction();

//                        try
//                        {
//                            DependencyContainerManager.Container.Get<JournalMapper>()
//                                .LogTestStep(command, SessionManager.VolatileElements.ClientRequest,
//                                !SessionManager.VolatileElements.WasExceptionThrown);

//                            if (!ConfigurationMapper.Instance.ForceRollbackTransaction)
//                                SqlConnectionManager.TestDbInstance.CommitTransaction();
//                            else
//                                SqlConnectionManager.TestDbInstance.RollbackTransaction();
//                        }
//                        catch (Exception)
//                        {
//                            SqlConnectionManager.TestDbInstance.RollbackTransaction();
//                            throw;
//                        }
//                    }
//                    finally
//                    {
//                        //It cannot be called if Initialize was not called
//                        SqlConnectionManager.TestDbInstance.ReleasePrivilegedConnection();
//                    }
//                }
//            }
//            catch (Exception ex)
//            {
//                //Log exception and prevent from main Kernel logic be affected by this exception
//                TestRecorderExceptionLogger.Instance.Log(ex);
//            }
//        }
//    }
//}
