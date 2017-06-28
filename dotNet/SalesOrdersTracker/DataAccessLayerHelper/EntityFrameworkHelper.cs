using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Objects;
using System.Data;
using System.Configuration;

namespace DataAccessLayerHelper
{
	public class EntityFrameworkHelper
	{
		private static EntityFrameworkHelper _Instance;

		public static EntityFrameworkHelper Instance
		{
			get
			{
				if (_Instance == null)
				{
					_Instance = new EntityFrameworkHelper();
				}
				return _Instance;
			}
		}

		public bool PersistEntity<EntityType>(ObjectContext objCtx, string entitySetName, EntityType newEntity) where EntityType : class
		{
			bool isNew = false;
			object oldObject = null;
			objCtx.TryGetObjectByKey(objCtx.CreateEntityKey(entitySetName, newEntity), out oldObject);
			if (oldObject == null)
			{
				objCtx.AddObject(entitySetName, newEntity);
				isNew = true;
			}
			else
			{
				objCtx.ApplyCurrentValues(entitySetName, newEntity);
			}
			objCtx.DetectChanges();
			objCtx.SaveChanges();
			return isNew;
		}

		public void InsertEntities<EntityType>(ObjectContext objCtx, string entitySetName, IEnumerable<EntityType> newEntities) where EntityType : class
		{
			foreach (EntityType entity in newEntities)
			{
				objCtx.AddObject(entitySetName, entity);
			}
			objCtx.DetectChanges();
			objCtx.SaveChanges();
		}

		public void InsertEntity<EntityType>(ObjectContext objCtx, string entitySetName, EntityType newEntity) where EntityType : class
		{
			objCtx.AddObject(entitySetName, newEntity);
			objCtx.SaveChanges();
		}

		public void UpdateEntities<EntityType>(ObjectContext objCtx, string entitySetName, List<EntityType> newEntities) where EntityType : class
		{
			foreach (EntityType entity in newEntities)
			{
				objCtx.AttachTo(entitySetName, entity);
				objCtx.ObjectStateManager.ChangeObjectState(entity, EntityState.Modified);
			}
			objCtx.SaveChanges();
		}

		public void DeleteEntity<EntityType>(ObjectContext objCtx, string entitySetName, EntityType newEntity) where EntityType : class
		{
			object oldObject = null;
			objCtx.TryGetObjectByKey(objCtx.CreateEntityKey(entitySetName, newEntity), out oldObject);
			if (oldObject != null)
			{
				objCtx.DeleteObject(oldObject);
				objCtx.SaveChanges();
			}
		}

		public ObjectContextType CreateInstance<ObjectContextType>(string appSettingsKey) where ObjectContextType : ObjectContext, new ()
		{
			if (!String.IsNullOrWhiteSpace(appSettingsKey))
			{
				var connectionStringName = ConfigurationManager.AppSettings[appSettingsKey];
				if (connectionStringName != null)
				{
					return Activator.CreateInstance(typeof(ObjectContextType), new object[] { "name=" + connectionStringName }) as ObjectContextType;
				}
			}
			return new ObjectContextType();
		}
	}
}
