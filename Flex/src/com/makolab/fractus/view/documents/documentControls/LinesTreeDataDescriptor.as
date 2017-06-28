package com.makolab.fractus.view.documents.documentControls
{
	import mx.collections.ICollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.treeClasses.DefaultDataDescriptor;

	public class LinesTreeDataDescriptor extends DefaultDataDescriptor
	{
		public function LinesTreeDataDescriptor()
		{
			super();
		}
		
		override public function getChildren(node:Object, model:Object=null):ICollectionView
		{
			return new XMLListCollection(node.correctiveLines.line);
		}
		
		override public function hasChildren(node:Object, model:Object=null):Boolean
		{
			return isBranch(node, model);
		}
		
		override public function isBranch(node:Object, model:Object=null):Boolean
		{
			return (XMLList(node.correctiveLines.line).length() > 0);
		}
		
		override public function getData(node:Object, model:Object=null):Object
		{
			return node;
		}

		override public function getParent(node:Object, collection:ICollectionView, model:Object = null):Object
		{
			if (node && node.parent()) return XML(node).parent().parent();
			else return null;
		}
	}
}