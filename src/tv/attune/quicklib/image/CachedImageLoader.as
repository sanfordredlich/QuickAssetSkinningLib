package tv.attune.quicklib.image
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.geom.Matrix;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;

    import mx.core.mx_internal;

    // need to use mx_internal to be able to call GraphicElement.captureBitmapData()
    // to draw the BitmapImage onto our output Sprite
    use namespace mx_internal;


    /**
     * Holds a CachedImage and loads it with image data
     * specified by its imageUrl.
     *
     * When loading is complete, the image is drawn
     * to the CachedImage and a "COMPLETE" event is sent.
     *
     * @author Sanford
     */
    [Event(name = "complete", type = "flash.events.Event")]
    [Event(name = "ioError", type = "flash.events.IOErrorEvent")]
    [Event(name = "securityError", type = "flash.events.SecurityErrorEvent")]
    public class CachedImageLoader extends EventDispatcher
    {

        public function CachedImageLoader()
        {
            super();

            // set up the loader
            loader = new Loader();
            loaderContext = new LoaderContext();
            loaderContext.checkPolicyFile = true;

            // Attach load-event listeners to our LoaderInfo instance.
            contentLoaderInfo = loader.contentLoaderInfo;
            attachLoadingListeners();
        }

        private var _bitmapData:BitmapData;
        private var _cachedImage:CachedImage;
        private var contentLoaderInfo:LoaderInfo;
        private var loader:Loader;
        private var loaderContext:LoaderContext;

        public function get bitmapData():BitmapData
        {
            return _bitmapData;
        }

        public function get cachedImage():CachedImage
        {
            return _cachedImage;
        }

        public function set cachedImage(value:CachedImage):void
        {
            _cachedImage = value;
            loadImage();
        }

        /**
         * Empty any data in the loader
         * so it takes up the minimum memory
         */
        public function reset():void
        {
            // YOYO: this may not be worth the cost
            loader.unload();
        }

        protected function loadImage():void
        {
            // clear the previous image, if any
            cachedImage.graphics.clear();

            var url:String = cachedImage.imageUrl;

            try
            {
                loader.load(new URLRequest(url), loaderContext);
            }
            catch (error:SecurityError)
            {
                onSecurityError(error);
            }
        }

        protected function onImageLoadError(event:IOErrorEvent):void
        {
            dispatchEvent(event.clone());
        }

        protected function onImageLoaded(event:Event):void
        {
            var image:Bitmap = Bitmap(contentLoaderInfo.content);
            _bitmapData = image.bitmapData;

            var g:Graphics = cachedImage.graphics;

            g.beginBitmapFill(_bitmapData, new Matrix());
            g.drawRect(0, 0, image.width, image.height);
            g.endFill();

            dispatchEvent(new Event(Event.COMPLETE));
        }

        private function attachLoadingListeners():void
        {
            if (contentLoaderInfo)
            {
                contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
                contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageLoadError);
                contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
                                                   onSecurityError);
            }
            else
            {
                throw new ArgumentError();
            }
        }

        private function onSecurityError(error:SecurityError):void
        {
            // TODO
            trace("ERROR: " + error);
        }
    }
}
