////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// Ingame configuration page
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAconfig.uc,v 1.1 2003/10/14 10:56:46 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAconfig extends GUIPage dependson(BAmut);

var class<BAdrenalinePickup> AdrPill;
var SpinnyWeap AdrenalinePill;
var vector SpinnyAdrOffset;
var array<BAmut.SERange> TempSEConfig;
var GUIMultiColumnList mclTempConf;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local array<string> visnotitems;
	local int i;

	Super.InitComponent(MyController, MyOwner);

	moCheckBox(Controls[3]).MyLabel.Caption = class'BAmut'.default.msgSettingDesc[0];
	moCheckBox(Controls[3]).Checked(class'BAmut'.default.bResetOnDeath);

	moFloatEdit(Controls[4]).MyLabel.Caption = class'BAmut'.default.msgSettingDesc[1];
	moFloatEdit(Controls[4]).SetValue(class'BAmut'.default.fShroomDuration);
	moFloatEdit(Controls[5]).MyLabel.Caption = class'BAmut'.default.msgSettingDesc[2];
	moFloatEdit(Controls[5]).SetValue(class'BAmut'.default.smWanderSpeed);
	moFloatEdit(Controls[6]).MyLabel.Caption = class'BAmut'.default.msgSettingDesc[3];
	moFloatEdit(Controls[6]).SetValue(class'BAmut'.default.smAccel);

	moFloatEdit(Controls[7]).MyLabel.Caption = class'BAmut'.default.msgSettingDesc[4];
	moFloatEdit(Controls[7]).SetValue(class'BAmut'.default.fElastoDuration);
	moFloatEdit(Controls[8]).MyLabel.Caption = class'BAmut'.default.msgSettingDesc[5];
	moFloatEdit(Controls[8]).SetValue(class'BAmut'.default.emInitialBounce);
	moFloatEdit(Controls[9]).MyLabel.Caption = class'BAmut'.default.msgSettingDesc[6];
	moFloatEdit(Controls[9]).SetValue(class'BAmut'.default.emBounce);
	moNumericEdit(Controls[10]).MyLabel.Caption = class'BAmut'.default.msgSettingDesc[7];
	moNumericEdit(Controls[10]).SetValue(class'BAmut'.default.emFov);

	split(class'BAmut'.default.msgVisNotOpt, ";", visnotitems);
	for (i = 0; i < visnotitems.length-1; i += 2)
	{
		moComboBox(Controls[11]).AddItem(visnotitems[i+1]);
	}
	moComboBox(Controls[11]).MyLabel.Caption = class'BAmut'.default.msgSettingDesc[8];
	moComboBox(Controls[11]).SetIndex(class'BAmut'.default.VisualNotification);

	TempSEConfig = class'BAmut'.default.SEConfig;
	mclTempConf = GUIMultiColumnListBox(Controls[13]).List;
	mclTempConf.ItemCount = TempSEConfig.length;

	mclTempConf.ExpandLastColumn=true;
	mclTempConf.SortColumn=-1;
	mclTempConf.ColumnHeadings[0]="Effect";
	mclTempConf.InitColumnPerc[0]=0.4;
	mclTempConf.ColumnHeadings[1]="min";
	mclTempConf.InitColumnPerc[1]=0.2;
	mclTempConf.ColumnHeadings[2]="max";
	mclTempConf.InitColumnPerc[2]=0.2;
	mclTempConf.OnDrawItem=MyOnDrawItem;

	SetSpinnyAdrenaline();
}

function SetSpinnyAdrenaline()
{
	AdrPill = class<BAdrenalinePickup>(DynamicLoadObject(class'BAmut'.default.BadAdrenalineClassName, class'Class'));
	if (AdrPill == none) return;

	AdrenalinePill = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
	AdrenalinePill.LinkMesh( None );
	AdrenalinePill.SetStaticMesh( AdrPill.default.StaticMesh );
	AdrenalinePill.SetDrawScale( AdrPill.default.DrawScale );
	AdrenalinePill.SetDrawScale3D( AdrPill.default.DrawScale3D );
	SetAdrSkin(moComboBox(Controls[11]).GetIndex());
	AdrenalinePill.SetDrawType(DT_StaticMesh);
}

function SetAdrSkin(int skin)
{
	switch (skin)
	{
		case 1: AdrenalinePill.Skins[0] = material'BadAdrenaline_tex.BA.BALevel1'; break;
		case 2: AdrenalinePill.Skins[0] = material'BadAdrenaline_tex.BA.BALevel2'; break;
		case 3: AdrenalinePill.Skins[0] = material'BadAdrenaline_tex.BA.BALevel3'; break;
		case 4: AdrenalinePill.Skins[0] = material'BadAdrenaline_tex.BA.BALevel4'; break;
		default: AdrenalinePill.Skins.length = 0;
	}		
}

function bool InternalDraw(Canvas canvas)
{
	local vector CamPos, X, Y, Z, WX, WY, WZ;
	local rotator CamRot;

	if(AdrPill != None)
	{
		canvas.GetCameraLocation(CamPos, CamRot);
		GetAxes(CamRot, X, Y, Z);

		if(AdrenalinePill.DrawType == DT_Mesh)
		{
			GetAxes(AdrenalinePill.Rotation, WX, WY, WZ);
			AdrenalinePill.SetLocation(CamPos + (SpinnyAdrOffset.X * X) + (SpinnyAdrOffset.Y * Y) + (SpinnyAdrOffset.Z * Z) + (30 * WX));
		}
		else
		{
			AdrenalinePill.SetLocation(CamPos + (SpinnyAdrOffset.X * X) + (SpinnyAdrOffset.Y * Y) + (SpinnyAdrOffset.Z * Z));
		}
		canvas.DrawActor(AdrenalinePill, false, true, 90.0);
	}
	return false;
}

function InternalOnClose(optional Bool bCanceled)
{
	if (!bCanceled)	PageSaveINI();
	if(AdrenalinePill != None)
	{
		AdrenalinePill.Destroy();
	}
}

function OnVisNotChange(GUIComponent Sender)
{
	if(AdrPill != None)
	{
		SetAdrSkin(moComboBox(Controls[11]).GetIndex());
	}
}

function bool OnOkClick(GUIComponent Sender)
{
	class'BAmut'.default.bResetOnDeath = moCheckBox(Controls[3]).IsChecked();

	class'BAmut'.default.fShroomDuration = moFloatEdit(Controls[4]).GetValue();
	class'BAmut'.default.smWanderSpeed = moFloatEdit(Controls[5]).GetValue();
	class'BAmut'.default.smAccel = moFloatEdit(Controls[6]).GetValue();

	class'BAmut'.default.fElastoDuration = moFloatEdit(Controls[7]).GetValue();
	class'BAmut'.default.emInitialBounce = moFloatEdit(Controls[8]).GetValue();
	class'BAmut'.default.emBounce = moFloatEdit(Controls[9]).GetValue();
	class'BAmut'.default.emFov = moNumericEdit(Controls[10]).GetValue();

	class'BAmut'.default.VisualNotification = moComboBox(Controls[11]).GetIndex();
	class'BAmut'.default.SEConfig = TempSEConfig;

	class'BAmut'.static.StaticSaveConfig();
	Controller.CloseMenu(false);
	return true;
}

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected)
{
	local float CellLeft, CellWidth;

	if( bSelected )
  {
		Canvas.SetDrawColor(128,8,8,255);
		Canvas.SetPos(x,y-2);
		Canvas.DrawTile(Controller.DefaultPens[0],w,h+2,0,0,1,1);
		Canvas.SetDrawColor(255,255,255,255);
	}

	mclTempConf.GetCellLeftWidth( 0, CellLeft, CellWidth );
	mclTempConf.Style.DrawText( Canvas, mclTempConf.MenuState, X+CellLeft, Y, CellWidth, H, TXTA_Left, SEToString(TempSEConfig[i].effect));

	mclTempConf.GetCellLeftWidth( 1, CellLeft, CellWidth );
	mclTempConf.Style.DrawText( Canvas, mclTempConf.MenuState, X+CellLeft, Y, CellWidth, H, TXTA_Right, string(TempSEConfig[i].min)@"   ");

	mclTempConf.GetCellLeftWidth( 2, CellLeft, CellWidth );
	mclTempConf.Style.DrawText( Canvas, mclTempConf.MenuState, X+CellLeft, Y, CellWidth, H, TXTA_Right, string(TempSEConfig[i].max)@"   ");
}

function bool SEEdit(GUIComponent Sender)
{
	local int i;
	i = mclTempConf.Index;
	if (Sender == Controls[14]) // add
	{
		Controller.OpenMenu("BadAdrenaline.BAconfigEdit");
	}
	else if (Sender == Controls[15]) // edit
	{
		if (i >= 0 && i < TempSEConfig.length)
			Controller.OpenMenu("BadAdrenaline.BAconfigEdit", string(i));
	}
	else if (Sender == Controls[16]) // del
	{
		if (i >= 0 && i < TempSEConfig.length)
		{
			TempSEConfig.Remove(i, 1);
			mclTempConf.RemovedCurrent();
		}
	}
	return true;
}

function string SEToString(BAmut.BASideEffect se)
{
	switch (se)
	{
		case BASE_Shroom: return class'BAPickupMessage'.default.msgShroomsMode;
		case BASE_Elasto: return class'BAPickupMessage'.default.msgElastoMode;
	}
	return "";
}

defaultproperties
{
	Begin Object Class=GUIImage name=BACimgBG
		WinWidth=0.95
		WinHeight=0.95
		WinTop=0.025
		WinLeft=0.025
		bAcceptsInput=false
		bNeverFocus=true
		Image=Material'InterfaceContent.Menu.BorderBoxD'
		ImageStyle=ISTY_Stretched
	End Object
	Controls(0)=GUIImage'BACimgBG'

	Begin Object Class=GUIButton Name=BACbtnOK
		Caption="OK"
		WinWidth=0.200000
		WinHeight=0.040000
		WinLeft=0.400000
		WinTop=0.933333
		OnClick=OnOkClick
	End Object
	Controls(1)=GUIButton'BACbtnOK'

	Begin Object Class=GUILabel Name=BAClblBA
		Caption="Bad Adrenaline"
		StyleName="Header"
		TextAlign=TXTA_Center
		WinWidth=1.000000
		WinHeight=0.058750
		WinLeft=0.000000
		WinTop=0.033333
	End Object
	Controls(2)=GUILabel'BAClblBA'

	// ...

	Begin Object Class=moCheckBox Name=BACcbResetOnDeath
		Hint="Remove all side effects when a player dies"
		WinWidth=0.393750
		WinHeight=0.040000
		WinLeft=0.387500
		WinTop=0.108334
		ComponentWidth=0.160000
	End Object
	Controls(3)=moCheckBox'BACcbResetOnDeath'

	// shrooms mode

	Begin Object Class=moFloatEdit Name=BACfeShroomsDuration
		Hint="Number of seconds the effect will last"
		WinWidth=0.368750
		WinHeight=0.090000
		WinLeft=0.037500
		WinTop=0.158334
		MinValue=1
		MaxValue=9999
		Step=1
		bVerticalLayout=true
	End Object
	Controls(4)=moFloatEdit'BACfeShroomsDuration'

	Begin Object Class=moFloatEdit Name=BACfeWanderSpeed
		Hint="The distance the mouse will wander off"
		WinWidth=0.368750
		WinHeight=0.090000
		WinLeft=0.037500
		WinTop=0.255000
		MinValue=1
		MaxValue=99999
		Step=10
		bVerticalLayout=true
	End Object
	Controls(5)=moFloatEdit'BACfeWanderSpeed'

	Begin Object Class=moFloatEdit Name=BACfeAccel
		Hint="The speed of the mouse wander"
		WinWidth=0.368750
		WinHeight=0.090000
		WinLeft=0.037500
		WinTop=0.358334
		MinValue=0
		MaxValue=999
		Step=0.1
		bVerticalLayout=true
	End Object
	Controls(6)=moFloatEdit'BACfeAccel'

	// elasto mode

	Begin Object Class=moFloatEdit Name=BACfeElastoDuration
		Hint="Number of seconds the effect will last"
		WinWidth=0.368750
		WinHeight=0.090000
		WinLeft=0.587500
		WinTop=0.158334
		MinValue=1
		MaxValue=9999
		Step=1
		bVerticalLayout=true
	End Object
	Controls(7)=moFloatEdit'BACfeElastoDuration'

	Begin Object Class=moFloatEdit Name=BACfeInitialBounce
		Hint="The initial bounce a player will get"
		WinWidth=0.368750
		WinHeight=0.090000
		WinLeft=0.587500
		WinTop=0.258334
		MinValue=100
		MaxValue=99999
		Step=50
		bVerticalLayout=true
	End Object
	Controls(8)=moFloatEdit'BACfeInitialBounce'

	Begin Object Class=moFloatEdit Name=BACfeBounce
		Hint="The bounce a player get when it hits a wall"
		WinWidth=0.368750
		WinHeight=0.090000
		WinLeft=0.587500
		WinTop=0.366667
		MinValue=100
		MaxValue=99999
		Step=50
		bVerticalLayout=true
	End Object
	Controls(9)=moFloatEdit'BACfeBounce'

	Begin Object Class=moNumericEdit Name=BACneFov
		Hint="The FOV when in elasto mode"
		WinWidth=0.368750
		WinHeight=0.090000
		WinLeft=0.587500
		WinTop=0.466666
		MinValue=1
		MaxValue=200
		bVerticalLayout=true
	End Object
	Controls(10)=moNumericEdit'BACneFov'

	// bad adrenaline

	Begin Object Class=moComboBox Name=BACcbVisualEffect
		Hint="Visual notification of bad adrenaline"
		WinWidth=0.418750
		WinHeight=0.128750
		WinLeft=0.056250
		WinTop=0.583334
		bVerticalLayout=true
		bReadOnly=true
		OnChange=OnVisNotChange
	End Object
	Controls(11)=moComboBox'BACcbVisualEffect'

	Begin Object Class=GUIImage name=BACimgVisNot
		WinWidth=0.112500
		WinHeight=0.137500
		WinLeft=0.587500
		WinTop=0.583334
		bAcceptsInput=false
		bNeverFocus=true
		Image=Material'InterfaceContent.Menu.BorderBoxD'
		ImageStyle=ISTY_Stretched
	End Object
	Controls(12)=GUIImage'BACimgVisNot'

	Begin Object Class=GUIMultiColumnListBox name=BACmclSEset
		WinWidth=0.796251
		WinHeight=0.168750
		WinLeft=0.056250
		WinTop=0.741667				
	End Object
	Controls(13)=GUIMultiColumnListBox'BACmclSEset'

	Begin Object Class=GUIButton Name=BACbtnAdd
		Caption="ADD"
		WinWidth=0.087500
		WinHeight=0.040000
		WinLeft=0.856251
		WinTop=0.758333
		OnClick=SEEdit
	End Object
	Controls(14)=GUIButton'BACbtnAdd'

	Begin Object Class=GUIButton Name=BACbtnEdit
		Caption="EDIT"
		WinWidth=0.087500
		WinHeight=0.040000
		WinLeft=0.856251
		WinTop=0.808333
		OnClick=SEEdit
	End Object
	Controls(15)=GUIButton'BACbtnEdit'

	Begin Object Class=GUIButton Name=BACbtnDel
		Caption="DELETE"
		WinWidth=0.087500
		WinHeight=0.040000
		WinLeft=0.856251
		WinTop=0.858333
		OnClick=SEEdit
	End Object
	Controls(16)=GUIButton'BACbtnDel'

	WinLeft=0.1
	WinTop=0.1
	WinWidth=0.8
	WinHeight=0.8

	OnDraw=InternalDraw
	OnClose=InternalOnClose
	SpinnyAdrOffset=(X=200,Y=55,Z=-45)
}
