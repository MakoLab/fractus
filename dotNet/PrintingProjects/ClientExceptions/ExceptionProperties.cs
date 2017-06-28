using System;
using System.Collections.Generic;
using System.Text;
using System.Reflection;

namespace Makolab.Fractus.Commons
{
    public class ExceptionProperties
    {
        public PropertyInfo MessageTypeProperty;
        public PropertyInfo IdProperty;
        public PropertyInfo MessageTemplateNameProperty;
        public PropertyInfo ParametersProperty;

        private Exception source;
        public Exception Source
        {
            get { return this.source; }
        }

        public string Id
        {
            get
            {
                return (string)this.IdProperty.GetValue(this.Source, null);
            }
        }

        public string MessageTemplateName
        {
            get
            {
                return (string)this.MessageTemplateNameProperty.GetValue(this.Source, null);
            }
        }

        public ICollection<string> Parameters
        {
            get
            {
                return (ICollection<string>)this.ParametersProperty.GetValue(this.Source, null);
            }
        }

        public ExceptionMessageType MessageType
        {
            get
            {
                if (this.MessageTypeProperty == null) return ExceptionMessageType.Extended;
                else return (ExceptionMessageType) Enum.Parse(typeof(ExceptionMessageType), (string)this.MessageTypeProperty.GetValue(this.Source, null));
            }
        }

        public ExceptionProperties(Exception exception)
        {
            if (exception == null) throw new ArgumentNullException("exception");

            this.source = exception;
            Type excType = exception.GetType();
            this.IdProperty = excType.GetProperty("Id", BindingFlags.Public | BindingFlags.Instance);
            this.MessageTemplateNameProperty = excType.GetProperty("MessageTemplateName", BindingFlags.Public | BindingFlags.Instance);
            this.ParametersProperty = excType.GetProperty("Parameters", BindingFlags.Public | BindingFlags.Instance);
            this.MessageTypeProperty = excType.GetProperty("MessageType", BindingFlags.Public | BindingFlags.Instance);
        }
    }
}
