////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// client side notification message
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAPickupMessage.uc,v 1.2 2003/10/14 10:56:46 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAPickupMessage extends PickupMessagePlus;

var localized string msgShroomsMode, msgElastoMode;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	switch(SwitchNum)
	{
		case 1: return Caps(Default.msgShroomsMode)@" !!!";
		case 2: return Caps(Default.msgElastoMode)@" !!!";
	}
	return "";
}

defaultproperties
{
	PosY=0.75
	DrawColor=(R=0,G=255,B=0,A=255)

	msgShroomsMode="Shrooms Mode"
	msgElastoMode="Elasto Mode"
}