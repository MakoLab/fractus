package com.makolab.components.catalogue
{
			import mx.controls.CheckBox;
			import mx.controls.treeClasses.TreeItemRenderer;
			import flash.events.MouseEvent;
			import mx.controls.Alert;
			import data.FractusKernelService;
			import mx.rpc.AbstractOperation;
			import mx.rpc.events.ResultEvent;
			import mx.rpc.events.FaultEvent;
			import mx.controls.Tree;
			import mx.collections.ICollectionView
			import mx.controls.treeClasses.ITreeDataDescriptor
			import mx.collections.*;
			import mx.controls.treeClasses.*;
			import mx.events.FlexEvent;
			
			
			
			
			public class GroupTreeRenderer extends TreeItemRenderer
			{
				
				public var myCheckBox:CheckBox;
				private var selectCheckbox:Boolean = false;
				
				public function GroupTreeRenderer()
				{
					super();
					this.addEventListener(FlexEvent.CREATION_COMPLETE,setCheckBoxBinder)
				}				
				
				
				private function setCheckBoxBinder(event:FlexEvent):void
				{
					var currentNodeXMLList:Object = this.data;
					
					if(currentNodeXMLList.@select==true)
					{
						myCheckBox.selected = true;											
					}
					else
					{	
						myCheckBox.selected = false;									
					}
					
				//    myCheckBox.selected = (Boolean)(currentNodeXMLList.@select);
				}
				
				override protected function createChildren():void
				{
					super.createChildren();			
					this.myCheckBox = new CheckBox();
					this.myCheckBox.setStyle("verticalAlign", "middle");		
					this.myCheckBox.addEventListener(MouseEvent.CLICK, listenerFunction);
					this.addChild(this.myCheckBox);
				}    		
	
    			
				
				override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
				{
				   super.updateDisplayList(unscaledWidth, unscaledHeight);			    
				  
				   if(super.data)
				   {
				      if (super.icon != null)
				      {
				         myCheckBox.x = super.icon.x;
				         myCheckBox.y = 2;
				         super.icon.x = myCheckBox.x + myCheckBox.width + 17;
				         super.label.x = super.icon.x + super.icon.width + 3;
				      }
				      else
				      {
				         myCheckBox.x = super.label.x;
				         myCheckBox.y = 2;
				         super.label.x = myCheckBox.x + myCheckBox.width + 17;
				      }
				      
				   }			
				   
				} 
				
				
				private function listenerFunction(event:MouseEvent):void
				{
					
					var tree:GroupTree = event.currentTarget.parent.owner;					
					var childItem:Object;
					var childItems:Object;
					var cursor:IViewCursor;
					
					
					var parentItem:Object = tree.getParentItem(this.data)
					var descriptor:ITreeDataDescriptor = tree.dataDescriptor;		
					
					if(parentItem) {
						var ob:Object = tree.itemToItemRenderer(parentItem)
						if(!ob.myCheckBox.selected) {
							ob.myCheckBox.dispatchEvent(new MouseEvent(MouseEvent.CLICK,true,false))
						}
					}
					
					if(!this.myCheckBox.selected) {
						this.unSelect(this.data,tree);
					}
					else
					{
					//	Alert.show("ok1");
						this.Select(this.data,tree);						
					}	
										
				}
				
				private function Select(object:Object,tree:GroupTree):void
				{
					object.@select="true";
				}
				
				private function unSelect(object:Object,tree:GroupTree):void {
					
					var childItem:Object;
					var childItems:Object;
					var cursor:IViewCursor;
					var descriptor:ITreeDataDescriptor = tree.dataDescriptor;
					
					object.@select="false"
					
					var ob:Object;
					if(descriptor.hasChildren(object)) {
						if(!this.myCheckBox.selected) {
							childItems = descriptor.getChildren(object);
							if (childItems){
								cursor = childItems.createCursor();
								while (!cursor.afterLast){
									childItem = cursor.current;
									ob = tree.itemToItemRenderer(childItem)
									if(ob) {
										if(ob.myCheckBox.selected) {
											ob.data.@select="false"
											ob.myCheckBox.selected=false
											this.unSelect(childItem,tree);
										}
									} else {
										this.unSelectHidden(XML(childItem));
									}
									cursor.moveNext();
								}
							}
						}
					} else {
						ob = tree.itemToItemRenderer(object)
						if(ob) {
							if(ob.myCheckBox.selected) {
								ob.myCheckBox.selected=false;
							}
						} else {
							this.unSelectHidden(XML(object));
						}
					}
				}
				
				private function unSelectHidden(xml:XML):void {
					xml.@select="false"
					var children:XMLList = xml.children()
					for(var i:int=0;i<children.length();i++) {
						unSelectHidden(children[i])
					}
					
				}	
			}	
}