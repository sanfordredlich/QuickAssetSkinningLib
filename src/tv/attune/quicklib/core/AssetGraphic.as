package tv.attune.quicklib.core
{
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import tv.attune.quicklib.util.BitmapImageUtil;


    /**
     * AssetGraphic takes an image that is set via CSS and sizes it.
     * It also allows for masking to create rounded corners.
     *
     * This is the lightest way to do this because it extends SpriteVisualElement
     * rather than UIComponent.
     *
     * Usage:
     * var assetGraphic:AssetGraphic = new AssetGraphic();
     * assetGraphic.styleName = "gradientGreen smallCorners"
     *
     * @author Sanford
     */
    public class AssetGraphic extends StyleClient
    {

        /**
         * The image to display
         */
        protected var imageAsset:DisplayObject;

        /**
         * The mask for the image
         */
        protected var imageMask:Shape;

        /**
         * The stylename to use to retrieve the image asset
         */
        private var _imageAssetStyleName:String = 'imageAsset';
        private var lastHeight:int;

        private var lastWidth:int;

        override public function set height(value:Number):void
        {
            if (height != value)
            {
                super.height = value;
                updateChildSizes(width, height);
            }
        }

        public function get imageAssetStyleName():String
        {
            return _imageAssetStyleName;
        }

        public function set imageAssetStyleName(value:String):void
        {
            if (_imageAssetStyleName != value)
            {
                _imageAssetStyleName = value;

                if (styleName)
                    setUpBitmapFromStyle();
            }
        }

        override public function set styleName(value:Object):void
        {
            if (super.styleName != value)
            {
                super.styleName = value;

                if (creationComplete)
                    setUpBitmapFromStyle();
            }
        }

        public function updateImageAsset(displayObject:DisplayObject):void
        {
            if (imageAsset && contains(imageAsset))
                removeChild(imageAsset);

            if (displayObject)
            {
                imageAsset = displayObject;
                updateImageSize(width, height);
                addChild(imageAsset);
            }
            else
            {
                imageAsset = null;
            }
        }

        override public function set width(value:Number):void
        {
            if (width != value)
            {
                super.width = value;
                updateChildSizes(width, height);
            }
        }

        override protected function createChildren():void
        {
            super.createChildren();

            if (styleName)
                setUpBitmapFromStyle();
        }

        protected function updateChildSizes(width:Number, height:Number):void
        {
            updateImageSize(width, height);
            updateMaskSize(width, height, getStyle('maskCornerRadius'));
        }

        override protected function updateDisplayList(width:Number, height:Number):void
        {
            super.updateDisplayList(width, height);

            if (width && height && (lastWidth != width || lastHeight != height))
            {
                lastWidth = width;
                lastHeight = height;

                setsSizeItself(width, height); // YOYO: added 10/16
                updateChildSizes(width, height);
            }
        }

        protected function updateImageSize(width:Number, height:Number):void
        {
            if (imageAsset)
            {
                if (imageAsset.height != height)
                    imageAsset.height = height;

                if (imageAsset.width != width)
                    imageAsset.width = width;
            }
        }

        protected function updateMaskSize(width:Number, height:Number, maskCornerRadius:Number):void
        {
            // remove any previous mask
            if (imageMask)
            {
                removeChild(imageMask);
                imageMask = null;
            }

            // add a new mask
            setUpMask(width, height, maskCornerRadius);
        }

        private function setUpBitmapFromStyle():void
        {
            var sourceData:Class = getStyle(imageAssetStyleName);

            if (sourceData)
                updateImageAsset(new sourceData);
            else
                throw new ArgumentError("Unknown asset referenced in style '"
                                        + imageAssetStyleName + "'");
        }

        private function setUpMask(width:Number, height:Number, maskCornerRadius:Number):void
        {
            if (maskCornerRadius && imageAsset && width && height)
            {
                // get the mask
                imageMask = BitmapImageUtil.getCorneredMask(width,
                                                            height,
                                                            maskCornerRadius);

                // add the mask to the display list so that its shape is drawn by the renderer
                addChildAt(imageMask, 0);

                // set the mask
                imageAsset.mask = imageMask;
            }
        }
    }
}
