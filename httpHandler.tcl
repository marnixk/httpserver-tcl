#
#	This module is includeable
#
@AbstractComponent oo::class create Http::Handler {

	@Logger variable log

	#
	#   Read from the http socket and dispatch it to the current state's handler
	#
	method read {request} {
		set chan [$request chan]

		set left [gets $chan line]

		# nothing more to read?
		if { $left < 0 } {
			if { [eof $chan] } {
				$log debug "Connection closed (chan: [$request chan])"
				$request destroy
				return
			}
		} else {
			[$request handler] [$request hook] $request $line
		}
	}

	#
	#	Read headers from the request
	#
	method readHeaders {request line} {

		# empty line means end of headers so 'start' doing what
		# this handler is used for.
		if {$line == ""} then {

			# posted information? parse the form data
			if {[$request postRequest?]} then {
				set postInfo [read [$request chan]]
				$request parseRequestParameters "?$postInfo"
			} 

			# start the handling
			my start $request
		} else {
			set headername [string range [lindex $line 0] 0 end-1]
			set value [string range $line [expr {2 + [string length $headername]}] end]

			$request addHeader $headername $value
		}
	}


	method start {request} {
		error "the `start` method has not been implemented for this class"
	}


	# 
	#	Send page not found output
	#
	method pageNotFound {request} {

		set chan [$request chan]

		set content "<html><body><p>page not found</p></body></html>"

		puts $chan "HTTP/1.1 404 Not Found"
		puts $chan "Content-Length: [string length $content]"
		puts $chan ""
		puts $chan $content

	}
}
