using System.Threading;
using System.Configuration;
using Makolab.Fractus.Messenger.Providers;
using log4net;
using System;
namespace Makolab.Fractus.Messenger
{
    public class MessageService
    {
        private volatile bool isEnabled;
        private Thread notifier;
        private ILog logger;

        public MessengerState State { get; private set; }

        public MessageService() 
            : this(ConfigurationManager.GetSection("messenger") as MessengerConfiguration, log4net.LogManager.GetLogger(typeof(MessageService)))
        {
        }

        public MessageService(MessengerConfiguration configuration, ILog log)
            : this(configuration, log, new MessageMapper(configuration.MessageDBConnectionString, 
                                                            configuration.GetMessageStoredProcedure, 
															configuration.GetMessageAttachmentsStoredProcedure,
                                                            configuration.SetMessageTransmissionSuccessStoredProcedure, 
                                                            configuration.SetMessageTransmissionErrorStoredProcedure), 
                   new MessageProviderFactory(configuration, log))
        {            
        }

        public MessageService(MessengerConfiguration configuration, ILog log, IMessageMapper mapper, IMessageProviderFactory factory)
        {
            this.State = MessengerState.Stopped;

            this.logger = log;
            this.Configuration = configuration;
            this.ProviderFactory = factory;
            this.Mapper = mapper;
        }

        public MessengerConfiguration Configuration { get; set; }

        public IMessageProviderFactory ProviderFactory { get; set; }

        public IMessageMapper Mapper { get; set; }

        public void Start()
        {
            try
            {
                //if (this.isEnabled == true) ret
                this.State = MessengerState.Starting;
                this.isEnabled = true;
                this.notifier = new Thread(Run);
                this.notifier.Start();
                logger.Info("Uruchamianie procesu wysy³ania wiadomoœci");
            }
            catch (Exception e)
            {
                this.isEnabled = false;
                this.State = MessengerState.Stopped;
                logger.Error("Unhandled exception", e);
                throw;
            }
        }

        public void Stop()
        {
            this.State = MessengerState.Stopping;
            this.isEnabled = false;
            logger.Info("Zatrzymywanie procesu wysy³ania wiadomoœci");
        }

        public void Run()
        {
            try
            {
                this.State = MessengerState.Started;
                int waitInterval = this.Configuration.SendInterval;

                while (this.isEnabled)
                {
                    try
                    {
                        var message = this.Mapper.Get();

                        if (message != null)
                        {
                            logger.InfoFormat("Wysy³anie wiadomoœci o id {0} typu {1}.", message.Id, message.Type);
                            logger.DebugFormat("Wiadomoœæ od {0}, do {1}. Treœæ wiadomoœci: {2}", message.Sender, message.Recipient, message.Body);

                            SendMessage(message);

                            this.Mapper.Update(message);

                            if (message.State == MessageState.Send) logger.Debug("Wiadomoœc zosta³a poprawnie zapisana do bazy.");

                            waitInterval = this.Configuration.SendInterval;
                        }
                        else
                        {
                            waitInterval = this.Configuration.RetrieveMessageInterval;
                            logger.Info("Brak wiadomoœci do wys³ania.");
                        }

                        logger.Debug("Oczekiwanie na kolejn¹ wiadomoœæ");
                        Thread.Sleep(waitInterval);
                    }
                    catch (Exception e)
                    {
                        logger.Error("Unhandled exception", e);
                    }
                }
            }
            finally
            {
                this.State = MessengerState.Stopped;
            }
        }

        private void SendMessage(Message message)
        {
            if (message == null) throw new ArgumentNullException("message");

            if (ProviderFactory == null) new ArgumentNullException("ProviderFactory");

            int retryCounter = 0;

            do
            {
                if (retryCounter >= this.Configuration.ReloadMessageLimit)
                {
                    logger.InfoFormat(String.Format("Iloœæ prób wys³ania przekroczy³a {0} - nastêpuje ponowne pobranie wiadomoœci z bazy.", this.Configuration.ReloadMessageLimit));
                    message.State = MessageState.Postponed;
                    break;
                }

                if (retryCounter > 0) Thread.Sleep(this.Configuration.RetryInterval);

                message.State = MessageState.New;
				try
				{
					var provider = this.ProviderFactory.CreateProvider(message.Type);
					if (provider == null) new ArgumentNullException("provider");
					provider.SendMessage(message);

					logger.InfoFormat("Uaktualnienie statusu wiadomoœci o id {0} na {1}.", message.Id, message.State);
					if (message.State == MessageState.Failed || message.State == MessageState.Retry) logger.InfoFormat("B³¹d wysy³ania: {0}", message.Error);
				}
				catch (System.FormatException fex)
				{
					logger.Error("Format exception", fex);
					message.State = MessageState.Failed;
					message.Error = String.Format("Wyst¹pi³ b³¹d formatu: {0} {1}", Environment.NewLine, fex.ToString());
				}
				catch (System.Exception e)
				{
					// TODO jakie maja byc komunikaty zapisywane do bazy
					logger.Error("Unhandled exception", e);
					message.State = MessageState.Retry;
					message.Error = String.Format("Wyst¹pi³ nieoczekiwany b³¹d: {0} {1}", Environment.NewLine, e.ToString());
				}
                ++retryCounter;
            } while (message.State == MessageState.Retry || message.State == MessageState.Postponed || (message.State == MessageState.Failed && retryCounter >= this.Configuration.RetryLimit));
        }

    }

}