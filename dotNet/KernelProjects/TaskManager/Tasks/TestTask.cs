using System.Threading;
using System.Xml.Linq;

namespace Makolab.Fractus.TaskManager.Tasks
{
    internal class TestTask : Task
    {
        public TestTask(XElement param)
        {
        }

        protected override void StartProcedure()
        {
            for (int i = 0; i <= 100; i += 5)
            {
                this.Progress = i;
                Thread.Sleep(300);
            }

            this.result = "<result>DONE!</result>";
        }
    }
}
