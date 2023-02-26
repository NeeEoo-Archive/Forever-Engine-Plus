package scripting;

import meta.state.PlayState;

class ModchartScript extends HScript
{
    public var script:HScript;

    public function new(file:String)
    {
        super(Paths.data('modcharts/$file.hxs'));
        set("addField", function(x:Float, y:Float, z:Float) {
            PlayState.instance.playfieldRenderer.addNewplayfield(x, y, z);
        });
        set("addEvent", function(beat:Float, func:Array<String> -> Void, args:Array<String>) {
			PlayState.instance.playfieldRenderer.addEvent(beat, func, args);
        });
    }
}