package tv.attune.quicklib.image
{
    import spark.primitives.BitmapImage;


    public class ClearableBitmapImage extends BitmapImage
    {
        public function reset():void
        {
            setBitmapData(null);
        }
    }
}
