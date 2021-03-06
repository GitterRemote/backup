


on date_time_to_iso(dt)
	(*
https://apple.stackexchange.com/questions/106350/how-do-i-save-a-screenshot-with-the-iso-8601-date-format-with-applescript
*)
	set {year:y, month:m, day:d, hours:h, minutes:min, seconds:s} to dt
	set y to text 2 through -1 of ((y + 10000) as text)
	set m to text 2 through -1 of ((m + 100) as text)
	set d to text 2 through -1 of ((d + 100) as text)
	set h to text 2 through -1 of ((h + 100) as text)
	set min to text 2 through -1 of ((min + 100) as text)
	set s to text 2 through -1 of ((s + 100) as text)
	return y & "-" & m & "-" & d & "T" & h & ":" & min & ":" & s
end date_time_to_iso


tell application "Evernote"
	
	
	(*
	I don't know why I have to use `from user domain` parameter in path to, others like `system domain/‌local domain` raise error, says "the folder doesn't exists and I don't have privilege to create it"
*)
	set appDocumentsDir to path to documents folder from user domain with folder creation
	log appDocumentsDir
	
	
	tell me to set FullDate to date_time_to_iso(current date)
	log FullDate
	
	
	tell application "Finder"
		(*
	I don't know why I have to use `from user domain` parameter in path to, others like `system domain/‌local domain` raise error, says "the folder doesn't exists and I don't have privilege to create it"
*)
		if (not (exists (folder "backup" of appDocumentsDir))) then
			set backFileDir to make new folder at appDocumentsDir with properties {name:"backup"}
		else
			set backFileDir to folder "backup" of appDocumentsDir
		end if
		
		if (not (exists (folder "evernote" of backFileDir))) then
			set backFileDir to make new folder at backFileDir with properties {name:"evernote"}
		else
			set backFileDir to folder "evernote" of backFileDir
		end if
		
		set backFileDir to make new folder at backFileDir with properties {name:FullDate}
		
		log backFileDir
	end tell
	
	
	
	set notebookNames to {}
	repeat with aNoteBook in notebooks
		set notebookNames to notebookNames & (name of aNoteBook)
	end repeat
	
	(*
	set notebookNames to {"I am here"}
*)
	log notebookNames
	
	
	repeat with notebookName in notebookNames
		
		set backFilePath to ((backFileDir as text) & notebookName & ".enex")
		set quotedFormOfNotebookName to "\"" & notebookName & "\""
		set matches to find notes "notebook:" & quotedFormOfNotebookName
		log backFilePath
		log (count of matches)
		(*
		export matches to backFilePath
*)
		
	end repeat
	
	
	tell application "Finder"
		(*
		using backFileDir from evernote backup files, move backupfiles to dir where I want to store them and gzip them
*)
		set userDocumentsDir to path to documents folder from user domain with folder creation
		(* if appDocumentsDir is not the same as userDocumentsDir *)
		set userBackFileDir to folder "evernote" of folder "backup" of userDocumentsDir
		log "move from " & backFileDir & " to " & userBackFileDir
		set userBackFiles to move backFileDir to userBackFileDir without replacing
		
		(* because that in HFS path names, a colon ":", is used as a separator, and in POSIX path names, a forward slash "/" is used as a separator.
		https://en.wikibooks.org/wiki/AppleScript_Programming/Aliases_and_paths
		
		and the folder name using current date which contains colon which was converted to backslack in the HFS path, such as folder/file/alias. Actually, its name is using colon, so I have to convert it to POSIX path before get its name. I can't use `info for` directly on the HFS file/alias.
		*)
		
		set filename to do shell script "basename " & quoted form of POSIX path of (userBackFiles as alias)
		log filename
		set tarCMD to "cd " & quoted form of POSIX path of (userBackFileDir as alias) & " && tar -zcf " & quoted form of (filename & ".tar.gz") & " " & quoted form of filename & " && rm -r " & quoted form of filename
		log tarCMD
		do shell script tarCMD
		(*
		only keep 15 backups / or keep in size
*)
	end tell
	
	
end tell


