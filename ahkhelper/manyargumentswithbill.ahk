#noEnv ; #warn
#SingleInstance force
#notrayicon
sendMode Input
setWorkingDir %a_scriptDir%
menu, tray, add, Open Script Folder, Open_ScriptDir,
menu, tray, standard
needle:="([A-Za-z]:\\[^<>:" . chr(34) . "\/\|?*]+)"
arr:= [], n:=1
args:= a_args[1] . "c" ;just putting it on to take it off after
while,e:=regexmatch(args,needle,o,n) {
	n+= strlen(o)-1
	StringTrimRight, o, o, 1
	arr[a_index]:= o
}

for,i in arr
{
	FileGetTime, olddate_m ,% arr[i], m ;datemodified
	FileGetTime, olddate_c ,% arr[i], c ;datecreated
	FileGetTime, olddate_a ,% arr[i], a	;dateaccessed
	current:= splitpath(arr[i])
	, cmd:= comspec . " /c convert -quality 90 " . chr(34) . arr[i] . Chr(34) . " " . chr(34) . current.dir . "\" . current.fn . ".jpg" . chr(34)
	runwait,% cmd ,% current.dir,hide
	FileSetTime, olddate_m ,% current.dir . "\" . current.fn . ".jpg", m
	FileSetTime, olddate_c ,% current.dir . "\" . current.fn . ".jpg", c
	FileSetTime, olddate_a ,% current.dir . "\" . current.fn . ".jpg", a
}

sleep,100

for,i in arr
{
	try,filerecycle,% arr[i]
} return,

exitapp,

Open_ScriptDir:
toolTip %a_scriptFullPath%
z=explorer.exe /select,%a_scriptFullPath%
run %comspec% /C %z%,, hide
sleep 1250

ToolOff:
toolTip,
return
Explorer_GetIIPath(hwnd="")
{
	if !(window := Explorer_GetIIWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
		return A_Desktop
	path := window.LocationURL
	path := RegExReplace(path, "ftp://.*@","ftp://")
	StringReplace, path, path, file:///
	StringReplace, path, path, /, \, All 
	
	; thanks to polyethene
	Loop
		If RegExMatch(path, "i)(?<=%)[\da-f]{1,2}", hex)
			StringReplace, path, path, `%%hex%, % Chr("0x" . hex), All
		Else Break
	return path
}
Explorer_GetIIAll(hwnd="")
{
	return Explorer_GetII(hwnd)
}
Explorer_GetIISelection(hwnd="")
{
	return Explorer_GetII(hwnd,true)
}

Explorer_GetIIWindow(hwnd="")
{
	; thanks to jethrow for some pointers here
    WinGet, process, processName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")
    WinGetClass class, ahk_id %hwnd%
	
	if (process!="explorer.exe")
		return
	if (class ~= "(Cabinet|Explore)WClass")
	{
		for window in ComObjCreate("Shell.Application").Windows
			if (window.hwnd==hwnd)
				return window
	}
	else if (class ~= "Progman|WorkerW") 
		return "desktop" ; desktop found
}
Explorer_GetII(hwnd="",selection=false)
{
	if !(window := Explorer_GetIIWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
	{
		ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
		if !hwWindow ; #D mode
			ControlGet, hwWindow, HWND,, SysListView321, A
		ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%
		base := SubStr(A_Desktop,0,1)=="\" ? SubStr(A_Desktop,1,-1) : A_Desktop
		Loop, Parse, files, `n, `r
		{
			path := base "\" A_LoopField
			msgbox
			IfExist %path% ; ignore special icons like Computer (at least for now)
			 	ret .= path "`n"
		}
	}
	else
	{
		if selection
			collection := window.document.SelectedItems
		else
			collection := window.document.Folder.Items
		for item in collection
			ret .= item.path "`n"
	}
	return Trim(ret,"`n")
}
