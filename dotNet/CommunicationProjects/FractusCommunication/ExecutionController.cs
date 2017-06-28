using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Commons.Communication;
using System.Xml.Linq;

namespace Makolab.Fractus.Communication
{
    public class ExecutionController
    {
        protected DBXml ChangesetBuffer { get; private set; }
        protected List<Action> CommandBuffer { get; private set; }
        private bool isDeffered;
        private IUnitOfWork unitOfWork;
        private ExecutionController eagerExecution;

        public bool IsDeffered
        {
            get { return this.isDeffered; }
            set
            {
                this.isDeffered = value;
                if (this.isDeffered == true) this.eagerExecution = new ExecutionController(this.unitOfWork);
                ClearBuffers();
            }
        }

        public IUnitOfWork UnitOfWork
        {
            get { return this.unitOfWork; }
            set
            {
                this.unitOfWork = value;
                ClearBuffers();
            }
        }

        private ExecutionController(IUnitOfWork unitOfWork)
        {
            this.isDeffered = false;
            this.unitOfWork = unitOfWork;
        }

        public ExecutionController(bool isDeffered, IUnitOfWork unitOfWork)
        {
            this.isDeffered = isDeffered;

            if (isDeffered == true)
            {
                this.ChangesetBuffer = new DBXml();
                this.CommandBuffer = new List<Action>();
                this.eagerExecution = new ExecutionController(unitOfWork);
            }
        }

        public void ExecuteCommand(Action command)
        {
            if (this.isDeffered == true) this.CommandBuffer.Add(command);
            else
            {
                //using (this.unitOfWork.ConnectionManager.SynchronizeConnection())
                //{
                    
                //}
                command.Invoke();
            }
        }

        public void ExecuteOperations(Action<XDocument> action, DBXml operations)
        {
            if (this.isDeffered == true) this.ChangesetBuffer.AddOrReplaceData(operations.Tables);
            else action.Invoke(operations.Xml);
        }

        public void RunDefferedActions()
        {
            if (this.isDeffered == true)
            {
                if (this.ChangesetBuffer.Tables.Count() > 0)
                {
                    DocumentRepository execRepo = new DocumentRepository(unitOfWork, this.eagerExecution);
                    //using (this.unitOfWork.ConnectionManager.SynchronizeConnection())
                    //{

                    //}
                    execRepo.ExecuteOperations(this.ChangesetBuffer);
                }

                this.CommandBuffer.ForEach(cmd => cmd.Invoke());
            }
        }

        public void ClearBuffers()
        {
            if (this.isDeffered == true)
            {
                if (this.CommandBuffer == null) this.CommandBuffer = new List<Action>();
                else if (this.CommandBuffer.Count > 0) this.CommandBuffer.Clear();
                if (this.ChangesetBuffer == null || this.ChangesetBuffer.Tables.Count() > 0) this.ChangesetBuffer = new DBXml();
            }
            else
            {
                this.CommandBuffer = null;
                this.ChangesetBuffer = null;
            }
        }
    }
}
