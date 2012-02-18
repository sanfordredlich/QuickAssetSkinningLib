package tv.attune.quicklib.core
{
    import flash.display.DisplayObject;
    import flash.events.Event;


    /**
     * StyleClient with flags to show when size or styles have changed,
     * to be sure updateDisplayList only does work when necessary.
     *
     * Usage:
     * 	in updateDisplayList():
     *
     * 		super.updateDisplayList();
     *
     * 		if (areStylesInvalid || hasSizeChanged)
     * 		{
     * 			// your code
     * 		}
     *
     * @author Sanford
     */
    [Event(name = "creationComplete", type = "flash.events.Event")]
    public class InvalidatingStyleClient extends StyleClient
    {

        protected var areStylesInvalid:Boolean = true;

        /**
         * True if, in updateDisplayList, the height or width
         * has changed from the last call;
         */
        protected var hasSizeChanged:Boolean = false;

        protected var lastUnscaledHeight:Number;

        protected var lastUnscaledWidth:Number;

        public function validateSize():void
        {
            measure();
        }

        override protected function setStateDeclaration():void
        {
            areStylesInvalid = true;
            super.setStateDeclaration();
        }

        override protected function updateDisplayList(width:Number, height:Number):void
        {
            // note whether the size has changed, to help descendent classes 
            // only do size work if necessary.  When they do the work, they should
            // set hasSizeChanged to false
            if ((width > 0 || height > 0)
                && (width != lastUnscaledWidth || height != lastUnscaledHeight))
            {
                hasSizeChanged = true;
                lastUnscaledWidth = width;
                lastUnscaledHeight = height;
            }
            else
            {
                hasSizeChanged = false;
            }
        }

        protected function updateDisplayListResetFlags():void
        {
            areStylesInvalid = false;
            hasSizeChanged = false;
        }

        override public function set creationComplete(value:Boolean):void
        {
            super.creationComplete = value;
            dispatchEvent(new Event("creationComplete"));
        }
    }
}
