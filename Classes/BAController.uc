////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// The new player controller to screw with your game
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAController.uc,v 1.1 2003/10/10 08:00:46 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAController extends xPlayer;

#exec OBJ LOAD FILE=BadAdrenaline_rc.utx

#exec AUDIO IMPORT FILE="Sounds\ShroomsMode.wav" NAME="ShroomsModeSound"
#exec AUDIO IMPORT FILE="Sounds\ElastoMode.wav" NAME="ElastoModeSound"

/** sick time remaining */
var float fSickTime;

//// SHROOMS MODE ////
/** duration fo shrooms mode */
var float fShroomDuration;
/** true if in shrooms mode */
var bool bShroomsMode;
/** the amplitude */
var float smWanderSpeed;
/** the acceleration */
var float smAccel;
/** direction */
var float smWanderDirX, smWanderDirY;
/** the visual effect #1 */
var CameraOverlay smOverlay;
/** the visual effect #2 */
var MotionBlur smBlur;

//// ELASTO MODE ////
/** duration of elasto mode */
var float fElastoDuration;
/** true if in elasto mode */
var bool bElastoMode;


event PreBeginPlay()
{
	Super.PreBeginPlay();
	smOverlay = new class'CameraOverlay';
	smOverlay.OverlayMaterial = material'BadAdrenaline_rc.ShroomEffect';
	smBlur = new class'MotionBlur';
	smBlur.BlurAlpha = 127;
}

event PlayerTick( float DeltaTime )
{
	Super.PlayerTick(DeltaTime);
	if (fSickTime > 0)
	{
		fSickTime -= DeltaTime;
		if (fSickTime <= 0) ResetBAMode();
	}
}

function HandlePickup(Pickup pick)
{
	Super.HandlePickup(pick);
}

/** activate shrooms mode */
function ShroomsMode(optional bool bDisable)
{
	bShroomsMode = !bDisable;
	if (bShroomsMode) 
	{		
		smWanderSpeed = 400;
		smWanderDirX = 1;
		smWanderDirY = 1;
		smAccel = 2;
		AddCameraEffect(smOverlay, true);
		AddCameraEffect(smBlur, true);
		fSickTime = fShroomDuration;
	}
	else {
		RemoveCameraEffect(smOverlay);
		RemoveCameraEffect(smBlur);
	}
}

/** activate elasto mode */
function ElastoMode(optional bool bDisable)
{
	// Pawn.function AddVelocity( vector NewVelocity)
	bElastoMode = !bDisable;
	if (bElastoMode) 
	{		
		// ...
		fSickTime = fElastoDuration;
	}
	else {
	}
}

function ResetBAMode()
{
	fSickTime = 0;
	if (bShroomsMode) ShroomsMode(true);
	if (bElastoMode) ElastoMode(true);
}

defaultproperties
{
	InputClass=class'BAInput'

	fShroomDuration=15
	fElastoDuration=15
}