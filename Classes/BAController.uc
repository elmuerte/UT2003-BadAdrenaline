////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// The new player controller to screw with your game
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAController.uc,v 1.6 2003/10/12 14:12:54 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAController extends Info;

#exec OBJ LOAD FILE=BadAdrenaline_tex.utx

#exec AUDIO IMPORT FILE="Sounds\ShroomsMode.wav" NAME="ShroomsModeSound"
#exec AUDIO IMPORT FILE="Sounds\ElastoMode.wav" NAME="ElastoModeSound"

var xPlayer MyController;
var string BAHUDClass;
var BAHUD MyHud;

/** sick time remaining */
var float fSickTime;
var float fOrigSickTime;

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
/** the current positions */
var float smMouseWanderX, smMouseWanderY;
/** last change */
var float smLastDirChangeX, smLastDirChangeY;
/** the visual effect #1 */
var CameraOverlay smOverlay;
/** the visual effect #2 */
var MotionBlur smBlur;

//// ELASTO MODE ////
/** duration of elasto mode */
var float fElastoDuration;
/** true if in elasto mode */
var bool bElastoMode;
/** */
var float emVelX, emVelY;
/** */
var int emLastFov;
/** */
var EPhysics emLastPhys;

replication
{
	reliable if ( Role == ROLE_Authority )
		MyController, fSickTime, fOrigSickTime,
		fShroomDuration, bShroomsMode, smWanderSpeed, smAccel,
		fElastoDuration, bElastoMode,  
		ClientShroomsMode, ClientElastoMode, AddHud;
}

event PreBeginPlay()
{	
	Super.PreBeginPlay();
	if ( Role == ROLE_Authority )
	{
		MyController = xPlayer(Owner);
		if (MyController == none) 
		{
			Error("My owner is not a xPlayer:"@Owner);
			return;
		}	
	}	
}

event Tick( float DeltaTime )
{
	local float Rot;

	if (MyController == none) 
	{
		Destroy();
		return;
	}

	Super.Tick(DeltaTime);

	if ((Role < ROLE_Authority) || (Level.NetMode != NM_DedicatedServer))
	{
		if (bShroomsMode) 
		{
			MyController.aMouseX = ShroomInput(MyController.aMouseX, DeltaTime, 0);
			MyController.aMouseY = ShroomInput(MyController.aMouseY, DeltaTime, 1);
		}
	}

	if (bElastoMode && false)
	{
		if (MyController.Pawn != none)
		{
			MyController.DesiredFOV = 130;
			MyController.FOVAngle = 130;

			Rot = float(MyController.Pawn.Rotation.Yaw)/65535.0*Pi*2.0;

			emVelX += DeltaTime*Pi;
			if (emVelX > pi*2) emVelX = pi*2-emVelX;
			emVelY += DeltaTime*Pi;
			if (emVelY > pi) emVelY = pi-emVelY;

			MyController.Pawn.Velocity.X = 1000*sin(emVelX)*sin(rot)+1000*cos(rot);
			MyController.Pawn.Velocity.Y = 1000*cos(emVelX)*cos(rot)+1000*sin(rot);
			//MyController.Pawn.Velocity.z = sin(Pi*(fSickTime/fTotalSickTime))*50;

			log(MyController.Pawn.Velocity);
		}
	}

	if (fSickTime > 0)
	{
		fSickTime -= DeltaTime;
		if (fSickTime <= 0) ResetBAMode();
	}
}

function bool isSick()
{
	return (fSickTime > 0);
}

/** activate shrooms mode */
function ShroomsMode(optional bool bDisable)
{
	bShroomsMode = !bDisable;
	ClientShroomsMode(bShroomsMode);
	if (bShroomsMode) 
	{
		fSickTime = fShroomDuration;
		fOrigSickTime = fShroomDuration;
	}
	Log("ShroomsMode"@bShroomsMode);
}

/** activate shrooms mode on the client side */
simulated function ClientShroomsMode(bool bEnabled)
{
	if (MyHud == none) AddHud();
	if (bEnabled) 
	{		
		smWanderSpeed = 0.4;
		smWanderDirX = 1;
		smWanderDirY = 1;
		smAccel = 2.5;
		
		if (smOverlay == none)
		{
			smOverlay = new() class'CameraOverlay';
			smOverlay.OverlayMaterial = material'BadAdrenaline_tex.shroom.ShroomEffect';		
		}
		MyController.AddCameraEffect(smOverlay, true);

		if (smBlur == none)
		{
			smBlur = new() class'MotionBlur';
			smBlur.BlurAlpha = 127;
		}
		MyController.AddCameraEffect(smBlur, true);
		
		MyHud.EffectImage = Material'BadAdrenaline_tex.HUD.HudMushRoom';
		MyHud.ResetEffect();
	}
	else {
		MyController.RemoveCameraEffect(smOverlay);
		MyController.RemoveCameraEffect(smBlur);
	}
	MyHud.bActive = bEnabled;
	MyHud.bVisible = bEnabled;
	Log("ClientShroomsMode"@bEnabled);
}

/** activate elasto mode */
function ElastoMode(optional bool bDisable)
{
	// Pawn.function AddVelocity( vector NewVelocity)
	bElastoMode = !bDisable;
	ClientElastoMode(bElastoMode);
	if (bElastoMode) 
	{
		PendingTouch = MyController.Pawn.PendingTouch;
		MyController.Pawn.PendingTouch = self;

		fSickTime = fElastoDuration;
		fOrigSickTime = fElastoDuration;
	}
	Log("ElastoMode"@bElastoMode);
}

/** activate elasto mode on the client side */
simulated function ClientElastoMode(bool bEnabled)
{	
	if (MyHud == none) AddHud();
	if (bEnabled) 
	{
		emLastFov = MyController.DesiredFOV;
		//MyController.DesiredFOV = 130;
		//MyController.FOVAngle = 130;
		MyHud.EffectImage = Material'BadAdrenaline_tex.HUD.HudPinBall';
		MyHud.ResetEffect();
	}
	else {
		MyController.DesiredFOV = emLastFov;
		MyController.FOVAngle = emLastFov;
	}
	MyHud.bActive = bEnabled;
	MyHud.bVisible = bEnabled;
	Log("ClientElastoMode"@bEnabled);
}

event PostTouch( Actor Other )
{
	local float Rot;
	local vector pVect;
	local xPawn myXPawn;

	myXPawn = xPawn(MyController.Pawn);

	Rot = float(MyController.Pawn.Rotation.Yaw)/65535.0*Pi*2.0;
	pVect.X = cos(Rot) * 5000;
	pVect.Y = sin(Rot) * 5000;
	pVect.Z = 280;
		
	if ( myXPawn.Physics == PHYS_Walking ) myXPawn.SetPhysics(PHYS_Falling);

	myXPawn.Velocity =  pVect;
	myXPawn.Acceleration = vect(0,0,0);
}

/** reset the currently active effect */
function ResetBAMode()
{
	fSickTime = 0;
	if (bShroomsMode) ShroomsMode(true);
	if (bElastoMode) ElastoMode(true);
	Log("ResetBAMode");
}

simulated function AddHud()
{
	if ( (Role < ROLE_Authority) || (Level.NetMode != NM_DedicatedServer))
	{
		MyHud = BAHUD(MyController.Player.InteractionMaster.AddInteraction(BAHUDClass, MyController.Player));
		MyHud.BAC = Self;
	}
}

/** shrooms mode over the players input */
function float ShroomInput(float aMouse, float DeltaTime, int Index)
{
	if (index == 0)
	{
		if (smWanderDirX != 0) smMouseWanderX += DeltaTime*smAccel;
		if (smMouseWanderX > pi*2) smMouseWanderX = pi*2-smMouseWanderX;
		aMouse += smWanderDirX*cos(smMouseWanderX)*smWanderSpeed;		
	}
	else {
		if (smWanderDirY != 0) smMouseWanderY += DeltaTime*smAccel;
		if (smMouseWanderY > pi*2) smMouseWanderY = pi*2-smMouseWanderY;
		aMouse += smWanderDirY*cos(smMouseWanderY)*smWanderSpeed;
	}

	if ((sin(smMouseWanderX) > 0.9) && (sin(smMouseWanderY) > 0.9))
	{
		smWanderDirX = 0;
		smWanderDirY = 1;
	}
	else if ((sin(smMouseWanderX) < -0.9) && (sin(smMouseWanderY) < -0.9))
	{
		smWanderDirX = 1;
		smWanderDirY = 1;
	}
	else if ((sin(smMouseWanderX) < -0.9) && (sin(smMouseWanderY) > 0.9))
	{
		smWanderDirX = 0;
		smWanderDirY = 1;
	}
	else if ((sin(smMouseWanderX) > 0.9) && (sin(smMouseWanderY) < -0.9))
	{
		smWanderDirX = 1;
		smWanderDirY = 1;
	}
	return aMouse;
}

defaultproperties
{
	bAlwaysRelevant=true
	RemoteRole=ROLE_AutonomousProxy

	BAHUDClass="BadAdrenaline.BAHUD"

	fShroomDuration=30
	fElastoDuration=30
}