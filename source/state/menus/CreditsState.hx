package state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.util.FlxColor;
import meta.CoolUtil;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;

using StringTools;

typedef CreditGuy =
{
    var name:String;
    var substate_name:String;
    var icon:String; //handle multiple files at once
    var description:String;
    var expression:String;
    var color:Array<Int>;
    var social_medias:Array<SocialMedia>;
    var isCategorie:Bool;
}

typedef SocialMedia =
{
    var name:String;
    var value:String; //link or social username
    var position:Array<Float>;
    var scale:Float;
}

class CreditsState extends meta.MusicBeat.MusicBeatState
{
    var creditBuds:Array<CreditGuy>;
    var creditsGroup:FlxTypedGroup<CreditBuddy>;
    var curSelected:Int = 0;
    var mainColor:FlxColor = FlxColor.WHITE;
    var bg:FlxSprite;

    override function create()
    {
        super.create();
		creditBuds = haxe.Json.parse(openfl.Assets.getText(Paths.data('credits.json')));

		bg = new FlxSprite(-85).loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xff1b6ecc;
		add(bg);
        
        creditsGroup = new FlxTypedGroup<CreditBuddy>();
        add(creditsGroup);
        
        for(i in 0...creditBuds.length)
        {
			var bud = new CreditBuddy(creditBuds[i].name, creditBuds[i].icon, creditBuds[i].isCategorie);
            if(!creditBuds[i].isCategorie) bud.xTo = 350;
			bud.targetY = i;
			creditsGroup.add(bud);
        }

        changeSelection();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(controls.ACCEPT)
        {
            var bud = creditBuds[curSelected];
			if(!bud.isCategorie) openSubState(new CreditSubState(bud.substate_name, bud.icon, bud.description, bud.expression, bud.social_medias));
        }

        if(controls.UI_UP_P)
        {
            changeSelection(-1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        if(controls.UI_DOWN_P)
        {
            changeSelection(1);
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        if(controls.BACK)
        {
            Main.switchState(this, new MainMenuState());
			FlxG.sound.play(Paths.sound('cancelMenu'));
        }
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;
		if (curSelected < 0)
			curSelected = Std.int(creditBuds.length - 1);
		if (curSelected >= creditBuds.length)
			curSelected = 0;

        var bullShit:Int = 0;
		for (item in creditsGroup.members)
		{
			item.targetY = item.targetX = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;
			if(item.targetY == 0)
				item.alpha = 1;
		}

		var color = creditBuds[curSelected].color;
		mainColor = FlxColor.fromRGB(color[0], color[1], color[2]);
        FlxTween.cancelTweensOf(bg);
		FlxTween.color(bg, 0.35, bg.color, mainColor);
    }
}

class CreditSubState extends meta.MusicBeat.MusicBeatSubState
{
    public static var instance:CreditSubState; //oh no
    public var canSelect:Bool = false;
    
    public function new(name:String, avatar:String, description:String, expression:String, socialMedias:Array<SocialMedia>)
    {
        super();
        instance = this; //NOOOOO
        FlxG.mouse.visible = true;

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
        add(bg);

        var icon = new FlxSprite(100, 100).loadGraphic(Paths.image('menus/credits/avatars/$avatar'));
        icon.alpha = 0;
        add(icon);

		var desc = new FlxText(icon.x + 50, icon.y + icon.height + 50, 0, '$name\n\n$description').setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
        desc.alpha = 0;
        add(desc);

		var exp = new FlxText(0, icon.y, 0, '“$expression”').setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
        exp.screenCenter(X);
        exp.alpha = 0;
		add(exp);

        for(i in 0...socialMedias.length)
        {
			var social = new SocialMediaButton(socialMedias[i].position[0], socialMedias[i].position[1], socialMedias[i].name, socialMedias[i].value, socialMedias[i].scale);
            add(social);
        }

        FlxTween.tween(bg, {alpha: 0.5}, 0.2, {onComplete: function(_) { canSelect = true; }});
        for(object in [icon, desc, exp]) FlxTween.tween(object, {alpha: 1}, 0.2);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(canSelect)
        {
            if(controls.BACK)
            {
				canSelect = false;
                for(object in members)
                    FlxTween.tween(object, {alpha: 0}, 0.5, {onComplete: function(_) {
                        if(this != null) close();
                    }});
            }
        }
    }

    override function close()
    {
		FlxG.mouse.visible = false;
        super.close();
    }
}

class CreditBuddy extends FlxGroup
{
    public var targetY:Float = 0;
    public var targetX:Float = 0;
    public var xTo:Float = 150;
    public var alpha:Float = 1;
	public var text:Alphabet;
    var icon:FlxSprite;

    public function new(name:String, iconFile:String, isCategorie:Bool)
    {
        super();

        if(!isCategorie)
        {
			icon = new FlxSprite(10).loadGraphic(Paths.image('menus/credits/icons/$iconFile'));
			icon.antialiasing = true;
			add(icon);
        }

        text = new Alphabet(0, 0, name, true, false);
        text.screenCenter(X);
        text.disableX = true;
        text.antialiasing = true;
        add(text);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		var lerp = CoolUtil.boundTo(elapsed * 10.2, 0, 1);
		text.y = FlxMath.lerp(text.y, (targetY * 120) + 320, lerp);
        text.x = FlxMath.lerp(text.x, (targetX * 120) + xTo, lerp);
        text.alpha = alpha;

		if (icon != null) {
			icon.setPosition(text.x - 150, text.y - 35);
			icon.alpha = alpha;
		}
    }
}

class SocialMediaButton extends FlxTypedButton<FNFSprite>
{
    public function new(x:Float, y:Float, socialMedia:String, value:String, scale:Float)
    {
        super(x, y);
        loadGraphic(Paths.image('menus/credits/socials/$socialMedia'));
        antialiasing = true;
        onDown.callback = function() {
            if(CreditSubState.instance.canSelect)
            {
				if (value.startsWith('http')) CoolUtil.browserLoad(value);
				else
				{
					var swagText = new FlxText(0, 25).setFormat(Paths.font('vcr.ttf'), 34);
					swagText.text = value;
                    swagText.screenCenter(X);

					var rectangle = new FlxSprite(0, 50).makeGraphic(Std.int(swagText.width * 1.2), 10, FlxColor.BLACK);
                    rectangle.screenCenter(X);
                    
					CreditSubState.instance.add(rectangle);
					CreditSubState.instance.add(swagText);
					for (object in [rectangle, swagText])
						FlxTween.tween(object, {alpha: 0}, 4, {startDelay: 3, onComplete: function(_)
						{
							object.destroy();
						}});
				}
            }
        };

		onOver.callback = function()
		{
            if(CreditSubState.instance.canSelect)
            {
				this.scale.x += 0.25;
				this.scale.y += 0.25;
				FlxG.sound.play(Paths.sound('scrollMenu'));
            }
		};

		onOut.callback = function()
		{
            if(CreditSubState.instance.canSelect)
            {
				this.scale.x -= 0.25;
				this.scale.y -= 0.25;
            }
		};

        this.scale.set(scale, scale);
        updateHitbox();
    }
}
