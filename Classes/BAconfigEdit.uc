////////////////////////////////////////////////////////////////////////////////
// Bad Adrenaline
// Ingame configuration page
//
// Copyright 2003, Michiel "El Muerte" Hendriks
// $Id: BAconfigEdit.uc,v 1.1 2003/10/14 10:56:46 elmuerte Exp $
////////////////////////////////////////////////////////////////////////////////

class BAconfigEdit extends GUIPage dependson(BAmut);

var BAconfig SourcePage;
var int SourceIndex;

event HandleParameters(string Param1, string Param2)
{
	local int i;
	if (Param1 != "") SourceIndex = int(Param1);
		else SourceIndex = -1;

	for (i = Controller.MenuStack.length-1; i >= 0; i--)
	{
		if (BAconfig(Controller.MenuStack[i]) != none)
		{
			SourcePage = BAconfig(Controller.MenuStack[i]);
			break;
		}
	}

	for (i = 1; i < class'BAmut'.static.BASideEffectCount(); i++)
	{
		moComboBox(Controls[4]).AddItem(SourcePage.SEToString( BASideEffect(i) ));
	}

	if (SourceIndex > -1)
	{
		moComboBox(Controls[4]).SetIndex(int(SourcePage.TempSEConfig[SourceIndex].Effect)-1);
		moFloatEdit(Controls[2]).SetValue(SourcePage.TempSEConfig[SourceIndex].Min);
		moFloatEdit(Controls[3]).SetValue(SourcePage.TempSEConfig[SourceIndex].Max);
	}
}

function bool OnOkClick(GUIComponent Sender)
{
	if (SourceIndex == -1) 
	{
		SourceIndex = SourcePage.TempSEConfig.length;
		SourcePage.TempSEConfig.length = SourceIndex+1;
		SourcePage.mclTempConf.ItemCount = SourcePage.TempSEConfig.length;
	}
	SourcePage.TempSEConfig[SourceIndex].Effect = BASideEffect(moComboBox(Controls[4]).GetIndex()+1);
	SourcePage.TempSEConfig[SourceIndex].Min = moFloatEdit(Controls[2]).GetValue();
	SourcePage.TempSEConfig[SourceIndex].Max = moFloatEdit(Controls[3]).GetValue();
	Controller.CloseMenu(false);
	return true;
}

defaultproperties
{
	SourceIndex = -1;

	Begin Object Class=GUIImage name=BACimgBG
		WinWidth=0.5
		WinHeight=0.5
		WinTop=0.25
		WinLeft=0.25
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
		WinTop=0.683333
		OnClick=OnOkClick
	End Object
	Controls(1)=GUIButton'BACbtnOK'

	Begin Object Class=moFloatEdit Name=BACfeMin
		Caption="Min"
		WinWidth=0.462500
		WinHeight=0.090000
		WinLeft=0.268750
		WinTop=0.416667
		MinValue=0
		MaxValue=1
		Step=0.01
		bVerticalLayout=true
	End Object
	Controls(2)=moFloatEdit'BACfeMin'

	Begin Object Class=moFloatEdit Name=BACfeMax
		Caption="Max"
		WinWidth=0.463750
		WinHeight=0.090000
		WinLeft=0.268750
		WinTop=0.533334
		MinValue=0
		MaxValue=1
		Step=0.01
		bVerticalLayout=true
	End Object
	Controls(3)=moFloatEdit'BACfeMax'

	Begin Object Class=moComboBox Name=BACcbEffect
		Caption="Effect"
		WinWidth=0.462500
		WinHeight=0.128750
		WinLeft=0.268750
		WinTop=0.266668
		bVerticalLayout=true
		bReadOnly=true
	End Object
	Controls(4)=moComboBox'BACcbEffect'

	WinLeft=0.25
	WinTop=0.25
	WinWidth=0.5
	WinHeight=0.5
}
