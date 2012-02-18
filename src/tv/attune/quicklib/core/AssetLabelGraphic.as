package tv.attune.quicklib.core
{
    import mx.core.UIComponent;

    import spark.components.supportClasses.GroupBase;
    import spark.primitives.BitmapImage;
    import spark.primitives.supportClasses.GraphicElement;


    /**
     * An AssetGraphic that contains a label.
     * It expands to match the size of the label with the specified horizontal and vertical padding.
     *
     * Usage:
     * <AssetLabelGraphic text="Hi" horizontalPadding="3" verticalPadding="2" styleName="count"/>
     *
     * Where we have in CSS:
     *
     * .count {
     * 	image-asset: Embed('../asset/sampleAssets.swf#count');
     * }
     *
     * @author Sanford
     *
     */
    public class AssetLabelGraphic extends StandardStyleClient
    {
        private static const DEFAULT_HORIZONTAL_PADDING:int = 3;
        private static const DEFAULT_VERTICAL_PADDING:int = 2;

        private var _text:String;
        private var assetGraphic:AssetGraphic;
        private var hasLabelChanged:Boolean;
        private var horizontalPadding:int;
        private var textField:SimpleStyleableTextField;
        private var verticalPadding:int;

        public function get text():String
        {
            return _text;
        }

        public function set text(value:String):void
        {
            if (_text != value)
            {
                _text = value;

                if (textField)
                    textField.text = _text;

                hasLabelChanged = true;
            }
        }

        override public function set styleName(value:Object):void
        {
            super.styleName = value;

            if (textField)
                textField.styleName = value;
        }

        override protected function createChildren():void
        {
            textField = new SimpleStyleableTextField();
            assetGraphic = new AssetGraphic();

            if (styleName)
            {
                textField.styleName = styleName;
                assetGraphic.styleName = styleName;
            }

            if (text)
                textField.text = text;

            getStyles();

            addChild(assetGraphic);
            addChild(textField);
        }

        override protected function updateDisplayList(width:Number, height:Number):void
        {
            super.updateDisplayList(width, height);

            if (textField && hasLabelChanged && text && text.length)
            {
                // update the text
                textField.text = text;

                // center the text in the button
                var textHeight:int = textField.height;
                var textWidth:int = textField.width;

                assetGraphic.width = textWidth + (2 * horizontalPadding);
                assetGraphic.height = textHeight + (2 * verticalPadding);

                textField.x = horizontalPadding;
                textField.y = verticalPadding;

                // reset the flag
                hasLabelChanged = false;
            }
        }

        private function getStyles():void
        {
            horizontalPadding = getStyle("horizontalPadding") || DEFAULT_HORIZONTAL_PADDING;
            verticalPadding = getStyle("verticalPadding") || DEFAULT_VERTICAL_PADDING;
        }
    }
}
