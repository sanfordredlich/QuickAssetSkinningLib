package tv.attune.quicklib.image
{
    import flash.events.Event;

    import spark.core.SpriteVisualElement;


    /**
     * Used with the CachedImageManager, to which it holds a reference.
     * When the imageUrl is set, it passes itself to CachedImageManager
     * to have the result image (or a broken image icon) drawn to it.
     *
     * @author Sanford
     */
    [Event(name = "imageReadyToLoad", type = "flash.events.Event")]
    public class CachedImage extends SpriteVisualElement
    {
        public static const IMAGE_SIZE_TYPE_LARGE:String = 'large';
        public static const IMAGE_SIZE_TYPE_SMALL:String = 'small';

        // YOYO, TODO: these sizes are specific to my app and shouldn't be here in a library.
        public static const IMAGE_SIZE_LARGE_HEIGHT:int = 100;
        public static const IMAGE_SIZE_LARGE_WIDTH:int = 100;
        public static const IMAGE_SIZE_SMALL_HEIGHT:int = 100;
        public static const IMAGE_SIZE_SMALL_WIDTH:int = 100;

        public static const IMAGE_SIZE_RATIO:Number = CachedImage.IMAGE_SIZE_SMALL_WIDTH /
            CachedImage.IMAGE_SIZE_LARGE_WIDTH;

        public static const SCALE_FACTOR:Number = 1.30;

        public static function getHeightFromSizeType(sizeType:String):Number
        {
            var result:Number;

            switch (sizeType)
            {
                case IMAGE_SIZE_TYPE_LARGE:
                    result = IMAGE_SIZE_LARGE_HEIGHT;
                    break;

                case IMAGE_SIZE_TYPE_SMALL:
                    result = IMAGE_SIZE_SMALL_HEIGHT;
                    break;

                default:
                    throw new ArgumentError();
            }

            return result;
        }

        public static function getWidthFromSizeType(sizeType:String):Number
        {
            var result:Number;

            switch (sizeType)
            {
                case IMAGE_SIZE_TYPE_LARGE:
                    result = IMAGE_SIZE_LARGE_WIDTH;
                    break;

                case IMAGE_SIZE_TYPE_SMALL:
                    result = IMAGE_SIZE_SMALL_WIDTH;
                    break;

                default:
                    throw new ArgumentError();
            }

            return result;
        }

        private var _imageUrl:String;

        /**
         * See CachedImageManager
         */
        private var _sizeType:String;

        public function get imageUrl():String
        {
            return _imageUrl;
        }

        public function set imageUrl(value:String):void
        {
            _imageUrl = value;
            checkIfReadyToLoad();
        }

        public function get sizeType():String
        {
            return _sizeType;
        }

        public function set sizeType(value:String):void
        {
            _sizeType = value;

            switch (_sizeType)
            {
                case IMAGE_SIZE_TYPE_SMALL:
                    height = IMAGE_SIZE_SMALL_HEIGHT;
                    width = IMAGE_SIZE_SMALL_WIDTH;
                    break;

                case IMAGE_SIZE_TYPE_LARGE:
                    height = IMAGE_SIZE_LARGE_HEIGHT;
                    width = IMAGE_SIZE_LARGE_WIDTH;
                    break;

                default:
                    throw new ArgumentError();
            }

            checkIfReadyToLoad();
        }

        private function checkIfReadyToLoad():void
        {
            if (sizeType != null && imageUrl != null)
                dispatchEvent(new Event("imageReadyToLoad"));
        }
    }
}
