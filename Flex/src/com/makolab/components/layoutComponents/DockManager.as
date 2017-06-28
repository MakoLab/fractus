package com.makolab.components.layoutComponents
{
	
    /**
    * Dispatched when a configuration XML changes.
    */
    [Event(name="configurationChange", type="flash.events.Event")]
	
	/**
	 * <code>DockManager</code> lets you layout given dock panels in given dock containers persuant to configuration XML and generate configuration XML persuant to current dock panels layout.
	 * 
	 * @author Tomek
	 * @see DockingVBox
	 * @see DockPanel
	 */ 	
	public class DockManager
	{
		public function DockManager()
		{
		}
		
		private var _configuration:XML = 	<root>
											  <dockObject>
											    <name>do1</name>
											    <parent>dc3</parent>
											    <index>2</index>
											    <properties/>
											  </dockObject>
											  <dockObject>
											    <name>do2</name>
											    <parent>dc1</parent>
											    <index>0</index>
											    <properties/>
											  </dockObject>
											</root>;
		/**
		 * Set of dock elemnts in format {<i>name</i> : <i>reference</i>};
		 * 
		 * @see #dockContainers
		 */		
		[Bindable]
		public var dockObjects:Object = null;
		/**
		 * Set of dock containers in format {<i>name</i> : <i>reference</i>};
		 * 
		 * @see #dockObjects
		 */	
		[Bindable]
		public var dockContainers:Object = null;
		/**
		 * Layout configuration. Contains a list of dock elements with configuration: <br/>
		 * 1. <i>name</i> - element's id property<br/>
		 * 2. <i>parent</i> - the container, that an element belongs to<br/>
		 * 3. <i>index</i> - an index in the DockContainer instance<br/>
		 * 4. <i>properties</i> - any supported <code>DisplayObject</code>'s property.
		 * @example
		 * <pre>
		 * &lt;root&gt;
		 *		&lt;dockObject&gt;
		 *		  &lt;name&gt;myDockObject1&lt;/name&gt;
		 *		  &lt;parent&gt;myDockContainer2&lt;/parent&gt;
		 *		  &lt;index&gt;2&lt;/index&gt;
		 *		  &lt;properties&gt;
		 *		    &lt;height&gt;200&lt;/height&gt;
		 *		  &lt;/properties&gt;
		 *		&lt;/dockObject&gt;
		 *		&lt;dockObject&gt;
		 *		  &lt;name&gt;myDockObject2&lt;/name&gt;
		 *		  &lt;parent&gt;myDockContainer1&lt;/parent&gt;
		 *		  &lt;index&gt;0&lt;/index&gt;
		 *		  &lt;properties/&gt;
		 *		&lt;/dockObject&gt;
		 *	&lt;/root&gt;
		 * </pre>
		 * 
		 */
		public function set configuration(value:XML):void
		{
			_configuration = value;
		}
		/**
		 * @private
		 */
		public function get configuration():XML
		{
			return _configuration;
		}
		/**
		 * Layouts components given in the <code>dockObjects</code> property in the containers given in the <code>dockContainers</code> property.
		 */
		public function getState():void
		{
			if(!dockContainers || !dockObjects)return;
			for each(var node:XML in configuration.*){
				if(dockContainers[node.parent] && dockObjects[node.name] && dockContainers[node.parent].getChildAt(node.index) !== dockObjects[node.name]){
					dockContainers[node.parent].addChildAt(dockObjects[node.name],node.index);
					for each(var p:XML in node.properties.*){
						dockObjects[node.name][p.name()] = p.*;
					}
				}
			}
		}
		
		/**
		 * Creates a configuration XML persuant to current layout of dock elements given in the <code>dockObjects</code> property and containers given in the <code>dockContainers</code> property and dispatches the <code>configurationChange</code> event.
		 */
		public function saveState():void
		{
			if(!dockContainers || !dockObjects)return;
			var stateConfiguration:XML = <root/>;
			for(var o:String in dockObjects){
				for(var c:String in dockContainers){
					var node:XML = <dockObject><name/><parent/><index/><properties/></dockObject>;
					node.name = o;
					node.parent = c;
					node.index = dockObjects[o].parent.getChildIndex(dockObjects[o]);
					node.properties.height = dockObjects[o].height;
					if(dockObjects[o].parent === dockContainers[c]){stateConfiguration.appendChild(node);break;};
				}
			}
			configuration = stateConfiguration;
		}
	}
}