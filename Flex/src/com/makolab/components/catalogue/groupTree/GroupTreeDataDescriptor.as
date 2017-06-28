package com.makolab.components.catalogue.groupTree
{
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.treeClasses.DefaultDataDescriptor;

	public class GroupTreeDataDescriptor extends DefaultDataDescriptor
	{
		public function GroupTreeDataDescriptor()
		{
		}

		override public function getChildren(node:Object, model:Object=null):ICollectionView
		{
			return new XMLListCollection(node.subgroups.group);
		}
		
		override public function hasChildren(node:Object, model:Object=null):Boolean
		{
			return isBranch(node, model) && (XMLList(node.subgroups.group).length() > 0);
		}
		
		override public function isBranch(node:Object, model:Object=null):Boolean
		{
			return (node.subgroups != undefined);
		}
		
		override public function getData(node:Object, model:Object=null):Object
		{
			return node;
		}
		
		override public function addChildAt(parent:Object, newChild:Object, index:int, model:Object=null):Boolean
		{
			if (!parent)
			{
				if (index > model.length) index = model.length;
				if (model is IList) IList(model).addItemAt(newChild, index);
			}
			else
			{
				var subgroups:XML = XML(parent.subgroups);
				var prevChild:XML = subgroups.group[index];
				if (prevChild) subgroups.insertChildBefore(prevChild, newChild);
				else subgroups.appendChild(newChild);
				return true;
			}
			return true;
		}
		
		override public function removeChildAt(parent:Object, child:Object, index:int, model:Object=null):Boolean
		{
			//super.removeChildAt();
			//var subgroups:XML = XML(parent.subgroups);
			var childXML:XML = XML(child);
			//trace(childXML.childIndex())
			//trace("-----")
			//trace(model)
			//trace("-----")
			if(childXML.childIndex() != -1) {
				delete childXML.parent().children()[childXML.childIndex()];	
			} else {
				var cursor:IViewCursor = model.createCursor();
                cursor.seek(CursorBookmark.FIRST, index);
                cursor.remove();
			}
			return true;
		}

		override public function getParent(node:Object, collection:ICollectionView, model:Object = null):Object
		{
			if (node && node.parent()) return XML(node).parent().parent();
			else return null;
		}
    }
}