package options;

import MainMenuState;
import FreeplayState;
#if TOUCH_CONTROLS
import mobile.substates.MobileControlSelectSubState;
import mobile.substates.MobileExtraControl;
#end
import mobile.states.CopyState;
import ClientPrefs;
import StageData;
import options.NovaFlareOptionsObjects.Option;
import funkin.backend.scripting.events.CataEvent;

class OptionsState extends MusicBeatState
{
	public static var instance:OptionsState;
	#if android final lastStorageType:String = ClientPrefs.data.storageType; #end

	var filePath:String = 'menuExtend/OptionsState/';

	var naviArray:Array<NaviData> = [];

	//make them changeable
	var baseNaviArray = [
		'Visual & UI',
		'Gameplay',
		'Controls'
	];

	////////////////////////////////////////////////////////////////////////////////////////////

	public var baseColor = 0x302E3A;
	public var mainColor = 0x24232C;

	////////////////////////////////////////////////////////////////////////////////////////////

	public var mouseEvent:MouseEvent;

	var naviBG:RoundRect;
	var naviGroup:Array<NaviGroup> = [];
	var naviMove:MouseMove;

	var cataGroup:Array<OptionCata> = [];
	public var cataMove:MouseMove;
	public var stringCount:Array<StringSelect> = []; //string开启的检测

	public var downBG:Rect;
	var tipButton:TipButton;
	var specButton:FuncButton;

	public var specBG:Rect;
	var searchButton:SearchButton;
	var resetButton:ResetButton;
	var backButton:GeneralBack;

	override function create()
	{
		persistentUpdate = persistentDraw = true;
		instance = this;
		/* Stuffs I preferred */
		FlxG.mouse.visible = true;
		Main.fpsVar.visible = false;
		#if EXTRA_FPSCOUNTER Main.fpsVarNova.visible = false; #end

		super.create();

		naviArray = [
			new NaviData('PsychExtended', baseNaviArray)
		];
		#if SCRIPTING_ALLOWED call('onNaviCreate'); #end

		mouseEvent = new MouseEvent();
		add(mouseEvent);

		var bg = new Rect(0, 0, FlxG.width, FlxG.height, 0, 0, baseColor);
		add(bg);

		naviBG = new RoundRect(0, 0, UIScale.adjust(FlxG.width * 0.2), FlxG.height, 0, LEFT_CENTER,  mainColor);
		add(naviBG);

		#if SCRIPTING_ALLOWED
		var naviCreation = event("onNaviCreatePost", new CancellableEvent());
		if (!naviCreation.cancelled) {
		#end
			for (i in 0...naviArray.length)
			{
				var naviSprite = new NaviGroup(FlxG.width * 0.005, UIScale.adjust(FlxG.height * 0.005) + i * UIScale.adjust(FlxG.height * 0.1), UIScale.adjust(FlxG.width * 0.19), UIScale.adjust(FlxG.height * 0.09), naviArray[i], i, false);
				naviSprite.antialiasing = ClientPrefs.data.antialiasing;
				add(naviSprite);
				naviGroup.push(naviSprite);
			}
			naviMoveEvent(true);
		#if SCRIPTING_ALLOWED } #end

		naviMove = new MouseMove(OptionsState, 'naviPosiData', 
								[-1 * Math.max(0, (naviGroup.length - 9)) * UIScale.adjust(FlxG.height * 0.1), UIScale.adjust(FlxG.height * 0.005)],
								[	
									[UIScale.adjust(FlxG.width * 0.005), 
									UIScale.adjust(FlxG.width * 0.19)], [0, FlxG.height]
								],
								naviMoveEvent);
		add(naviMove);

		naviGroup[0].moveParent(0.01);

		/////////////////////////////////////////////////////////////////

		for (data in 0...naviArray.length) {
			var naviData:NaviData = naviArray[data];
			for (mem in 0...naviData.group.length) {
				if (naviData.extraPath != '') addCata(naviData.group[mem], naviGroup[data], naviGroup[data].parent[mem], naviData.extraPath);
				else addCata(naviData.group[mem], naviGroup[data], naviGroup[data].parent[mem]);
			}
		}

		var moveHeight:Float = 100;
		for (num in cataGroup) {
			if (num != cataGroup[cataGroup.length - 1]) {
				moveHeight -= num.bg.realHeight;
				moveHeight -= UIScale.adjust(FlxG.width * (0.8 / 40));
			}
		}
		cataMove = new MouseMove(OptionsState, 'cataPosiData', 
								[moveHeight, 100],
								[ 
									[UIScale.adjust(FlxG.width * 0.2), FlxG.width], 
									[0, FlxG.height - Std.int(UIScale.adjust(FlxG.height * 0.1))]
								],
								cataMoveEvent);
		add(cataMove);
		cataMoveEvent(true);
			
		/////////////////////////////////////////////////////////////

		downBG = new Rect(0, FlxG.height - Std.int(UIScale.adjust(FlxG.height * 0.1)), FlxG.width, Std.int(UIScale.adjust(FlxG.height * 0.1)), 0, 0, mainColor, 0.75);
		add(downBG);

		tipButton = new TipButton(
			UIScale.adjust(FlxG.width * 0.2) + UIScale.adjust(FlxG.height * 0.01), 
			downBG.y + Std.int(UIScale.adjust(FlxG.height * 0.01)),
			FlxG.width - UIScale.adjust(FlxG.width * 0.2) - UIScale.adjust(FlxG.height * 0.01) - Std.int(UIScale.adjust(FlxG.width * 0.15)) - Std.int(UIScale.adjust(FlxG.height * 0.01) * 2), 
			Std.int(UIScale.adjust(FlxG.height * 0.08))
		);
		add(tipButton);

		specButton = new FuncButton(
			FlxG.width - Std.int(UIScale.adjust(FlxG.width * 0.15)) - Std.int(UIScale.adjust(FlxG.height * 0.01)), 
			downBG.y + Std.int(UIScale.adjust(FlxG.height * 0.01)),
			Std.int(UIScale.adjust(FlxG.width * 0.15)), 
			Std.int(UIScale.adjust(FlxG.height * 0.08)),
			specChange
		);
		specButton.alpha = 0.5;
		add(specButton);

		//////////////////////////////////////////////////////////////////////

		specBG = new Rect(UIScale.adjust(FlxG.width * 0.2), 0, FlxG.width - UIScale.adjust(FlxG.width * 0.2), Std.int(UIScale.adjust(FlxG.height * 0.1)), 0, 0, mainColor, 0.75);
		add(specBG);

		searchButton = new SearchButton(specBG.x + specBG.height * 0.2, specBG.height * 0.2, specBG.width * 0.5, specBG.height * 0.6);
		add(searchButton);

		resetButton = new ResetButton(specBG.x + specBG.height * 0.2 * 2 + searchButton.width, specBG.height * 0.2, specBG.width - (specBG.height * 0.2 * 3 + searchButton.width), specBG.height * 0.6);
		add(resetButton);

		backButton = new GeneralBack(0, 720 - 72, UIScale.adjust(FlxG.width * 0.2), UIScale.adjust(FlxG.height * 0.1), 'Back', EngineSet.mainColor, backMenu);
		add(backButton);
	}

	public var ignoreCheck:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		cataMove.inputAllow = true;
		for (cata in stringCount) {
			if (!cata.isOpend) continue;
			else {
				if (OptionsState.instance.mouseEvent.overlaps(cata.bg)){
					cataMove.inputAllow = false;
					break;
				}
			}
		}

		for (navi in naviGroup) navi.cataChoose = false;
		for (cata in cataGroup){
			if (cata.checkPoint()) {
				cata.follow.cataChoose = true;
				break;
			}
		}
	}

	override function openSubState(SubState:flixel.FlxSubState) {
		super.openSubState(SubState);
		persistentUpdate = false;
	}

	override function closeSubState()
	{
		super.closeSubState();
		persistentUpdate = true;
	}

	public function startSearch(text:String, time = 0.6) {
		for (cata in cataGroup) {
			cata.startSearch(text, time);
		}
	}

	public function changeCata(cataSort:Int, memSort:Int) {
		var outputData:Float = 100;

		var realSort:Int = memSort;
		for (navi in 0...naviGroup.length) {
			if (navi < cataSort) realSort += naviGroup[navi].parent.length;
			else break;
		}

		for (cata in 0...realSort) {
			outputData -= cataGroup[cata].bg.realHeight;
			outputData -= UIScale.adjust(FlxG.width * (0.8 / 40));
		}
		outputData = Math.max(outputData, cataMove.moveLimit[0]);
		cataMove.lerpData = outputData;
	}

	public function changeTip(str:String) {
		tipButton.changeText(str);
	}

	public function addCata(type:String, follow:NaviGroup, mem:NaviMember, extraPath:String = '') {
		var obj:OptionCata = null;

		var outputX:Float = naviBG.width + UIScale.adjust(FlxG.width * (0.8 / 40)); //已被初始化
		var outputWidth:Float = UIScale.adjust(FlxG.width * (0.8 - (0.8 / 40 * 2))); //已被初始化
		var outputY:Float = 100; //等待被初始化
		var outputHeight:Float = 200; //等待被初始化

		#if SCRIPTING_ALLOWED
		stateScripts.set('outputX', outputX);
		stateScripts.set('outputWidth', outputWidth);
		stateScripts.set('outputY', outputY);
		stateScripts.set('outputHeight', outputHeight);
		#end

		/* User can cancel it and change it for his own purpose (I'm recommend to make custom one but original one can usable too) */
		var createCataEvent = new CataEvent(type, obj); //create the CataEvent before the actual event because otherwise script can't get type
		createCataEvent.type = type;
		var cataCreation = event("addCata", createCataEvent);
		if (cataCreation.cancelled) {
			obj = cataCreation.obj;
		}
		else
		{
			switch (type)
			{
				case 'Graphics':
					obj = new GraphicsGroup(outputX, outputY, outputWidth, outputHeight);
				case 'Visual & UI':
					obj = new UIGroup(outputX, outputY, outputWidth, outputHeight);
				case 'Note Skins':
					obj = new SkinGroup(outputX, outputY, outputWidth, outputHeight);
				case 'Gameplay':
					obj = new GameplayGroup(outputX, outputY, outputWidth, outputHeight);
				case 'Controls':
					obj = new MobileGroup(outputX, outputY, outputWidth, outputHeight);
				default:
					#if SCRIPTING_ALLOWED
					obj = new ModGroup(outputX, outputY, outputWidth, outputHeight, '${type}Group'); //My System is Different
					#else
					obj = new GraphicsGroup(outputX, outputY, outputWidth, outputHeight); //I'll add dummy group later
					#end
			}
			if (cataCreation.obj != null) obj = cataCreation.obj;
		}

		cataGroup.push(obj);
		obj.follow = follow;
		obj.mem = mem;
		add(obj);
	}

	public function addMove(tar:MouseMove) {
		add(tar);
	}

	public function removeMove(tar:MouseMove) {
		remove(tar);
	}

	static public var cataPosiData:Float = 100;
	public function cataMoveEvent(init:Bool = false){
		for (i in 0...cataGroup.length) {
			if (i == 0) cataGroup[i].y = cataPosiData;
			else cataGroup[i].y = cataGroup[i - 1].y + cataGroup[i - 1].bg.realHeight + UIScale.adjust(FlxG.width * (0.8 / 40));
		}
	}

	public function cataMoveChange()
	{
		var moveHeight:Float = 100;
		for (num in cataGroup) {
			if (num != cataGroup[cataGroup.length]) {
				moveHeight -= num.bg.waitHeight;
				moveHeight -= UIScale.adjust(FlxG.width * (0.8 / 40));
			} else {
				moveHeight -= cataGroup[cataGroup.length - 1].bg.waitHeight - UIScale.adjust(FlxG.height * 0.8) * 2;
				moveHeight -= UIScale.adjust(FlxG.width * (0.8 / 40)) * 2;
			}
		}
		cataMove.moveLimit[0] = moveHeight;
	}

	static public var naviPosiData:Float = 0;
	public function naviMoveEvent(init:Bool = false){
		for (i in 0...naviGroup.length) {
			naviGroup[i].y = naviPosiData + i * UIScale.adjust(FlxG.height * 0.1) + naviGroup[i].offsetY;
		}
	}

	var naviTween:Array<FlxTween> = [];
	var alreadyDetele:Bool = false;
	public function changeNavi(navi:NaviGroup, isOpened:Bool, naviTime:Float = 0.45) {
		for (tween in naviTween) {
			if (tween != null) tween.cancel();
		}

		for (i in 0...naviGroup.length) {
			if (i <= navi.optionSort) continue;
			else {
				naviGroup[i].offsetWaitY += (navi.parent.length * 50 + 15) * (isOpened? -1 : 1);
				var tween = FlxTween.num(naviGroup[i].offsetY, naviGroup[i].offsetWaitY, naviTime, {ease: FlxEase.expoInOut}, function(v){naviGroup[i].offsetY = v;});
				naviTween.push(tween);
			}
		}
		
		var moveHeight:Float = 0;
		for (i in 0...naviGroup.length) {
			if (naviGroup[i] == navi) continue;
			else {
				if (naviGroup[i].isOpened) moveHeight += naviGroup[i].parent.length * 50 + 15;
			}
		}
		if (!isOpened) moveHeight += (navi.parent.length * 50 + 15);
		naviMove.moveLimit[0] = -1 * Math.max(0, ((naviGroup.length - 9)) * UIScale.adjust(FlxG.height * 0.1) + moveHeight);
	}

	var specOpen:Bool = false;
	var specTween:Array<FlxTween> = [];
	var specTime = 0.6;
	public function specChange() {
		for (tween in specTween) {
			if (tween != null) tween.cancel();
		}

		var newPoint:Float = 0;
		if (!specOpen) {
			newPoint = FlxG.width;
			cataMove.moveLimit[1] = 30;
		} else {
			newPoint = UIScale.adjust(FlxG.width * 0.2);
			cataMove.moveLimit[1] = 100;
		}

		var tween = FlxTween.tween(specBG, {x: newPoint}, specTime, {ease: FlxEase.expoInOut});
		specTween.push(tween);
		var tween = FlxTween.tween(searchButton, {x: newPoint + specBG.height * 0.2}, specTime, {ease: FlxEase.expoInOut});
		specTween.push(tween);
		var tween = FlxTween.tween(resetButton, {x: newPoint + specBG.height * 0.2 + searchButton.width + specBG.height * 0.2}, specTime, {ease: FlxEase.expoInOut});
		specTween.push(tween);
		
	
		specOpen = !specOpen;
	}

	public function resetData()
	{
		for (spr in 0...naviGroup.length) {
			if (naviGroup[spr].cataChoose == true) {
				cataGroup[spr].resetData();
				break;
			}
		}
	}

	public static var stateType:Int = 0; //检测到底退回到哪个界面
	var backCheck:Bool = false;
	function backMenu()
	{
		if (!backCheck)
		{
			backCheck = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			#if android
			if (ClientPrefs.data.storageType != lastStorageType) {
				File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.data.storageType);
				ClientPrefs.saveSettings();
				CoolUtil.showPopUp('Storage Type has been changed and you needed restart the game!!\nPress OK to close the game.', 'Notice!');
				lime.system.System.exit(0);
			}
			else
			#end
				ClientPrefs.saveSettings();
			#if EXTRA_FPSCOUNTER onChangeFPSCounterShit(); #end
			switch (stateType)
			{
				case 0:
					CustomSwitchState.switchMenus('MainMenu');
					FlxG.mouse.visible = false;
				case 1:
					CustomSwitchState.switchMenus('Freeplay');
				case 2:
					StageData.loadDirectory(PlayState.SONG); //Load Stage Directory (fixes null object issues)
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.mouse.visible = false;
			}
			stateType = 0;
		}
	}

	public static function onChangeFPSCounterShit()
	{
		Main.fpsVar.visible = false;
		#if EXTRA_FPSCOUNTER
		Main.fpsVarNova.visible = false;

		if (ClientPrefs.data.FPSCounter == 'NovaFlare')
			Main.fpsVarNova.visible = ClientPrefs.data.showFPS;
		else if (ClientPrefs.data.FPSCounter == 'Psych')
		#end
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
}