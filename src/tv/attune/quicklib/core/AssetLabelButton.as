package tv.attune.quicklib.core
{
    import flash.events.Event;
    import flash.events.MouseEvent;


    /**
     * A button for mobile, simply two images.  Label text is centered in the button.
     * When the user presses the button it sends a mouse click.
     *
     * Usage:
     * assetLabelButton = new AssetLabelButton();
     * assetLabelButton.styleName = "smallBlue";
     *
     * Where we have in CSS:
     * core|AssetLabelButton.smallBlue {
     * 		up-skin: Embed("/tv/attune/talkbackz/asset/button_resource.swf#smallBlueUp");
     * 		down-skin: Embed("/tv/attune/talkbackz/asset/button_resource.swf#smallBlueDown");
     * 		disabled-skin: Embed("/tv/attune/talkbackz/asset/button_resource.swf#smallBlueDisable");
     * }
     *
     * @author Sanford
     *
     */
    public class AssetLabelButton extends StandardStyleClient
    {
        public function AssetLabelButton()
        {
            mouseChildren = false;
            useHandCursor = true;
        }

        private var _label:String;

        private var button:AssetButton;

        private var hasLabelChanged:Boolean;

        private var textField:SimpleStyleableTextField;

        public function get label():String
        {
            return _label;
        }

        public function set label(value:String):void
        {
            if (_label != value)
            {
                _label = value;
                hasLabelChanged = true;
            }
        }

        override protected function createChildren():void
        {
            textField = new SimpleStyleableTextField();
            button = new AssetButton();
        }

        override protected function updateDisplayList(width:Number, height:Number):void
        {
            super.updateDisplayList(width, height);

            if (hasSizeChanged)
            {
                button.width = width;
                button.height = height;
            }

            if (textField && hasLabelChanged && label && label.length)
            {
                // update the text
                textField.text = label;

                // center the label in the button
                var textHeight:int = textField.getPreferredBoundsHeight();
                var textWidth:int = textField.getPreferredBoundsWidth();

                textField.x = (width / 2) - (textWidth / 2);
                textField.y = (height / 2) - (textHeight / 2);

                // reset the flag
                hasLabelChanged = false;
            }
        }
    }
}
