////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// change the mouse movement
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAInput.uc,v 1.4 2003/10/13 12:55:44 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAInput extends PlayerInput;

/** the current positions */
var float smMouseWanderX, smMouseWanderY;

function float SmoothMouse(float aMouse, float DeltaTime, out byte SampleCount, int Index)
{
  local BAcontroller me;

  me = BAcontroller(outer);
  aMouse = Super.SmoothMouse(aMouse, DeltaTime, SampleCount, Index);

  if (!me.bShroomsMode) return aMouse;

  if (index == 0)
  {
    if (me.smWanderDirX != 0) smMouseWanderX += DeltaTime*me.smAccel;
    if (smMouseWanderX > pi*2) smMouseWanderX = pi*2-smMouseWanderX;
    aMouse += me.smWanderDirX*cos(smMouseWanderX)*me.smWanderSpeed;                
  }
  else {
    if (me.smWanderDirY != 0) smMouseWanderY += DeltaTime*me.smAccel;
    if (smMouseWanderY > pi*2) smMouseWanderY = pi*2-smMouseWanderY;
    aMouse += me.smWanderDirY*cos(smMouseWanderY)*me.smWanderSpeed;
  }

  if ((sin(smMouseWanderX) > 0.9) && (sin(smMouseWanderY) > 0.9))
  {
    me.smWanderDirX = 0;
    me.smWanderDirY = 1;
  }
  else if ((sin(smMouseWanderX) < -0.9) && (sin(smMouseWanderY) < -0.9))
  {
    me.smWanderDirX = 1;
    me.smWanderDirY = 1;
  }
  else if ((sin(smMouseWanderX) < -0.9) && (sin(smMouseWanderY) > 0.9))
  {
    me.smWanderDirX = 0;
    me.smWanderDirY = 1;
  }
  else if ((sin(smMouseWanderX) > 0.9) && (sin(smMouseWanderY) < -0.9))
  {
    me.smWanderDirX = 1;
    me.smWanderDirY = 1;
  }
  return aMouse;
}
