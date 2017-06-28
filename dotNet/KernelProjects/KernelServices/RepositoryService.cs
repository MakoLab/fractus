using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using System.Xml.Linq;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.Repository;
using Makolab.RestUpload;

namespace Makolab.Fractus.Kernel.Services
{
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
    public class RepositoryService : IRepositoryService
    {
        private static IDocumentRepository repository;

        public RepositoryService()
        {
            if (ConfigurationManager.AppSettings["repositoryMode"] != null)
            {
                RepositoryService.repository = DocumentRepositoryFactory.Create(ConfigurationManager.AppSettings["repositoryMode"],
                                                                   ConfigurationManager.AppSettings["RepositoryUrl"],
                                                                   ConfigurationManager.AppSettings["CacheFolder"], 
                                                                   false);                                                                    
            }
            else
            {
                RepositoryService.repository = DocumentRepositoryFactory.Create(Boolean.Parse(ConfigurationManager.AppSettings["SkipCachingForMainRepository"]),
                                                                   ConfigurationManager.AppSettings["RepositoryUrl"],
                                                                   ConfigurationManager.AppSettings["CacheFolder"]);
            }
        }

        public Stream PutFile(Stream input)
        {
            //this.OnEntry();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");

            SessionManager.OneTimeSession = true;
            Stream outputStream = null;

            try
            {
                var uploadedDocument = repository.AddMultipleFiles(input);
                var response = XDocument.Parse("<response />");

                foreach (var doc in uploadedDocument)
                {
                    response.Root.Add(new XElement("file", new XAttribute("oldFilename", doc.FileName),
                                                           new XAttribute("newFilename", doc.FileIdentifier)));
                }

                outputStream = new MemoryStream(Encoding.UTF8.GetBytes(response.ToString(SaveOptions.DisableFormatting)));
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:609");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            WebOperationContext.Current.OutgoingResponse.ContentType = "text/xml";
            return outputStream;
        }

        public Stream GetFile(string name)
        {
            //this.OnEntry();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");

            SessionManager.OneTimeSession = true;
            Stream outputStream = null;
            string contentType = null;

            try
            {
                return repository.Get(name).Content;
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:610");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            WebOperationContext.Current.OutgoingResponse.ContentType = contentType;
            return outputStream;
        }
    }
}
