#
#   Socket server that dispatches to proper handler after reading URL
#
@Component oo::class create Http::Server {

	variable sockets

	# logging
	@Inject( Std::Logger ) variable log

	# inject all handlers
	@InjectList( Http::HandlerMounts ) variable mounts


	#
	#	Initialize data-members
	#
	constructor {} {
		set sockets [dict create]
	}

	destructor {
		foreach {chan request} $sockets {
			$request destroy
		}
	}

	#
	#	Start server
	#
	method start {port} {
		$log "Starting a server at $port"
		socket -server "[self] accept" $port 
		vwait forever
	}

	#
	#  Handler for accepting new connections
	#
	method accept {chan addr port} {

		$log "Started a new session on: $addr:$port"

		fconfigure $chan -buffering line
		fconfigure $chan -blocking 0
		fileevent $chan readable "[self] readFromSocket $chan"

		set request [Http::Request new $chan]
		dict set sockets $chan $request
	}

	#
	#   Generic socket reader, makes sure to dispatch resulting line to 
	#   the active state handler
	#
	method readFromSocket {chan} {
		set request [dict get $sockets $chan]

		# has a handler? dispatch.
		if { [$request hasHandler?] } then {
			[$request handler] read $request
			return
		}

		# try and get the URL
		my readHttpSocket $request
	}


	#
	#  Close a connection and clean up after ourselves
	#
	method close {request} {
		$request destroy
	}
	
	
	#
	#   Read from the http socket and dispatch it to the current state's handler
	#
	method readHttpSocket {request} {
		set channel [$request chan]

		set left [gets $channel line]
		if { $left < 0 } {
			if { [eof $channel] } {
				$request destroy
				return
			}
		} else {
			my [$request hook] $request $line
		}
	}

	# 
	#	Read the URL 
	#
	method readUrl {request line} {

		lassign $line method url version

		$log "Method: $method"
		$log "Url: $url"

		set handler [$mounts findMatchingHandler $url]

		lassign $handler handlerObjRef mountPath

		# setup state for this element further
		$request setMethod [string tolower $method]
		$request setUrl $url
		$request setHandler $handlerObjRef
		$request setHook "readHeaders"
		$request setMountPath $mountPath

	}

}
