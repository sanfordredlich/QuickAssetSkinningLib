/**
 * By Nahuel Foronda
 * http://www.asfusion.com/blog/entry/mobile-itemrenderer-in-actionscript-part-5
 */
package tv.attune.quicklib.util
{
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.getQualifiedClassName;

    import mx.styles.CSSStyleDeclaration;
    import mx.styles.ISimpleStyleClient;
    import mx.styles.IStyleManager2;
    import mx.styles.StyleManager;

    import tv.attune.quicklib.filter.CSSDropShadowFilter;


    public class TextUtil
    {

        public static function adjustMultilineTextSize(textField:TextField, lines:int):void
        {
            var origText:String = textField.text;
            var charIndex:int = textField.getLineOffset(lines);
            textField.text = origText.substr(0, charIndex - 4) + "...";
        }

        public static function adjustTextSize(textField:TextField, availableWidth:int):Boolean
        {
            var truncated:Boolean = false;

            if (availableWidth < textField.textWidth)
            {
                var origText:String = textField.text;
                var charWidth:int = textField.textWidth / textField.length;
                var numChar:int = availableWidth / charWidth - 3;

                while (availableWidth < textField.textWidth)
                {
                    textField.text = origText.substr(0, numChar) + "...";
                    numChar--;
                }
                truncated = true;
            }
            return truncated;
        }

        public static function changeColor(textField:TextField, color:uint):void
        {
            if (textField.textColor != color)
                textField.textColor = color;
        }

        public static function createSimpleTextField(client:Object,
                                                     selectable:Boolean = false,
                                                     autoSize:String = TextFieldAutoSize.
                                                     LEFT,
                                                     includeAll:Boolean = false):TextField
        {
            var textField:TextField = new TextField();

            client = getStyleClient(client);
            var textFormat:TextFormat = readTextFormat(client, includeAll);
            textField.defaultTextFormat = textFormat;
            textField.selectable = selectable;

            var dropShadowStyle:* = client.getStyle("textDropShadowStyle");

            if (autoSize && autoSize != "")
            {
                textField.autoSize = autoSize;
            }

            if (dropShadowStyle != undefined)
            {
                var dropShadow:CSSDropShadowFilter = new CSSDropShadowFilter(dropShadowStyle);
                textField.filters = [ dropShadow.filter ];
            }

            return textField;
        }

        public static function getStyleClient(client:Object):Object
        {
            var styleClient:Object;

            if (client is ISimpleStyleClient)
            {
                styleClient = client;
            }
            else
            {
                var styleManager:IStyleManager2 = StyleManager.getStyleManager(null);
                var selector:String = (client is String) ? "." + String(client) :
                    getQualifiedClassName(client).replace("::", ".");
                var styleDeclaration:CSSStyleDeclaration = styleManager.getStyleDeclaration(selector);
                styleClient = styleDeclaration;
            }
            return styleClient;
        }

        public static function readTextFormat(client:Object, includeAll:Boolean =
                                              false):TextFormat
        {
            var textFormat:TextFormat = new TextFormat();
            var align:String = client.getStyle("textAlign") || TextFormatAlign.LEFT;

            if (align == "start")
                align = TextFormatAlign.LEFT
            else if (align == "end")
                align = TextFormatAlign.RIGHT;

            textFormat.align = align;
            textFormat.bold = client.getStyle("fontWeight") == "bold";
            textFormat.color = client.getStyle("color");
            textFormat.italic = client.getStyle("fontStyle") == "italic";
            textFormat.font = client.getStyle("fontFamily");
            textFormat.size = client.getStyle("fontSize");
            textFormat.leading = client.getStyle("leading");

            if (includeAll)
            {
                textFormat.blockIndent = client.getStyle("blockIndent");
                textFormat.bullet = client.getStyle("bullet");
                textFormat.indent = client.getStyle("textIndent");
                textFormat.leftMargin = client.getStyle("leftMargin");
                textFormat.letterSpacing = client.getStyle("letterSpacing");
                textFormat.rightMargin = client.getStyle("rightMargin");
                textFormat.underline = client.getStyle("textDecoration") == "underline";

                var kerning:* = client.getStyle("kerning");

                if (kerning == "auto" || kerning == "on")
                    kerning = true;
                else if (kerning == "default" || kerning == "off")
                    kerning = false;
                textFormat.kerning = kerning;
            }
            return textFormat;
        }
    }
}
