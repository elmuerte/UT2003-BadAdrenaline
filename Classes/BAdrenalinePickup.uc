////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// possible contaminated adrenaline pickup
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAdrenalinePickup.uc,v 1.3 2003/10/11 12:34:08 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAdrenalinePickup extends AdrenalinePickup config;

#exec OBJ LOAD FILE=BadAdrenaline_tex.utx

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
	var float min;
	var float max;
};
/** side effect configuration, BASE_none is used if there's no match */
var config array<SERange> SEConfig;

var config byte VisualNotification;

/** current side effect */
var BASideEffect SideEffect;

auto state Pickup
{	
	function Touch( actor Other )
	{
		local BAController BAC;
			
		if ( ValidTouch(Other) ) 
		{
			BAC = FindBAController(Pawn(Other).Controller);
			if (BAC == none) Super.Touch(Other);
			else {
				switch (SideEffect)
				{
					case BASE_Shroom:
						if (BAC.isSick()) return; // don't pickup
						PlaySound( sound'BadAdrenaline.ShroomsModeSound' , SLOT_Interact ); 
						BAC.ShroomsMode();
						SetRespawn();
						break;
					case BASE_Elasto:	
						if (BAC.isSick()) return; // don't pickup
						PlaySound( sound'BadAdrenaline.ElastoModeSound' , SLOT_Interact ); 
						BAC.ElastoMode();
						SetRespawn();
						break;
					default: Super.Touch(Other);
				}	
			}
		}
	}

begin:
	SetSideEffect();
}

/** set the current side effect */
function SetSideEffect()
{
	local int i;
	local float f;

	f = frand();
	SideEffect = BASE_None;
	for (i = 0; i < SEConfig.length; i++)
	{
		if ((f >= SEConfig[i].min) && (f < SEConfig[i].max))
		{
			SideEffect = SEConfig[i].Effect;
			break;
		}
	}
	if (VisualNotification > 0)
	{
		if (SideEffect != BASE_None)
		{
			switch (VisualNotification)
			{
				case 1: Skins[0] = material'BadAdrenaline_tex.BA.BALevel1'; break;
				case 2: Skins[0] = material'BadAdrenaline_tex.BA.BALevel2'; break;
				case 3: Skins[0] = material'BadAdrenaline_tex.BA.BALevel3'; break;
				case 4: Skins[0] = material'BadAdrenaline_tex.BA.BALevel4'; break;
			}			
		}
		else Skins.length = 0;
	}	
	Log("SideEffect ="@SideEffect@f);
}

/** find the BAController for the picking up actor */
function BAController FindBAController(Controller ctlr)
{
	local BAController tempBAC;
	foreach DynamicActors(Class'BAController', tempBAC)
		if (tempBAC.MyController == ctlr) return tempBAC;
	return None;
}

defaultproperties
{
	SEConfig(0)=(Effect=BASE_Shroom,Min=0,Max=0.55)
	//SEConfig(1)=(Effect=BASE_Elasto,Min=0.25,Max=0.5)
	VisualNotification=4
}