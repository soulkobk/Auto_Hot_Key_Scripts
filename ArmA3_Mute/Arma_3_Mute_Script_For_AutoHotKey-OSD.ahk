;------------------------------------------------------------------------------
;	
;	Copyright © 2015 soulkobk (soulkobk.blogspot.com)
;
;	This program is free software: you can redistribute it and/or modify
;	it under the terms of the GNU Affero General Public License as
;	published by the Free Software Foundation, either version 3 of the
;	License, or (at your option) any later version.
;
;	This program is distributed in the hope that it will be useful,
;	but WITHOUT ANY WARRANTY; without even the implied warranty of
;	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;	GNU Affero General Public License for more details.
;
;	You should have received a copy of the GNU Affero General Public License
;	along with this program. If not, see <http://www.gnu.org/licenses/>.
;
;------------------------------------------------------------------------------
; 10 April 2015
;------------------------------------------------------------------------------
; This script was put together by soul[kobk] from 3 pre-existing scripts for
; autohotkey (John T, Xander Lih, Geekdude), customised and modIfied to suit
; Arma 3 with the help of (in no particular order) T_Lube, Linear Spoon and
; Masonjar13. Now you are able to control volume and mute with ease!
;------------------------------------------------------------------------------
; P.S. For all players that will use this script, you're welcome.
;------------------------------------------------------------------------------
; PLEASE READ THE FOLLOWING STATEMENTS BEFORE ASKING STUPID QUESTIONS!
;	[!] This script is bundled with VA.ahk 2.3.
;		https://dl.dropbox.com/u/20532918/Lib/VA-2.3.zip
;	[!] Please place VA.ahk in the same directory the mute/volume script is located.
;	[!] Please make sure that "Volume Mixer" is kept open at all times the script
;		is running, else you will encounter errors.
;	[!] When running this script, the hot keys (and on screen display) will only
;		work if the Arma 3 window is active and focused.
;------------------------------------------------------------------------------
;	Keyboard controls are as below...
;	[*] Volume DOWN (decremented by 5) = Ctrl with Numpad -
;	[*] Volume UP (incremented by 5) = Ctrl with Numpad +
;	[*] Volume MUTE/UNMUTE = Ctrl with Numpad *
;------------------------------------------------------------------------------
; ChangeLog...
;	[x] Changed scripting structure for use with AHK Version 1.1.19.01
;		Download the current version from http://ahkscript.org/download
;	[x] Added OSD functioning via a progress bar and MUTE text.
;	[x] Added script use for VA.ahk for a different way to retrieve volume and 
;		mute state for use with OSD.
;	[x] Added in manually changeable variable text for ease of script use for
;		the end user, including the key binds.
;	[x] Changed the key binds to not interfere with in-game Arma 3 zoom feature.
;------------------------------------------------------------------------------
; USER CHANGEABLE VARIABLES, PLEASE CHANGE THEM TO SUIT YOUR NEEDS, AKA LANGUAGE.
;------------------------------------------------------------------------------
; VOLUME MIXER PROGRAM VARIABLES
global VolMix = "SndVol.exe" ; Volume Mixer executable name.
global VolMixTitle = "Volume Mixer" ; Title of Volume Mixer (in your O/S language).
;------------------------------------------------------------------------------
; ARMA 3 PROGRAM VARIABLES
global Arma3Exe = "Arma3.exe" ; Arma 3 executable name, as shown in Task Manager.
global Arma3Title = "Arma 3" ; The title of Arma 3 as shown in Volume Mixer.
;------------------------------------------------------------------------------
; ON SCREEN DISPLAY VARIABLES
global OSDShow = "YES" ; Show the OSD or not? NO to disable.
global OSDTimeOut = "YES" ; YES (removes itself from screen), NO (stays on screen).
global OSDTimer = "2000" ; Time for volume OSD to show, 2000ms aka 2seconds.
global OSDTMute = "YES" ; Time out the MUTE display also? YES = on, NO = off.
;------------------------------------------------------------------------------
; VOLUME INCREMENT/DECREMENT
global VolNum = "5"
;------------------------------------------------------------------------------
; KEY BINDS SHOULD YOU WANT TO CHANGE THEM YOURSELF!
; Find the available hot keys here... http://www.autohotkey.com/docs/KeyList.htm
; Volume UP = search for "^NumPadAdd" and replace all instances with your key of choice!
; Volume DOWN = search for "^NumPadSub" and replace all instances with your key of choice!
; Volume (UN)MUTE = search for "^NumPadMult" and replace all instances with your key of choice!
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; DO NOT CHANGE ANYTHING BELOW, AS YOU RISK BREAKING THE SCRIPT!
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

SetWorkingDir %A_ScriptDir%

#Include %A_ScriptDir%\VA.ahk

SetTitleMatchMode, 2

IfWinNotExist, %VolMixTitle%
{
	Run, "%VolMix%" -r 88888888
	WinSet, Top,, ahk_class %VolMixTitle%
}

Loop
{
	IfWinNotActive, ahk_class %Arma3Title%
	{
		Progress, 1:OFF
		Progress, 2:OFF
		Suspend, ON
	}
	IfWinActive, ahk_class %Arma3Title%
	{
		Suspend, OFF
	}
	Sleep 100
}

;------------------------------------------------------------------------------

$^NumPadSub::
VolDn()
Return
;Hotkey to decrease volume
^NumPadSub::^NumPadSub
	
;------------------------------------------------------------------------------

VolDn()
{
	IfWinExist, ahk_class %Arma3Title%
	{
		IfWinActive, ahk_class %Arma3Title%
		{
			Process, Exist, %Arma3Exe%
			If !(Arma3PID := ErrorLevel)
			{
				MsgBox, 16, %Arma3Title% Error!, ERROR: %Arma3Exe% does not exist - please make sure %Arma3Title% is running.
				Return
			}
			ToolbarWindowNumber = 322
			msctls_trackbarNumber = 321
			Loop {
				ControlGetText, ControlName, ToolbarWindow%ToolbarWindowNumber%, %VolMixTitle%
				RegExMatch( ControlName , "Mute for *" Arma3Title "*" , ControlName ) ; regex fix for use with full screen, window mode and full screen window
				If ControlName = Mute for %Arma3Title%
				{
					ControlSend, msctls_trackbar%msctls_trackbarNumber%, {Down %VolNum%}, %VolMixTitle%
					VolumeObject := GetVolumeObject(Arma3PID)
					VA_ISimpleAudioVolume_GetMute(VolumeObject, AppMute)
					VA_ISimpleAudioVolume_GetMasterVolume(VolumeObject, AppVolume)
					ObjRelease(VolumeObject)
					GlobalVolume := VA_GetMasterVolume()
					GlobalMute := VA_GetMasterMute()
					ArmaCurVol := % (GlobalMute || AppMute ? "MUTED" : Round(AppVolume*GlobalVolume,0))
					If (OSDShow = "YES")
					{
						OSD(ArmaCurVol)
					}
					Break
				} Else {
					If ToolbarWindowNumber < 328
					{
						ToolbarWindowNumber := ToolbarWindowNumber + 2
						msctls_trackbarNumber := msctls_trackbarNumber + 1
					} Else {
						If ToolbarWindowNumber = 328
						{
							ToolbarWindowNumber = 3210
							msctls_trackbarNumber := msctls_trackbarNumber + 1
						} Else {
							If ToolbarWindowNumber < 3242
							{
								ToolbarWindowNumber := ToolbarWindowNumber + 2
								msctls_trackbarNumber := msctls_trackbarNumber + 1
							} Else {
								MsgBox, 16, Volume Mixer Error!, ERROR: Volume Mixer is not found!`nThis could occur If the Volume Mixer has more than 20 opened`napplications or the Volume Mixer was accidentally closed.
								Break
							}
						}
					}
				}
			}
		}
	}
	Return
}

;------------------------------------------------------------------------------

$^NumPadAdd::
VolUp()
Return
;Hotkey to increase volume
^NumPadAdd::^NumPadAdd

;------------------------------------------------------------------------------

VolUp()
{
	IfWinExist, ahk_class %Arma3Title%
	{
		IfWinActive, ahk_class %Arma3Title%
		{
			Process, Exist, %Arma3Exe%
			If !(Arma3PID := ErrorLevel)
			{
				MsgBox, 16, %Arma3Title% Error!, ERROR: %Arma3Exe% does not exist - please make sure %Arma3Title% is running.
				Return
			}
			ToolbarWindowNumber = 322
			msctls_trackbarNumber = 321
			Loop {
				ControlGetText, ControlName, ToolbarWindow%ToolbarWindowNumber%, %VolMixTitle%
				RegExMatch( ControlName , "Mute for *" Arma3Title "*" , ControlName ) ; regex fix for use with full screen, window mode and full screen window
				If ControlName = Mute for %Arma3Title%
				{
					ControlSend, msctls_trackbar%msctls_trackbarNumber%, {Up %VolNum%}, %VolMixTitle%
					VolumeObject := GetVolumeObject(Arma3PID)
					VA_ISimpleAudioVolume_GetMute(VolumeObject, AppMute)
					VA_ISimpleAudioVolume_GetMasterVolume(VolumeObject, AppVolume)
					ObjRelease(VolumeObject)
					GlobalVolume := VA_GetMasterVolume()
					GlobalMute := VA_GetMasterMute()
					ArmaCurVol := % (GlobalMute || AppMute ? "MUTED" : Round(AppVolume*GlobalVolume,0))
					If (OSDShow = "YES")
					{
						OSD(ArmaCurVol)
					}
					Break
				} Else {
					If ToolbarWindowNumber < 328
					{
						ToolbarWindowNumber := ToolbarWindowNumber + 2
						msctls_trackbarNumber := msctls_trackbarNumber + 1
					} Else {
						If ToolbarWindowNumber = 328
						{
							ToolbarWindowNumber = 3210
							msctls_trackbarNumber := msctls_trackbarNumber + 1
						} Else {
							If ToolbarWindowNumber < 3242
							{
								ToolbarWindowNumber := ToolbarWindowNumber + 2
								msctls_trackbarNumber := msctls_trackbarNumber + 1
							} Else {
								MsgBox, 16, Volume Mixer Error!, ERROR: Volume Mixer is not found!`nThis could occur If the Volume Mixer has more than 20 opened`napplications or the Volume Mixer was accidentally closed.
								Break
							}
						}
					}
				}
			}
		}
	}
	Return
}

;------------------------------------------------------------------------------

$^NumPadMult::
VolMt()
Return
;Hotkey to mute/unmute volume
^NumPadMult::^NumPadMult

;------------------------------------------------------------------------------

VolMt()
{
	IfWinExist, ahk_class %Arma3Title%
	{
		IfWinActive, ahk_class %Arma3Title%
		{
			Process, Exist, %Arma3Exe%
			If !(Arma3PID := ErrorLevel)
			{
				MsgBox, 16, %Arma3Title% Error!, ERROR: %Arma3Exe% does not exist - please make sure %Arma3Title% is running.
				Return
			}
			ToolbarWindowNumber = 322
			msctls_trackbarNumber = 321
			ControlGetPos, refX, refY, refW, refH, %Arma3Title%, %VolMixTitle%
			x = -1
			While ( x != "")
			{
				tbIDX := (A_Index * 2)
				ControlGetPos, x, y, w, h, ToolbarWindow32%tbIDX%, %VolMixTitle%
				dIff := x - refX
				If (dIff > 0 && dIff < refW)
				{
					ControlClick, ToolbarWindow32%tbIDX%, %VolMixTitle%
					VolumeObject := GetVolumeObject(Arma3PID)
					VA_ISimpleAudioVolume_GetMute(VolumeObject, AppMute)
					VA_ISimpleAudioVolume_GetMasterVolume(VolumeObject, AppVolume)
					ObjRelease(VolumeObject)
					GlobalVolume := VA_GetMasterVolume()
					GlobalMute := VA_GetMasterMute()
					ArmaCurVol := % (GlobalMute || AppMute ? "MUTED" : Round(AppVolume*GlobalVolume,0))
					If (OSDShow = "YES")
					{
						OSD(ArmaCurVol)
					}
					Break
				}
			}
		}
	}
	Return
}

;------------------------------------------------------------------------------

OSD(ArmaCurVol)
{
	If ArmaCurVol is Integer
	{
		Progress 2:Off
		PBBarOptionsArma = 1:B0 ZH20 ZW0 ZX0 ZY0 W200 CBC0C0C0 CW000000 CTFFFFFF Y4
		IfWinNotExist, OSDProgress
		{
			Progress, %PBBarOptionsArma%, , , OSDProgress
		}
		Progress, 1:%ArmaCurVol%
		If (OSDTimeOut = "YES")
		{
			SetTimer, OSDTimed, %OSDTimer%
		}
	}
	If (ArmaCurVol = "MUTED")
	{
		Progress 1:Off
		PBBarOptionsArma = 2:B0 ZH0 ZW0 ZX0 ZY0 W200 CBC0C0C0 CW000000 CTFF0000 Y4
		Progress, %PBBarOptionsArma%, %Arma3Title% %ArmaCurVol%, , OSDProgress
		If ((OSDTimeOut = "YES") && (OSDTMute = "YES"))
		{
			SetTimer, OSDTimed, %OSDTimer%
		} Else {
			SetTimer, OSDTimed, OFF
		}
	}
}

;------------------------------------------------------------------------------
	
GetVolumeObject(Param = 0)
{
	static IID_IASM2 := "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}"
	, IID_IASC2 := "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}"
	, IID_ISAV := "{87CE5498-68D6-44E5-9215-6DA47EF883D8}"
	If Param is not Integer
	{
		Process, Exist, %Param%
		Param := ErrorLevel
	}
	DAE := VA_GetDevice()
	VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)
	VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
	VA_IAudioSessionEnumerator_GetCount(IASE, Count)
	Loop, % Count
	{
		VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)
		IASC2 := ComObjQuery(IASC, IID_IASC2)
		ObjRelease(IASC)
		VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)
		If (SPID == Param)
		{
			ISAV := ComObjQuery(IASC2, IID_ISAV)
			ObjRelease(IASC2)
			break
		}
		ObjRelease(IASC2)
	}
	ObjRelease(IASE)
	ObjRelease(IASM2)
	ObjRelease(DAE)
	Return ISAV
}

;------------------------------------------------------------------------------

VA_ISimpleAudioVolume_GetMute(this, ByRef Muted) {
	Return DllCall(NumGet(NumGet(this+0)+6*A_PtrSize), "ptr", this, "int*", Muted)
}

;------------------------------------------------------------------------------

VA_ISimpleAudioVolume_GetMasterVolume(this, ByRef fLevel) {
	Return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "float*", fLevel)
}

;------------------------------------------------------------------------------
	
OSDTimed:
{
	SetTimer, OSDTimed, OFF
	Progress, 1:OFF
	Progress, 2:OFF
	Return
}

;------------------------------------------------------------------------------
; WHY ARE YOU BEING NOSEY AND LOOKING ALL THE WAY DOWN HERE?
;------------------------------------------------------------------------------