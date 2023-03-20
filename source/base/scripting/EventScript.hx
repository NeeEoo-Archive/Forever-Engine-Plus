package base.scripting;

import state.PlayState;

/**
 * WIP
 */
class EventScript extends HScript
{
    override public function new(event:String)
    {
        super(Paths.data('events/$event.hxs'));
        set("PlayState", PlayState);
        set("game", PlayState.instance);
        set("addShader", PlayState.instance.shaders.addShader);
    }

    public function callFunc(func:String, ?args:Null<Array<Dynamic>>)
    {
        if(exists(func))
            call(func, args);
    }
}