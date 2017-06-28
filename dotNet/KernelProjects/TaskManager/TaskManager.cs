using System;
using System.Collections.Generic;
using System.Threading;
using System.Xml.Linq;
using Makolab.Fractus.TaskManager.Tasks;

namespace Makolab.Fractus.TaskManager
{
    public class TaskManager
    {
        private static TaskManager instance = new TaskManager();

        public static TaskManager Instance
        {
            get { return TaskManager.instance; }
        }

        private Dictionary<Guid, TaskDescription> dctTasks = new Dictionary<Guid, TaskDescription>();
        private Thread cleanerThread;

        private TaskManager()
        {
            this.cleanerThread = new Thread(new ThreadStart(this.CleanUpZombieTasks));
        }

        private void CleanUpZombieTasks()
        {
            while (true)
            {
                lock (typeof(TaskManager))
                {
                    DateTime now = DateTime.Now;
                    List<Guid> entriesToDelete = new List<Guid>();

                    foreach (Guid key in this.dctTasks.Keys)
                    {
                        TaskDescription td = this.dctTasks[key];

                        if (td.CreationDateTime.Subtract(now).TotalMinutes > 15)
                        {
                            if (td.Thread.ThreadState == ThreadState.Running)
                                td.Thread.Abort();

                            entriesToDelete.Add(key);
                        }
                    }

                    foreach (Guid key in entriesToDelete)
                    {
                        this.dctTasks.Remove(key);
                    }
                }

                Thread.Sleep((int)TimeSpan.FromMinutes(15).TotalMilliseconds);
            }
        }

        public Guid CreateTask(string taskName, XElement param)
        {
            Guid taskId = Guid.NewGuid();
            Task task = null;
            Thread thread = null;

            task = (Task)Activator.CreateInstance(Type.GetType("Makolab.Fractus.TaskManager.Tasks." + taskName + ", TaskManager"), param);

            thread = new Thread(new ThreadStart(task.Start));

            lock (typeof(TaskManager))
            {
                this.dctTasks.Add(taskId, new TaskDescription() { Task = task, Thread = thread });
            }

            thread.Start();
            return taskId;
        }

        public void TerminateTask(Guid taskId)
        {
            TaskDescription td = null;

            lock (typeof(TaskManager))
            {
                if (this.dctTasks.ContainsKey(taskId))
                {
                    td = this.dctTasks[taskId];
                    this.dctTasks.Remove(taskId);
                }
            }

            if (td != null)
                td.Thread.Abort();
        }

        public XElement QueryTask(Guid taskId)
        {
            TaskDescription td = null;

            lock (typeof(TaskManager))
            {
                if (!this.dctTasks.ContainsKey(taskId))
                    //throw new InvalidOperationException("Task not found.");
                    return new XElement("root", new XElement("status", "ignored"));

                td = this.dctTasks[taskId];
            }
            
            return td.Task.Query();
        }

        public string GetResult(Guid taskId)
        {
            TaskDescription td = null;

            lock (typeof(TaskManager))
            {
				if (!this.dctTasks.ContainsKey(taskId))
                    throw new InvalidOperationException("Task not found.");

                td = this.dctTasks[taskId];

                if (td.Thread.ThreadState == ThreadState.Running)
                    throw new InvalidOperationException("Cannot get result from task that is running.");

                this.dctTasks.Remove(taskId);
            }
            
            return td.Task.GetResult();
        }
    }
}
