#
#	This module is includeable
#
oo::class create Http::Handler {

	#
	#   Read from the http socket and dispatch it to the current state's handler
	#
	method read {request} {
		set chan [$request chan]

		set left [gets $chan line]

		# nothing more to read?
		if { $left < 0 } {
			if { [eof $chan] } {
				$log debug "Connection closed [$request chan]"
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

		set headername [string range [lindex $line 0] 0 end-1]
		set value [string range $line [expr {2 + [string length $headername]}] end]

		$request addHeader $headername $value

		# empty line means end of headers so 'start' doing what
		# this handler is used for.
		if {$line == ""} then {
			my start $request
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
