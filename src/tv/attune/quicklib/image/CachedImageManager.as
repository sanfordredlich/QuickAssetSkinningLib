package tv.attune.quicklib.image
{
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.geom.Matrix;
    import flash.utils.Dictionary;


    /**
     * Returns a sprite containing an image in
     * the lightest possible way.
     *
     * On request, returns a CachedImage, which holds
     * a reference to this class, so that object
     * can be added to the client class during createChildren().
     *
     * When the CachedImage.imageUrl is set, it will
     * pass itself to this class so the image may be
     * loaded and drawn into the CachedImage.
     *
     * If the image has been retrieved
     * in the last X number of requests, the cached
     * version will be located and used for drawing.
     *
     * If the image is not in the cache, a new image loader
     * will be allocated and used.
     *
     * If the image fails to load, the CachedImage
     * will be updated with a "broken image" display.
     *
     * @author Sanford
     */
    public class CachedImageManager
    {
        private static const DEFAULT_MAXIMUM_CACHED_IMAGES:uint = 60;
        private static const MINIMUM_IMAGE_LOADERS:uint = 10;

        public var maximumCachedImages:int = DEFAULT_MAXIMUM_CACHED_IMAGES;

        private var cachedImageLoaderPool:Array = [];

        private var imageCache:Dictionary = new Dictionary();
        private var imageCacheKeys:Vector.<String> = new Vector.<String>();

        /**
         * Get the CachedImage.  When both its imageUrl and sizeType
         * are set, the image will be drawn into it.
         *
         * @return
         */
        public function getImage():CachedImage
        {
            var result:CachedImage = new CachedImage();
            result.addEventListener("imageReadyToLoad", onImageReadyToLoad);
            return result;
        }

        /**
         * Load the image
         */
        protected function onImageReadyToLoad(event:Event):CachedImage
        {
            var result:CachedImage = CachedImage(event.target);

            // get the image if it's cached
            var cachedImageData:BitmapData = imageCache[result.imageUrl + result.
                sizeType];

            // if we have the image, load it into a new CachedImage and return it; otherwise, get a new image
            // 	note that we can store and re-use the CachedImage objects because
            // 	each one is added as a child on the display list and would remove itself
            // 	from its previous parent when added to the new one
            if (cachedImageData)
                drawBitmap(cachedImageData, result)
            else
                loadNewImage(result);

            return result;
        }

        private function drawBitmap(bitmapData:BitmapData, cachedImage:CachedImage):void
        {
            var g:Graphics = cachedImage.graphics;

            g.clear();
            g.beginBitmapFill(bitmapData, new Matrix());
            g.drawRect(0, 0, cachedImage.width, cachedImage.height);
            g.endFill();
        }

        private function getCachedImageLoader():CachedImageLoader
        {
            var result:CachedImageLoader;

            if (cachedImageLoaderPool.length > 0)
            {
                result = cachedImageLoaderPool.pop();
            }
            else
            {
                result = new CachedImageLoader();

                // add event listeners
                result.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                result.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                result.addEventListener(Event.COMPLETE, onImageLoaded);
            }

            return result;
        }

        private function loadNewImage(cachedImage:CachedImage):void
        {
            var cachedImageLoader:CachedImageLoader = getCachedImageLoader();

            // start the image loading process
            cachedImageLoader.cachedImage = cachedImage;
        }

        private function manageCacheSize():void
        {
            if (imageCacheKeys.length >= maximumCachedImages)
            {
                var keyToDelete:String = imageCacheKeys.shift();
                delete imageCache[keyToDelete];
            }
        }

        private function onIOError(event:IOErrorEvent):void
        {
            // TODO: show broken image icon and log the error
            trace("ERROR: " + event);
        }

        /**
         * Cache the image if it loads successfully
         * @param event
         */
        private function onImageLoaded(event:Event):void
        {
            var cachedImageLoader:CachedImageLoader = CachedImageLoader(event.target);
            var cachedImage:CachedImage = cachedImageLoader.cachedImage;

            // save the BitmapData into the image cache
            var key:String = cachedImage.imageUrl + cachedImage.sizeType;
            imageCache[key] = cachedImageLoader.bitmapData;
            imageCacheKeys.push(key);
            manageCacheSize();

            // if there's room, clean and save the loader into the pool
            if (cachedImageLoaderPool.length < MINIMUM_IMAGE_LOADERS)
            {
                cachedImageLoader.reset();
                cachedImageLoaderPool.push(cachedImageLoader);
            }
        }

        private function onSecurityError(event:SecurityErrorEvent):void
        {
            // TODO: show broken image icon and log the error
            trace("ERROR: " + event);
        }

        private function setSize(cachedImage:CachedImage, sizeType:String):void
        {
            cachedImage.sizeType = sizeType;
        }
    }
}
