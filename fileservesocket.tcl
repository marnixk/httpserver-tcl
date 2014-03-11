#
#   Default fallback for requests coming into the server.
#
namespace eval FileServeSocket {

	variable debug 0
	variable contexts
	variable mimetypes {
		.html text/html
		.css text/css
		.js text/javascript
		.json text/json
		.xml text/xml

		.jpg image/jpeg 
		.png image/png 
		.gif image/gif
	}

	#
	#   Read from the http socket and dispatch it to the current state's handler
	#
	proc read-from-socket {chan} {

		set left [gets $chan line]
		if { $left < 0 } {
			if { [eof $chan] } {
				close $chan
				return
			}
		} else {
			$HttpServer::state($chan) $chan $line
		}
	}

	#
	#	Read headers from the request
	#
	proc read-headers {chan line} {

		set headername [string range [lindex $line 0] 0 end-1]
		set value [string range $line [expr {2 + [string length $headername]}] end]
		
		log " .. $headername: $value"

		set HttpServer::state($chan,$headername) $value

		if {$line == ""} then {
			log ".. done reading headers"
			send-file $chan
		}
	}

	#
	#   Find the first file match in the bases we are tracking.
	#
	proc find-first-match {filename} {
		variable contexts

		foreach ctx $contexts {
			set lookingfor "$ctx/$filename"
			if { [file exists $lookingfor] } then {
				file stat $lookingfor stat
				return [list info [array get stat] name $lookingfor]
			}
		}

		return {}
	}

	# 
	#	Send page not found output
	#
	proc page-not-found {chan} {
		set content "<html><body><p>page not found</p></body></html>"

		puts $chan "HTTP/1.1 404 Not Found"
		puts $chan "Content-Length: [string length $content]"
		puts $chan ""
		puts $chan $content

	}

	proc get-mimetype-for {name} {
		variable mimetypes

		array set mimemap $mimetypes
		set extension [file ext $name]

		if {![info exists mimemap($extension)]} {
			puts "unknown extension $extension"
			return "application/octet-stream"
		} 

		return $mimemap($extension)
	}

	#
	#   Try to find the file in the registered bases and stream it efficiently
	#
	proc send-file {chan} {
		variable mimetypes

		# sanitize url 
		set url [HttpServer::request-url $chan]
		if { $url == "/" } then {
			set url "/index.html"
		}

		# get a file to match
		array set file_info [find-first-match $url]

		# nothing found? return 404.
		if { [array size file_info] == 0 } then {
			page-not-found $chan
			HttpServer::close $chan
			return
		} 

		# get filestat from `info` key
		array set filestat $file_info(info)

		# get the mimetype for this file by custom mapping
		set filetype [get-mimetype-for $file_info(name)] 

		# return the OK code and the mimetype
		puts $chan "HTTP/1.1 200 OK"
		puts $chan "Content-Type: $filetype"
		puts $chan ""
	
		# stream the file contents
		set streamfile [open $file_info(name)]
		while { 1 } {
			set input [read $streamfile]
			puts -nonewline $chan $input

			if {[ eof $streamfile ]} then {
				break
			}
		}
		close $streamfile

		# closing socket
		HttpServer::close $chan
	}

	#
	#	Log something to the console
	#
	proc log {text} {
		variable debug
		if {$debug != 0} then {
			puts "debug: $text"
		}
	}
}

proc files'add-context {base} {
	lappend FileServeSocket::contexts $base
}