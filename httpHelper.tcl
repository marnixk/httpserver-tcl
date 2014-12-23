namespace eval Http {

	proc urlDecode {str} {
		# rewrite "+" back to space
		# protect \ from quoting another '\'
		set str [string map [list + { } "\\" "\\\\"] $str]

		# prepare to process all %-escapes
		regsub -all -- {%([A-Fa-f0-9][A-Fa-f0-9])} $str {\\u00\1} str

		# process \u unicode mapped chars
		return [subst -novar -nocommand $str]
	}

}