////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// possible contaminated adrenaline pickup
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAdrenalinePickup.uc,v 1.7 2003/10/13 12:55:44 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAdrenalinePickup extends AdrenalinePickup dependson(BAmut);

#exec OBJ LOAD FILE=BadAdrenaline_tex.utx

/** side effect configuration, BASE_none is used if there's no match */
var array<BAmut.SERange> SEConfig;

/** how to display a bad adrenaline pill */
var byte VisualNotification, defVisualNotification;

/** current side effect */
var BAmut.BASideEffect SideEffect;
/** special local message for the side effects */
var class<PickupMessagePlus> MessageClassEx;

replication
{
	reliable if (Role == ROLE_Authority)
		VisualNotification, SideEffect, SetEffectSkin;
}

event BeginPlay()
{
	VisualNotification = default.defVisualNotification;
}

simulated function UpdatePrecacheMaterials()
{
	Super.UpdatePrecacheMaterials();
	Level.AddPrecacheMaterial(Material'BadAdrenaline_tex.BA.BALevel1');
	Level.AddPrecacheMaterial(Material'BadAdrenaline_tex.BA.BALevel2');
	Level.AddPrecacheMaterial(Material'BadAdrenaline_tex.BA.BALevel3');
	Level.AddPrecacheMaterial(Material'BadAdrenaline_tex.BA.BALevel4');
}

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
	SetEffectSkin();
	//Log("SideEffect ="@SideEffect@f@RepSkin@VisualNotification);
}

/** directly send the localized message */
function AnnouncePickupEx(Controller ctlr, BAmut.BASideEffect effect)
{
	if (PlayerController(ctlr) == none) return;
	PlayerController(ctlr).ReceiveLocalizedMessage(MessageClassEx, effect, , , class);
}

simulated function SetEffectSkin()
{
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
		if (Level.NetMode != NM_DedicatedServer) Skins[0] = RepSkin;
	}	
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	MessageClassEx=class'BAPickupMessage'	
}