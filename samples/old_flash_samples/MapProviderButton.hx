import flash.display.MovieClip;import flash.text.TextField;import flash.text.TextFormat;import com.modestmaps.mapproviders.IMapProvider;  /**     * Button for use in ModestMaps Sample     *      * @author David Knape     */  class MapProviderButton extends MovieClip
{private var label : TextField;public var mapProvider : IMapProvider;public function new(label_text : String, map_provider : IMapProvider)
    {
        super();useHandCursor = true;mouseChildren = false;buttonMode = true;mapProvider = map_provider;  // create label  label = new TextField();label.selectable = false;label.defaultTextFormat = new TextFormat("Verdana", 10, 0xffffff);label.text = label_text;label.width = label.textWidth + 4;label.height = 18;label.x = label.y = 1;addChild(label);  // create background  graphics.moveTo(0, 0);graphics.beginFill(0x000000, .8);graphics.drawRoundRect(0, 0, 110, 18, 3, 3);graphics.endFill();
    }
}