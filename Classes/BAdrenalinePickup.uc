////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// possible contaminated adrenaline pickup
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAdrenalinePickup.uc,v 1.6 2003/10/12 20:06:21 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAdrenalinePickup extends AdrenalinePickup;

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
var array<SERange> SEConfig;

/** how to display a bad adrenaline pill */
var byte VisualNotification;

/** current side effect */
var BASideEffect SideEffect;
/** special local message for the side effects */
var class<PickupMessagePlus> MessageClassEx;

auto state Pickup
{	
	function Touch( actor Other )
	{
		local BAController BAC;
			
		if ( ValidTouch(Other) ) 
		{
			BAC = BAController(Pawn(Other).Controller);
			if (BAC == none) Super.Touch(Other);
			else {
				switch (SideEffect)
				{
					case BASE_Shroom:
						if (BAC.isSick()) return; // don't pickup
						PlaySound( sound'BadAdrenaline.ShroomsModeSound' , SLOT_Interact ); 
						BAC.ShroomsMode();
						AnnouncePickupEx(Pawn(Other).Controller, SideEffect);
						SetRespawn();
						break;
					case BASE_Elasto:	
						if (BAC.isSick()) return; // don't pickup
						PlaySound( sound'BadAdrenaline.ElastoModeSound' , SLOT_Interact ); 
						BAC.ElastoMode();
						AnnouncePickupEx(Pawn(Other).Controller, SideEffect);
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
				case 1: RepSkin = material'BadAdrenaline_tex.BA.BALevel1'; break;
				case 2: RepSkin = material'BadAdrenaline_tex.BA.BALevel2'; break;
				case 3: RepSkin = material'BadAdrenaline_tex.BA.BALevel3'; break;
				case 4: RepSkin = material'BadAdrenaline_tex.BA.BALevel4'; break;
			}			
		}
		else RepSkin = none;
		/*if (Level.NetMode != NM_DedicatedServer)*/ Skins[0] = RepSkin;
	}	
	//Log("SideEffect ="@SideEffect@f@RepSkin@Skins[0]);
}

/** directly send the localized message */
function AnnouncePickupEx(Controller ctlr, BASideEffect effect)
{
	if (PlayerController(ctlr) == none) return;
	PlayerController(ctlr).ReceiveLocalizedMessage(MessageClassEx, effect, , , class);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	MessageClassEx=class'BAPickupMessage'	
}