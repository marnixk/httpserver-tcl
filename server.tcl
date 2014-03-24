#
#   Socket server that dispatches to proper handler after reading URL
#
module HttpServer {

	variable debug 0
	variable state
	variable handlers
	variable default_handler {FileServeSocket}

	#
	#  Start a socket server
	#
	public start {port} {
		socket -server accept $port 
		vwait forever
	}

	#
	#  Handler for accepting new connections
	#
	protected accept {chan addr port} {
		variable state

		log "$addr:$port started"

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
	public read-from-socket {chan} {
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
	#	Return the request url for a specific channel
	#
	public request-url {chan} {
		return $HttpServer::state($chan,url)
	}

	#
	#	Return the request path for a specific channel
	#
	public request-path {chan} {
		set url $HttpServer::state($chan,url)
		set context $HttpServer::state($chan,context)

		set uri [string range $url [string length $context] end]
		return $uri
	}


	#
	#  Close a connection and clean up after ourselves
	#
	public close {chan} {
		variable state

		# clean up all state that starts with $chan 
		foreach name [array names state] {
			if {[string range $name 0 [string length $chan]-1] == $chan} {
				unset state($name)
			}
		}
		
		# clean up channel
		::close $chan
	}
	
	
	#
	#   Read from the http socket and dispatch it to the current state's handler
	#
	protected read-http-socket {chan} {
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
	protected read-url {chan line} {
		variable state

		set url [lindex $line 1]
		log ".. url - $url"

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
	protected find-matching-handler {url} {
		variable handlers
		variable default_handler

		foreach handler $handlers {
			set ns [lindex $handler 0]
			set nspath [lindex $handler 1]

			if { [starts-with $url $nspath] } then {
				return $handler
			}
		}

		return [list $default_handler "/"]
	}

	#
	#   Make sure `str` starts with `start`
	#
	protected starts-with {str start} {
		return [expr {[string range $str 0 [string length $start]-1] == $start}]
	}


	#
	#	Log something to the console
	#
	protected log {text} {
		variable debug
		if {$debug != 0} then {
			puts "debug: $text"
		}
	}
	

}

#
#	Adds a httpserver handler for a path and all underlying content
#
proc httpserver'path {path} {
	set handler_ns [uplevel 1 namespace current]
	lappend HttpServer::handlers [list $handler_ns $path]
}
