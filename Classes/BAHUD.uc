////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// Show the current effect on screen
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAHUD.uc,v 1.1 2003/10/11 16:04:04 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAHUD extends Interaction;

var BAController BAC;

var Material EffectImage;

/** remove ourself */
simulated function NotifyLevelChange ()
{
 	Master.RemoveInteraction(Self);
}

/** */
simulated function ResetEffect()
{
	if (EffectImage == none)
	{
		bActive=false;
		bVisible=false;
	}
}

simulated function PostRender( canvas Canvas )
{
	local float LScale, Proc;
	Proc = BAC.fSickTime/BAC.fOrigSickTime;
	Canvas.SetDrawColor(255,255,255, 255*FMin(0.5*Proc+0.5, 1));
	Canvas.SetPos(Canvas.SizeX-(Proc*EffectImage.MaterialUSize()), (Canvas.SizeY-EffectImage.MaterialVSize())/2);
	LScale = Canvas.SizeY/EffectImage.MaterialVSize()*0.2;
  Canvas.DrawTileScaled(EffectImage, LScale, LScale);
}

defaultproperties
{
	bActive=false
	bVisible=false
}