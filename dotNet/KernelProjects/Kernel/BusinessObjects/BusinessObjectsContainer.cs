using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Interfaces;
using Makolab.Fractus.Kernel.BusinessObjects.Documents;
using Makolab.Fractus.Kernel.Attributes;
using System;
using Makolab.Fractus.Kernel.BusinessObjects.Dictionaries;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
    /// <summary>
    /// Base class that manages collection of <see cref="BusinessObject"/> attached to any parent <see cref="BusinessObject"/>.
    /// </summary>
    /// <typeparam name="T">Type of collection's children.</typeparam>
    public abstract class BusinessObjectsContainer<T> : ISerializableBusinessObjectContainer, IEnumerable<T> where T : class, IBusinessObject
    {
        /// <summary>
        /// Gets or sets the collection of <see cref="BusinessObject"/>.
        /// </summary>
        public ICollection<T> Children { get; private set; }

        /// <summary>
        /// <see cref="BusinessObject"/> whos this collection belongs to.
        /// </summary>
        protected BusinessObject Parent { get; set; }

        /// <summary>
        /// Child's name in xml.
        /// </summary>
        protected string ChildNodeName { get; set; }

		/// <summary>
		/// Checks if Collection Has Any Element
		/// </summary>
		public bool HasChildren
		{
			get { return this.Children != null && this.Children.Count > 0; }
		}

		/// <summary>
        /// Gets or sets the alternate version of the <see cref="BusinessObjectsContainer&lt;T&gt;"/>. For new <see cref="BusinessObjectsContainer&lt;T&gt;"/> it references to its old version and for the old <see cref="BusinessObjectsContainer&lt;T&gt;"/> version it references to its new <see cref="BusinessObjectsContainer&lt;T&gt;"/> version.
        /// </summary>
        public BusinessObjectsContainer<T> AlternateVersion { get; protected set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="BusinessObjectsContainer&lt;T&gt;"/> class with a specified <see cref="BusinessObject"/> to attach to, collection xml node name and child xml node name.
        /// </summary>
        /// <param name="parent"><see cref="BusinessObject"/> to attach to.</param>
        /// <param name="childNodeName">Xml node name of the collection's child element.</param>
        protected BusinessObjectsContainer(BusinessObject parent, string childNodeName)
        {
            this.Parent = parent;
            this.ChildNodeName = childNodeName;

            this.Children = new List<T>();
        }

        /// <summary>
        /// Creates new child according to the contractor's defaults and attaches it to the parent <see cref="BusinessObject"/>.
        /// </summary>
        /// <returns>A new child.</returns>
		public virtual T CreateNew()
		{
			T bo = (T)Activator.CreateInstance(typeof(T), new object[] { this.Parent });
			IOrderable orderable = (IOrderable)bo;
			if (orderable != null)
			{
				orderable.Order = this.Children.Count + 1;
			}
			this.Children.Add(bo);

			return bo;
		}

        /// <summary>
        /// Creates new child according to the contractor's defaults and attaches it to the parent <see cref="BusinessObject"/>.
        /// </summary>
        /// <param name="status">The status that has to be set to the newly created <see cref="BusinessObject"/>.</param>
        /// <returns>A new child.</returns>
        public T CreateNew(BusinessObjectStatus status)
        {
            T obj = this.CreateNew();
            obj.Status = status;

            return obj;
        }

        /// <summary>
        /// Validates the collection.
        /// </summary>
        public virtual void Validate()
        {
            foreach (T child in this.Children)
                child.Validate();
        }

        /// <summary>
        /// Checks whether any of child was deleted.
        /// </summary>
        /// <returns><c>true</c> if any of the children was deleted; otherwise <c>false</c>.</returns>
        public bool IsAnyChildDeleted()
        {
			if (this.Children.Any(child => child.Status == BusinessObjectStatus.Deleted))
				return true;

			if (this.AlternateVersion != null
				&& this.AlternateVersion.Children.Any(child => child.Status == BusinessObjectStatus.Deleted))
            {
				return true;
			}

            return false;
        }

        public void AppendChild(T child)
        {
            this.Children.Add(child);
            child.Parent = this.Parent;

            if (typeof(IOrderable).IsAssignableFrom(typeof(T)))
            {
                ((IOrderable)child).Order = this.Children.Count;
            }
        }

        /// <summary>
        /// Determines whether the collection contains new children. Check whether any children have Version set to <c>null</c>.
        /// </summary>
        /// <returns><c>true</c> if the collection contains new children; otherwise, <c>false</c>.</returns>
        public bool IsAnyChildNew()
        {
			return this.Children.Any(child => child.IsNew);
        }

        /// <summary>
        /// Determines whether the collection contains modified children.
        /// </summary>
        /// <returns><c>true</c> if the collection contains modified children; otherwise, <c>false</c>.</returns>
        public bool IsAnyChildModified()
        {
			return this.Children.Any(child => child.Status == BusinessObjectStatus.Modified);
        }

		/// <summary>
		/// Determines whether the collection contains modified, deleted or new children.
		/// </summary>
		public bool HasChanges
		{
			get
			{
				return this.IsAnyChildDeleted() || this.IsAnyChildModified() || this.IsAnyChildNew();
			}
		}

        /// <summary>
        /// Sets the children status to the specified one.
        /// </summary>
        /// <param name="status">The status to set in children.</param>
        public void SetChildrenStatus(BusinessObjectStatus status)
        {
            foreach (T child in this.Children)
                child.Status = status;
        }

        public XElement Serialize(string collectionName)
        {
            XElement element = new XElement(collectionName);

            foreach (T child in this.Children)
                element.Add(child.Serialize());

            return element;
        }

        public XElement Serialize()
        {
            return this.Serialize("collection");   
        }

        /// <summary>
        /// Updates order for <see cref="IOrderable"/> objects.
        /// </summary>
        public void UpdateOrder()
        {
            if (typeof(IOrderable).IsAssignableFrom(typeof(T)))
            {
                int i = 1;

                foreach (T child in this.Children)
                {
                    IOrderable obj = (IOrderable)child;

                    obj.Order = i++;
                }
            }
        }

        /// <summary>
        /// Sets the alternate version of the <see cref="BusinessObjectsContainer&lt;T&gt;"/> and of all its children.
        /// </summary>
        /// <param name="alternate"><see cref="BusinessObjectsContainer&lt;T&gt;"/> that is to be considered as the alternate one.</param>
        public void SetAlternateVersion(BusinessObjectsContainer<T> alternate)
        {
            this.AlternateVersion = alternate;
            alternate.AlternateVersion = this;

            foreach (T child in this.Children)
            {
                foreach (T alternateChild in alternate.Children)
                {
                    if (alternateChild.Id == child.Id)
                    {
                        child.SetAlternateVersion(alternateChild);
                        break;
                    }
                }
            }
        }

        public void Deserialize(XElement element)
        {
            this.RemoveAll();

            if (element != null)
            {
                foreach (XElement child in element.Elements(this.ChildNodeName))
                {
                    T newChild = this.CreateNew();
                    newChild.Deserialize(child);
                }

                this.UpdateOrder();
            }
        }

        /// <summary>
        /// Updates <see cref="BusinessObject.Status"/> of all its children.
        /// </summary>
        /// <param name="isNew">Value indicating whether the <see cref="BusinessObjectsContainer&lt;T&gt;"/> should be considered as the new one or the old one.</param>
        public void UpdateStatus(bool isNew)
        {
            foreach (T child in this.Children)
            {
                child.UpdateStatus(isNew);
            }
        }

        /// <summary>
        /// Saves children's changes to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public void SaveChanges(XDocument document)
        {
            foreach (T child in this.Children)
            {
                child.SaveChanges(document);
            }
        }

        /// <summary>
        /// Removes the specified child.
        /// </summary>
        /// <param name="child">The child.</param>
        public void Remove(T child)
        {
            this.Children.Remove(child);
            this.UpdateOrder();
        }

        /// <summary>
        /// Removes all children.
        /// </summary>
        public void RemoveAll()
        {
            this.Children.Clear();
        }

        /// <summary>
        /// Gets the <see cref="BusinessObject"/> with the specified key.
        /// </summary>
        public T this[int key]
        {
            get { return this.Children.ElementAt(key); }
        }

        /// <summary>
        /// Returns an enumerator that iterates through the collection.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.Collections.Generic.IEnumerator`1"/> that can be used to iterate through the collection.
        /// </returns>
        public IEnumerator<T> GetEnumerator()
        {
            return this.Children.GetEnumerator();
        }

        /// <summary>
        /// Returns an enumerator that iterates through a collection.
        /// </summary>
        /// <returns>
        /// An <see cref="T:System.Collections.IEnumerator"/> object that can be used to iterate through the collection.
        /// </returns>
        IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return this.Children.GetEnumerator();
        }
    }

	internal abstract class AbstractAttrValue<T> : BusinessObject, IOrderable where T : struct
	{
		/// <summary>
		/// Object order in the database and in xml node list.
		/// </summary>
		[XmlSerializable(XmlField = "order")]
		[Comparable]
		[DatabaseMapping(ColumnName = "order")]
		public int Order { get; set; }

		public abstract Guid FieldId { get; set; }

		/// <summary>
		/// Gets or sets the field's name
		/// </summary>
		public abstract Enum FieldName { get; set; }

		/// <summary>
		/// Gets or sets attribute value. Cannot be null.
		/// </summary>
		[XmlSerializable(XmlField = "value")]
		[Comparable]
		[DatabaseMapping(ColumnName = "value", VariableColumnName = true)]
		public XElement Value { get; set; }

		public AbstractAttrValue(BusinessObject parent) : base(parent) { }
	}

	internal abstract class AbstractAttributesContainer<U, V> : BusinessObjectsContainer<U> 
		where V : struct 
		where U : AbstractAttrValue<V>
	{
		protected AbstractAttributesContainer(BusinessObject parent, string childNodeName) : base(parent, childNodeName) { }

		public U this[Enum fieldName]
		{
			get
			{
				return this.Children.Where(a => a.FieldName == fieldName).FirstOrDefault();
			}
		}

		public U CreateNew(Enum fieldName)
		{
			var attr = this.CreateNew();
			attr.FieldName = fieldName;
			return attr;
		}

		public U GetOrCreateNew(Enum fieldName)
		{
			U result = this[fieldName];

			if (result == null)
			{
				result = this.CreateNew(fieldName);
			}

			return result;
		}
	}
}
