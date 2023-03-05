package base.scripting;

import meta.state.PlayState;
import modcharting.Modifier;

class ModchartScript extends HScript
{
    public function new(file:String)
    {
        super(Paths.data('modcharts/$file.hxs'));
        set("Modifier", Modifier);
        set("DrunkXModifier", DrunkXModifier);
		set("DrunkYModifier", DrunkYModifier);
		set("DrunkZModifier", DrunkZModifier);
		set("TipsyXModifier", TipsyXModifier);
		set("TipsyYModifier", TipsyYModifier);
		set("TipsyZModifier", TipsyZModifier);
		set("ReverseModifier", ReverseModifier);
		set("IncomingAngleModifier", IncomingAngleModifier);
		set("RotateModifier", RotateModifier);
		set("StrumLineRotateModifier", StrumLineRotateModifier);
		set("BumpyModifier", BumpyModifier);
		set("XModifier", XModifier);
		set("YModifier", YModifier);
		set("ZModifier", ZModifier);
        set("ModifierType", ModifierType);
        set("addNoteField", function(x:Float, y:Float, z:Float) {
            PlayState.instance.playfieldRenderer.addNewplayfield(x, y, z);
        });
        set("addModifier", function(name:String, mod:Modifier, type:ModifierType) {
            mod.tag = name;
            mod.type = type;
            mod.setupSubValues();
			PlayState.instance.playfieldRenderer.addModifier(mod);
        });
		set("removeModifier", function(name:String) {
			PlayState.instance.playfieldRenderer.removeModifier(name);
		});
    }

	public function create()
	{
		if(exists("onCreate"))
			call("onCreate");
	}
}