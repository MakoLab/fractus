namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.ServiceModel;
    //using Makolab.Commons.Communication;

    [ServiceContract(Namespace = "http://www.makolab.pl/communication/administration/2008/02/")]
    public interface ICommunicationStatusService
    {
        [OperationContract]
        Dictionary<string, string> GetDepartmentsName();

        [OperationContract]
        Dictionary<string, DepartmentStatistics> GetBasicDepartmentsStatistics();

        [OperationContract]
        DepartmentStatistics GetAdvancedDepartmentStatistics(Makolab.Commons.Communication.ServiceType service, string departmentIdentifier);

        [OperationContract]
        DepartmentStatistics GetFDirectorStatistics(string executorName);

        [OperationContract]
        string GetFDirectorLastExecutionLog(string executorName);

        [OperationContract]
        LogEntry[] GetLog();
    }
}
