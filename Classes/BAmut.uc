////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// Change the default playercontroller class
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAmut.uc,v 1.4 2003/10/13 12:55:44 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAmut extends Mutator config;

const VERSION = "100";

/** localized setting description */
var localized string msgSettingDesc[9];
/** visual notification options */
var localized string msgVisNotOpt;

/** the AdrenalinePickup class to replace the original AdrenalinePickup with */
var config string BadAdrenalineClassName;
/** out new playercontroller class */
var config string BAControllerClassName;

/** the available side effects */
enum BASideEffect
{
	BASE_None,
	BASE_Shroom,
	BASE_Elasto,
};

/** side effect configuration, BASE_none is used if there's no match */
struct SERange
{
	var BASideEffect effect;
	var float	min;
	var float	max;
};

//// external config variable
// BAController
var config bool bResetOnDeath;
var config float fShroomDuration;
var config float smWanderSpeed;
var config float smAccel;
var config float fElastoDuration;
var config float emInitialBounce, emBounce;
var config int emFov;
// BAdrenalinePickup
var config array<SERange> SEConfig;
var config byte VisualNotification;

event PreBeginPlay()
{
	local class<BAController> BAC;
	local class<BAdrenalinePickup> BAP;

	Log("~> Loading Bad Adrenaline version"@VERSION@"...", 'BadAdrenaline');
	Log("~> (c) 2003 Michiel 'El Muerte' Hendriks", 'BadAdrenaline');
	Level.Game.PlayerControllerClassName = BAControllerClassName;

	if ( Level.Game.PlayerControllerClass == None )
		Level.Game.PlayerControllerClass = class<PlayerController>(DynamicLoadObject(Level.Game.PlayerControllerClassName, class'Class'));
	
	BAC = class<BAController>(Level.Game.PlayerControllerClass);
	if (BAC != none)
	{
		BAC.default.defbResetOnDeath = bResetOnDeath;
		BAC.default.deffShroomDuration = fShroomDuration;
		BAC.default.defsmWanderSpeed = smWanderSpeed;
		BAC.default.defsmAccel = smAccel;
		BAC.default.deffElastoDuration = fElastoDuration;
		BAC.default.defemInitialBounce = emInitialBounce;
		BAC.default.defemBounce = emBounce;
		BAC.default.defemFov = emFov;
	}
	else Log("~> Error: BAController not configured", 'BadAdrenaline');

	BAP = class<BAdrenalinePickup>(DynamicLoadObject(BadAdrenalineClassName, class'Class'));
	if (BAP != none)
	{
		BAP.default.SEConfig = SEConfig;
		BAP.default.defVisualNotification = VisualNotification;
	}
	else Log("~> Error: BAdrenalinePickup not configured", 'BadAdrenaline');

	Log("~> Done!", 'BadAdrenaline');
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	bSuperRelevant = 0;
	if ((AdrenalinePickup(Other) != none) && (string(Other.Class) != BadAdrenalineClassName))
	{
		ReplaceWith( Other, BadAdrenalineClassName );
		return false;
	}
	return true;
}

function MutatorFillPlayInfo(PlayInfo PlayInfo)
{
	Super.MutatorFillPlayInfo(PlayInfo);
	PlayInfo.AddSetting("Bad Adrenaline", "bResetOnDeath",			default.msgSettingDesc[0], 0, 1, "Check");

	PlayInfo.AddSetting("Bad Adrenaline", "fShroomDuration",		default.msgSettingDesc[1], 0, 2, "Text", "10:0.1:9999");
	PlayInfo.AddSetting("Bad Adrenaline", "smWanderSpeed",			default.msgSettingDesc[2], 0, 3, "Text", "10:0.1:9999");
	PlayInfo.AddSetting("Bad Adrenaline", "smAccel",						default.msgSettingDesc[3], 0, 4, "Text", "10:0.1:999");

	PlayInfo.AddSetting("Bad Adrenaline", "fElastoDuration",		default.msgSettingDesc[4], 0, 5, "Text", "10:0.1:9999");
	PlayInfo.AddSetting("Bad Adrenaline", "emFov",							default.msgSettingDesc[5], 0, 6, "Text", "10:0:200");
	PlayInfo.AddSetting("Bad Adrenaline", "emInitialBounce",		default.msgSettingDesc[6], 0, 7, "Text", "10:0.1:99999");
	PlayInfo.AddSetting("Bad Adrenaline", "emBounce",						default.msgSettingDesc[7], 0, 8, "Text", "10:0.1:99999");

	PlayInfo.AddSetting("Bad Adrenaline", "VisualNotification", default.msgSettingDesc[8], 0, 9, "Select", default.msgVisNotOpt);
}

defaultproperties
{
	FriendlyName="Bad Adrenaline"
	Description="Some adrenaline got bad, so watch out for them"
	GroupName="Controller Mod"
	ConfigMenuClassName=""

	BAControllerClassName="BadAdrenaline.BAController"
	BadAdrenalineClassName="BadAdrenaline.BAdrenalinePickup"

	msgSettingDesc[0]="Reset of death"
	msgSettingDesc[1]="Shroom Mode duration"
	msgSettingDesc[2]="Shroom Mode speed"
	msgSettingDesc[3]="Shroom Mode acceleration"
	msgSettingDesc[4]="Elasto Mode duration"
	msgSettingDesc[5]="Elasto Mode FOV"
	msgSettingDesc[6]="Elasto Mode initial bounce"
	msgSettingDesc[7]="Elasto Mode bounce"
	msgSettingDesc[8]="Visual Notification"
	msgVisNotOpt="0;None;1;Orange;2;Purple;3;Green;4;Blue"

	// BAController
	bResetOnDeath=true

	fShroomDuration=30
	smWanderSpeed=500
	smAccel=2.5

	fElastoDuration=30
	emFov=150
	emInitialBounce=5000
	emBounce=1500	

	// BAdrenalinePickup
	SEConfig(0)=(Effect=BASE_Shroom,Min=0,Max=0.16666)
	SEConfig(1)=(Effect=BASE_Elasto,Min=0.16666,Max=0.33333)
	VisualNotification=1
}