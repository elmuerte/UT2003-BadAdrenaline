////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// Change the default playercontroller class
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAmut.uc,v 1.2 2003/10/11 12:34:08 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAmut extends Mutator config;

const VERSION = "100";

/** the AdrenalinePickup class to replace the original AdrenalinePickup with */
var config string BadAdrenalineClassName;

event PreBeginPlay()
{
	Log("~> Loading Bad Adrenaline version"@VERSION@"...", 'BadAdrenaline');
	
	Log("~> Done!", 'BadAdrenaline');
}

function ModifyPlayer(Pawn Other)
{
	local BAController tempBAC;	
	Super.ModifyPlayer(Other);

	if (xPlayer(Other.Controller) != none)
	{
		foreach DynamicActors(Class'BAController', tempBAC)	if (tempBAC.MyController == Other.Controller) return;
		Log("ModifyPlayer"@Other);
		spawn(class'BAController', Other.Controller);
	}
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