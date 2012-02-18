package tv.attune.quicklib.core
{


    public interface ILayoutStyleClient
    {

        /**
         *  Calling this method results in a call to the component's
         *  <code>validateDisplayList()</code> method
         *  before the display list is rendered.
         *
         *  <p>For components that extend UIComponent, this implies
         *  that <code>updateDisplayList()</code> is called.</p>
         *
         */
        function invalidateDisplayList():void;
        /**
         *  Calling this method results in a call to the component's
         *  <code>validateProperties()</code> method
         *  before the display list is rendered.
         *
         *  <p>For components that extend UIComponent, this implies
         *  that <code>commitProperties()</code> is called.</p>
         */
        function invalidateProperties():void;

        /**
         *  Calling this method results in a call to the component's
         *  <code>validateSize()</code> method
         *  before the display list is rendered.
         *
         *  <p>For components that extend UIComponent, this implies
         *  that <code>measure()</code> is called, unless the component
         *  has both <code>explicitWidth</code> and <code>explicitHeight</code>
         *  set.</p>
         */
        function invalidateComponentSize():void;

        /**
         *  Validates the position and size of children and draws other
         *  visuals.
         *  If the <code>LayoutManager.invalidateDisplayList()</code> method is called with
         *  this ILayoutStyleClient, then the <code>validateDisplayList()</code> method
         *  is called when it's time to update the display list.
         */
        function validateDisplayList():void;

        /**
         *  Validates and updates the properties and layout of this object
         *  by immediately calling <code>validateProperties()</code>,
         *  <code>validateSize()</code>, and <code>validateDisplayList()</code>,
         *  if necessary.
         *
         *  <p>When properties are changed, the new values do not usually have
         *  an immediate effect on the component.
         *  Usually, all of the application code that needs to be run
         *  at that time is executed. Then the LayoutManager starts
         *  calling the <code>validateProperties()</code>,
         *  <code>validateSize()</code>, and <code>validateDisplayList()</code>
         *  methods on components, based on their need to be validated and their
         *  depth in the hierarchy of display list objects.</p>
         *
         *  <p>For example, setting the <code>width</code> property is delayed, because
         *  it may require recalculating the widths of the object's children
         *  or its parent.
         *  Delaying the processing also prevents it from being repeated
         *  multiple times if the application code sets the <code>width</code> property
         *  more than once.
         *  This method lets you manually override this behavior.</p>
         *
         */
        function validateNow():void;

        /**
         *  Validates the properties of a component.
         *  If the <code>LayoutManager.invalidateProperties()</code> method is called with
         *  this ILayoutStyleClient, then the <code>validateProperties()</code> method
         *  is called when it's time to commit property values.
         */
        function validateProperties():void;

        /**
         *  Validates the measured size of the component
         *  If the <code>LayoutManager.invalidateSize()</code> method is called with
         *  this ILayoutStyleClient, then the <code>validateSize()</code> method
         *  is called when it's time to do measurements.
         *
         *  @param recursive If <code>true</code>, call this method
         *  on the objects children.
         */
        function validateSize(recursive:Boolean = false):void;
    }
}
