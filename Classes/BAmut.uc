////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// Change the default playercontroller class
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAmut.uc,v 1.1 2003/10/10 08:00:46 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAmut extends Mutator config;

const VERSION = "100";

/** the AdrenalinePickup class to replace the original AdrenalinePickup with */
var config string BadAdrenalineClassName;

event PreBeginPlay()
{
	Log("~> Loading Bad Adrenaline version"@VERSION@"...", 'BadAdrenaline');
	Level.Game.PlayerControllerClassName = "BadAdrenaline.BAController";


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

defaultproperties
{
	FriendlyName="Bad Adrenaline"
	Description="Some adrenaline got bad, so watch out for them"
	GroupName="Controller Mod"
	ConfigMenuClassName=""

	BadAdrenalineClassName="BadAdrenaline.BAdrenalinePickup";
}