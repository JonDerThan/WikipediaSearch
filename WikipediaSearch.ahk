;----- Compiler Directives -----
;@Ahk2Exe-ExeName WikipediaSearch

;----- Directives -----
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.

;----- Options -----
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Mouse, Screen
Menu, Tray, Tip, WikipediaSearch

;----- Variables START -----

LanguageCode := "de"
SentenceCount := "10"	; Must be string with number from 1-10

;----- Variables STOP  -----

;----- Global -----
Endpoint := "https://" LanguageCode ".wikipedia.org/w/api.php"
Method := "GET"
PageidRegEx := """pageid"":(\d+)"
ExtractRegEx := """extract"":""(.+)"""

; Decodes the input from wikipedia, e.g. \u00fc -> ü	\n -> `n
Decode(String) {
	p := 1
	VarSetCapacity(var, 4)
	while p := InStr(String, "\u",, p) {
		p++
		hex := SubStr(String, ++p, 4)
		NumPut("0x" hex, var,, "UChar")
		chr := StrGet(&var)
		String := StrReplace(String, "\u" hex, chr)
		p--
	}
	String := StrReplace(String, "\n", "`n")
	
	Return String
}

; Got this from https://gist.github.com/anonymous1184/e6062286ac7f4c35b612d3a53535cc2a
EncodeUriComponent(String) {
	out := ""
	strLen := StrPut(String, "UTF-8")
	VarSetCapacity(var, strLen * 2)
	StrPut(String, &var, "UTF-8")
	while code := NumGet(var, A_Index - 1, "UChar") {
		chr := Chr(code)
		out .= chr ~= "[!'-*-\.0-9A-Z_a-z~]" ? chr : Format("%{:02x}", code)
	}
	return out
}

Search(Query) {
	; Make global variables accessible from within this function
	global Endpoint, Method, PageidRegEx, ExtractRegEx, SentenceCount
	
	HttpObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	
	; Fetch pageid for first result
	Url := Endpoint "?format=json&action=query&list=search&srlimit=1&srnamespace=0&srprop=&srinfo=&srsearch=" EncodeUriComponent(Query)
	HttpObj.Open(Method, Url)
	HttpObj.Send()
	RegExMatch(HttpObj.ResponseText, PageidRegEx, Match)
	Pageid := Match1
	
	; Fetch extract with pageid
	Url := Endpoint "?format=json&action=query&prop=extracts&exintro=true&explaintext=true&exsentences=" SentenceCount "&pageids=" pageid
	HttpObj.Open(Method, Url)
	HttpObj.Send()
	RegExMatch(HttpObj.ResponseText, ExtractRegEx, Match)
	Extract := Match1

	Return Decode(Extract)
}

;----- Hotkeys -----
#s::
	; Create input box at mouse position
	MouseGetPos, x, y
	InputBox, Query, Wikipedia Search,,, 200, 100, Min(x, 1700), Min(y, 900)

	; Return if user doesn't input anything, e.g. they pressed Cancel
	if (Query = "")
		return

	; Copy extract to clipboard for two reasons:
	;     -after the input box disappears, if a wrong window is focused user can still paste result
	;     -some symbols in wikipedia cause unexpected behaviour when just sending the symbols as input
	Clipboard := Search(Query)
	Send, {Control down}v{Control up}
	; Clipboard := "" ; Clear clipboard afterwards

	Return