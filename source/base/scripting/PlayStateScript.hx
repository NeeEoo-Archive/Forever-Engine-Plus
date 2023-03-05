package base.scripting;

import meta.state.PlayState;

class PlayStateScript extends HScript
{
    public function new(file:String)
    {
        super(Paths.data('scripts/$file.hxs'));
        set('game', PlayState.instance);
        set('PlayState', PlayState);
    }
}