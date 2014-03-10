#
#   Socket server that dispatches to proper handler after reading URL
#
namespace eval HttpServer {

	variable state
	variable handlers
	variable default_handler {FileServeSocket}

	#
	#  Start a socket server
	#
	proc start {port} {
		socket -server accept $port 
		vwait forever
	}

	#
	#  Handler for accepting new connections
	#
	proc accept {chan addr port} {
		variable state

		puts "$addr:$port started"

		fconfigure $chan -buffering line
		fconfigure $chan -blocking 0
		fileevent $chan readable "HttpServer::read-from-socket $chan"

		set state($chan) read-url
		set state($chan,connected) false
	}

	#
	#   Generic socket reader, makes sure to dispatch resulting line to 
	#   the active state handler
	#
	proc read-from-socket {chan} {
		variable state

		# has a handler? dispatch.
		if { [info exists state($chan,handler)] } then {
			set ns $state($chan,handler)
			${ns}::read-from-socket $chan
			return
		}

		# try and get the URL
		read-http-socket $chan
	}


	#
	#   Read from the http socket and dispatch it to the current state's handler
	#
	proc read-http-socket {chan} {
		variable state

		set left [gets $chan line]
		if { $left < 0 } {
			if { [eof $chan] } {
				close $chan
				return
			}
		} else {
			$state($chan) $chan $line
		}
	}

	# 
	#	Read the URL 
	#
	proc read-url {chan line} {
		variable state

		set url [lindex $line 1]
		puts ".. url - $url"

		set handler [find-matching-handler $url]

		set ns [lindex $handler 0]
		set nspath [lindex $handler 1]

		# setup state for this element further
		set state($chan,url) $url
		set state($chan,handler) $ns
		set state($chan,context) $nspath
		set state($chan) read-headers
	}


	#
	#	Try and find a handler for this url
	#
	proc find-matching-handler {url} {
		variable handlers
		variable default_handler

		puts "finding match for $url"

		foreach handler $handlers {
			set ns [lindex $handler 0]
			set nspath [lindex $handler 1]

			if { [starts-with $url $nspath] } then {
				return $handler
			}
		}

		return [list "/" $default_handler]
	}

	#
	#   Make sure `str` starts with `start`
	#
	proc starts-with {str start} {
		return [expr {[string range $str 0 [string length $start]-1] == $start}]
	}


	#
	#	Return the request url for a specific channel
	#
	proc request-url {chan} {
		return $HttpServer::state($chan,url)
	}

	#
	#	Return the request path for a specific channel
	#
	proc request-path {chan} {
		set url $HttpServer::state($chan,url)
		set context $HttpServer::state($chan,context)

		set uri [string range $url [string length $context] end]
		return $uri
	}

	

}

#
#	Adds a httpserver handler for a path and all underlying content
#
proc httpserver'path {path} {
	set handler_ns [uplevel 1 namespace current]
	lappend HttpServer::handlers [list $handler_ns $path ]
}
