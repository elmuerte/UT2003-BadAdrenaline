////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// The new player controller to screw with your game
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAController.uc,v 1.8 2003/10/13 12:55:44 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAController extends xPlayer;

#exec OBJ LOAD FILE=BadAdrenaline_tex.utx

#exec AUDIO IMPORT FILE="Sounds\ShroomsMode.wav" NAME="ShroomsModeSound"
#exec AUDIO IMPORT FILE="Sounds\ElastoMode.wav" NAME="ElastoModeSound"
#exec AUDIO IMPORT FILE="Sounds\ElastoBounce.wav" Name="ElastoBounceSound"

var string BAHUDClass;
var BAHUD MyBAHud;

/** sick time remaining */
var float fSickTime;
var float fOrigSickTime;

/** reset effects when the player died */
var bool bResetOnDeath, defbResetOnDeath;

//// SHROOMS MODE ////
/** duration fo shrooms mode */
var float fShroomDuration, deffShroomDuration;
/** true if in shrooms mode */
var bool bShroomsMode;
/** the amplitude */
var float smWanderSpeed, defsmWanderSpeed;
/** the acceleration */
var float smAccel, defsmAccel;
/** direction */
var float smWanderDirX, smWanderDirY;
/** last change */
var float smLastDirChangeX, smLastDirChangeY;
/** the visual effect #1 */
var CameraOverlay smOverlay;
/** the visual effect #2 */
var MotionBlur smBlur;

//// ELASTO MODE ////
/** duration of elasto mode */
var float fElastoDuration, deffElastoDuration;
/** true if in elasto mode */
var bool bElastoMode;
/** settings to bounce the player around */
var float emInitialBounce, emBounce, defemInitialBounce, defemBounce;
/** the direction to hurl the player at */
var vector emDirection, emLastVect;
/** the fov when Elasto Mode is active */
var int emFov, defemFov;
/** the last FOV */
var int emLastFov;
/** set to true when to update the player movement */
var bool DoElastoPostTouch;

replication
{
	reliable if ( Role == ROLE_Authority )		
		fShroomDuration, smWanderSpeed, smAccel,
		fElastoDuration, emInitialBounce, emBounce, emFov,
		ClientShroomsMode, ClientElastoMode, AddHud;

	unreliable if ( Role == ROLE_Authority )
		fSickTime, fOrigSickTime;
	reliable if ( Role == ROLE_Authority )
		bShroomsMode, bElastoMode;

	reliable if ( Role < ROLE_Authority )
		ElastoMode, ShroomsMode, ResetBAMode;
}

event PreBeginPlay()
{	
	Super.PreBeginPlay();
	enable('NotifyHitWall');	
}

event BeginPlay()
{
	bResetOnDeath = default.defbResetOnDeath;
	fShroomDuration = default.deffShroomDuration;
	smWanderSpeed = default.defsmWanderSpeed;
	smAccel = default.defsmAccel;
	fElastoDuration = default.deffElastoDuration;
	emInitialBounce = default.defemInitialBounce;
	emBounce = default.defemBounce;
	emFov = default.defemFov;
}

event PlayerTick( float DeltaTime )
{
	local BAdrenalinePickup BAP;

	Super.PlayerTick(DeltaTime);	

	if (bElastoMode) // prevent FOV fixing
	{
		SetFOV(emFov);
	}
	if (fSickTime > 0) 
	{
		fSickTime -= DeltaTime;
		if (fSickTime <= 0) ResetBAMode();
	}

	// directy hack to fix skin replication
	foreach DynamicActors(Class'BAdrenalinePickup', BAP)
	{
		if (BAP.SideEffect != BASE_none)
		{
			if (BAP.Skins.length <= 0 && BAP.VisualNotification > 0) 
			{
				BAP.SetEffectSkin();
			}
		}
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
	//Log("ShroomsMode"@bShroomsMode);
}

/** activate shrooms mode on the client side */
simulated function ClientShroomsMode(bool bEnabled)
{
	if (MyBAHud == none) AddHud();
	if (bEnabled) 
	{
		smWanderDirX = 1;
		smWanderDirY = 1;		
		
		if (smOverlay == none)
		{
			smOverlay = new() class'CameraOverlay';
			smOverlay.OverlayMaterial = material'BadAdrenaline_tex.shroom.ShroomEffect';		
		}
		AddCameraEffect(smOverlay, true);

		if (smBlur == none)
		{
			smBlur = new() class'MotionBlur';
			smBlur.BlurAlpha = 127;
		}
		AddCameraEffect(smBlur, true);
		
		MyBAHud.EffectImage = Material'BadAdrenaline_tex.HUD.HudMushRoom';
		MyBAHud.ResetEffect();
	}
	else {
		RemoveCameraEffect(smOverlay);
		RemoveCameraEffect(smBlur);
	}
	MyBAHud.bActive = bEnabled;
	MyBAHud.bVisible = bEnabled;
	//Log("ClientShroomsMode"@bEnabled);
}

/** activate elasto mode */
function ElastoMode(optional bool bDisable)
{
	local float Rot;
	bElastoMode = !bDisable;
	ClientElastoMode(bElastoMode);
	if (bElastoMode) 
	{
		Rot = float(Pawn.Rotation.Yaw)/65535.0*Pi*2.0;
		emDirection.X = cos(Rot) * (emInitialBounce * 0.75 + emInitialBounce * (0.5 * frand() - 0.25));
		emDirection.Y = sin(Rot) * (emInitialBounce * 0.75 + emInitialBounce * (0.5 * frand() - 0.25));
		emDirection.Z = 280;
		PendingTouch = Pawn.PendingTouch;
		Pawn.PendingTouch = self;
		DoElastoPostTouch = true;		

		fSickTime = fElastoDuration;
		fOrigSickTime = fElastoDuration;
	}
	else {
		
	}
	//Log("ElastoMode"@bElastoMode);
}

/** activate elasto mode on the client side */
simulated function ClientElastoMode(bool bEnabled)
{	
	if (MyBAHud == none) AddHud();
	if (bEnabled) 
	{
		emLastFov = DesiredFOV;
		SetFOV(emFov);
		MyBAHud.EffectImage = Material'BadAdrenaline_tex.HUD.HudPinBall';
		MyBAHud.ResetEffect();
	}
	else {
		SetFOV(emLastFov);
	}
	MyBAHud.bActive = bEnabled;
	MyBAHud.bVisible = bEnabled;
	//Log("ClientElastoMode"@bEnabled);
}

event bool NotifyHitWall(vector HitNormal, actor Wall)
{
	if (bElastoMode && (emLastVect != HitNormal))
	{
		emLastVect = HitNormal;
		HitNormal *= emBounce;
		emDirection.X = HitNormal.X;
		emDirection.Y = HitNormal.Y;
		emDirection.Z = HitNormal.Z;
		if (emDirection.Z <= 0) emDirection.Z = 280;
		PendingTouch = Pawn.PendingTouch;
		Pawn.PendingTouch = self;
		PlaySound( sound'BadAdrenaline.ElastoBounceSound', SLOT_Talk ); 
	}
	return Super.NotifyHitWall(HitNormal, Wall);
}

event PostTouch( Actor Other )
{
	Super.PostTouch(Other);
	if (!DoElastoPostTouch) return;	
	if ( Pawn.Physics == PHYS_Walking ) Pawn.SetPhysics(PHYS_Falling);
	Pawn.Velocity =  emDirection;
	Pawn.Acceleration = vect(0,0,0);
}

/** reset the currently active effect */
function ResetBAMode()
{
	fSickTime = 0;
	if (bShroomsMode) ShroomsMode(true);
	if (bElastoMode) ElastoMode(true);
	//Log("ResetBAMode");
}

/** add out hud interaction */
simulated function AddHud()
{
	if ( (Role < ROLE_Authority) || (Level.NetMode != NM_DedicatedServer))
	{
		MyBAHud = BAHUD(Player.InteractionMaster.AddInteraction(BAHUDClass, Player));
		MyBAHud.BAC = Self;
	}
}

state Dead
{
begin:
	if (bResetOnDeath) ResetBAMode();
}

defaultproperties
{
	MinHitWall=1
	BAHUDClass="BadAdrenaline.BAHUD"
	InputClass=class'BadAdrenaline.BAInput'
}