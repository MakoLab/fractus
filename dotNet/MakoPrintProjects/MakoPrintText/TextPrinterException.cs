using System;
using System.Collections.Generic;
using System.Text;

namespace Makolab.Printing.Text
{
    public class TextPrinterException : Exception
    {
        private const string EXCEPTION_TEMPLATE = "Makolab.Printing.Text.Exceptions.xml";

        private string id;
        public string Id
        {
            get
            {
                return this.id;
            }
            protected set
            {
                this.id = value;
            }
        }


        public string MessageTemplateName
        {
            get { return EXCEPTION_TEMPLATE; }
        }

        public string MessageType
        {
            get;
            set;
        }

        private List<string> parameters;
        public ICollection<string> Parameters
        {
            get { return this.parameters; }
        }

        public TextPrinterException(String message)
            : base(message)
        {
            this.MessageType = "Simple";
        }

        public TextPrinterException(TextExceptionId id)
        {
            this.id = id.ToString();
            this.MessageType = "Extended";
        }

        public TextPrinterException(TextExceptionId id, params string[] list)
        {
            this.id = id.ToString();
            this.AddParams(list);
            this.MessageType = "Extended";
        }   

        public TextPrinterException(TextExceptionId id, Exception innerException) : base(id.ToString(), innerException)
        {
            
            this.id = id.ToString();
            this.MessageType = "Extended";
        }

        public TextPrinterException(TextExceptionId id, Exception innerException, params string[] list)
            : base(id.ToString(), innerException)
        {
            this.id = id.ToString();
            this.AddParams(list);
            this.MessageType = "Extended";

        }

        protected void AddParams(params string[] list)
        {
            if (list != null)
            {
                this.parameters = new List<string>(list.Length);

                foreach (string param in list)
                    this.parameters.Add(param);
            }
        }

    }
}
