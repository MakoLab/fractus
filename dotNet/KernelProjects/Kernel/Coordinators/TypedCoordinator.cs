using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.Mappers;

namespace Makolab.Fractus.Kernel.Coordinators
{
	public class TypedCoordinator<MapperType> : Coordinator where MapperType : Mapper
	{
		public MapperType MapperTyped
		{
			get
			{
				return (MapperType)base.Mapper;
			}
		}

		protected TypedCoordinator(bool aquireDictionaryLock, bool canCommitTransaction) : base(aquireDictionaryLock, canCommitTransaction) { }

	}
}
