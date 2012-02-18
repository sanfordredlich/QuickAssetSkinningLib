package tv.attune.quicklib.component
{
    import tv.attune.quicklib.core.AssetGraphic;
    import tv.attune.quicklib.core.InvalidatingStyleClient;
    import tv.attune.quicklib.core.SimpleStyleableTextField;
    import tv.attune.quicklib.util.ChildUtil;
    import tv.attune.quicklib.util.LayoutUtil;


    /**
     * Displays an icon on the left and a label on the right,
     * with a gap in between.
     *
     * @author Sanford
     */
    public class IconLabelHorizontal extends InvalidatingStyleClient
    {

        public var gap:uint = 0;
        public var iconHeight:int = 24; // big default so if somethings wrong it will show large
        public var iconStyle:String;
        public var iconWidth:int = 24; // big default so if somethings wrong it will show large
        public var labelStyle:String;
        private var _labelText:String;

        private var icon:AssetGraphic;
        private var label:SimpleStyleableTextField;

        public function get labelText():String
        {
            return _labelText;
        }

        public function set labelText(value:String):void
        {
            if (_labelText != value)
            {
                _labelText = value;

                if (label)
                {
                    label.text = _labelText;
                    measure();
                    invalidateDisplayList();
                }
            }
        }

        override protected function createChildren():void
        {
            icon = ChildUtil.createAssetGraphicChild(this, iconStyle);
            icon.height = iconHeight * 2; //YOYO, this shouldn't be right; I think it's from the bounding boxes on Chris' assets
            icon.width = iconWidth * 2;

            label = ChildUtil.createTextFieldChild(this, labelStyle);
            label.text = labelText;
        }

        override protected function measure():void
        {
            setsSizeItself(icon.width + gap + label.width, icon.height);
        }

        override protected function updateDisplayList(width:Number, height:Number):void
        {
            label.setLayoutBoundsPosition(icon.width + gap,
                                          LayoutUtil.getCenteredY(icon.height, label));
        }
    }
}
