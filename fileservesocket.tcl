#
#   Default fallback for requests coming into the server.
#
module FileServeSocket {
	
	include HttpServer::HandlerBase

	variable debug 0
	variable contexts

	#
	#	List of common, supported mimetypes
	#
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

	public get-contexts-list {} {
		return $FileServeSocket::contexts
	}

	#
	#   Try to find the file in the registered bases and stream it efficiently
	#
	public send-contents {chan} {
		variable mimetypes

		# sanitize url 
		set url [HttpServer::request-url $chan]
		if { $url == "/" } then {
			set url "/index.html"
		}

		set url [strip-request-parameters $url]

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
	#   Find the first file match in the bases we are tracking.
	#
	protected find-first-match {filename} {
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
	protected page-not-found {chan} {
		set content "<html><body><p>page not found</p></body></html>"

		puts $chan "HTTP/1.1 404 Not Found"
		puts $chan "Content-Length: [string length $content]"
		puts $chan ""
		puts $chan $content

	}

	protected get-mimetype-for {name} {
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
	#	Strip request parameters
	#
	protected strip-request-parameters {url} {
		lassign [split $url "?"] url request
		return $url
	}

	
}

proc files'add-context {base} {
	lappend FileServeSocket::contexts $base
}