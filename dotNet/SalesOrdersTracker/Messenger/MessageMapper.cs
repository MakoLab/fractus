using System;
using System.Data.SqlClient;

namespace Makolab.Fractus.Messenger
{
    public class MessageMapper : IMessageMapper
    {
        private DatabaseHelper helper;
        private string getMsgSp;
		private string getMsgAttachmentsSp;
        private string setSentMsgSP;
        private string setMsgErrorSP;

        public MessageMapper(string connectionString, string getMessageSP, string getMsgAttachmentSp, string messageSentSP, string messageErrorSP)
        {
            this.helper = new DatabaseHelper(connectionString);

            this.getMsgSp = getMessageSP;
			this.getMsgAttachmentsSp = getMsgAttachmentSp;
            this.setSentMsgSP = messageSentSP;
            this.setMsgErrorSP = messageErrorSP;
        }

        public Message Get()
        {
			Message msg = new Message();
            using (var reader = helper.ExecuteStoreProcedure(this.getMsgSp))
            {
                try
                {
                    if (reader.Read())
                    {
                        msg.Id = new Guid(Convert.ToString(reader["id"]));
                        msg.Body = Convert.ToString(reader["message"]);
                        msg.Subject = Convert.ToString(reader["subject"]);
                        msg.Type = Convert.ToString(reader["type"]).ParseAsEnum<MessageType>();
                        msg.Recipient = Convert.ToString(reader["recipient"]);
						msg.Sender = Convert.ToString(reader["sender"]);
                        msg.CC = Convert.ToString(reader["CC"]);
                    }
                    else return null;
                }
                finally
                {
                    reader.Close();
                }
            }
			using (var reader = helper.ExecuteStoreProcedure(this.getMsgAttachmentsSp, 
				new SqlParameter() { ParameterName = "mailId", Value = msg.Id, SqlDbType = System.Data.SqlDbType.UniqueIdentifier }))
			{
				try
				{
					if (reader.HasRows)
					{
						msg.Attachments = new System.Collections.Generic.List<MessageAttachment>();
						while (reader.Read())
						{
							MessageAttachment msgAtt = new MessageAttachment()
							{
								Id = reader.GetGuid(0),
								MessageId = reader.GetGuid(1),
								Name = reader.GetString(2),
								Content = reader.GetSqlBinary(3).Value,
								ContentType = reader.GetString(4),
							};
							msg.Attachments.Add(msgAtt);
						}
					}
				}
				finally
				{
					reader.Close();
				}
			}
			return msg;
        }

        public void Update(Message message)
        {
            var msgIdParam = helper.CreateSqlParameter("messageId", System.Data.SqlDbType.UniqueIdentifier, message.Id);
            if (message.State == MessageState.Send) helper.ExecuteNonQueryStoreProcedure(this.setSentMsgSP, msgIdParam);
            else if (message.State == MessageState.Failed)
            {
                helper.ExecuteNonQueryStoreProcedure(this.setMsgErrorSP,
                                                      msgIdParam,
                                                      helper.CreateSqlParameter("errorMessage", System.Data.SqlDbType.NVarChar, message.Error));
            }
            else if (message.State == MessageState.Postponed) return;
            else throw new InvalidOperationException(String.Format("Wiadomoœæ o id {0} ma niew³aœciwy status: {1}", message.Id, message.State));
        }
    }

}