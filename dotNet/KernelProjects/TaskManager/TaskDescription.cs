using System;
using System.Threading;
using Makolab.Fractus.TaskManager.Tasks;

namespace Makolab.Fractus.TaskManager
{
    internal class TaskDescription
    {
        public Task Task { get; set; }
        public Thread Thread { get; set; }
        public DateTime CreationDateTime { get; private set; }

        public TaskDescription()
        {
            this.CreationDateTime = DateTime.Now;
        }
    }
}
