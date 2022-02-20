Simple [AutoHotkey](https://www.autohotkey.com/) script to search Wikipedia for a short description.

# Usage
Press `[Win] + [S]` to open a small window where you can input your query. After pressing enter, a short summary of the first Wikipedia article will be pasted in your clipboard.

To change the language or the word count of your summarys simply edit the file with a regular text editor:
```ahk
;----- Variables START -----

LanguageCode := "de"
SentenceCount := "10"	; Must be string with number from 1-10

;----- Variables STOP  -----
```
