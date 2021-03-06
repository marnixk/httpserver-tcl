@Component oo::class create Http::HandlerMounts {

	#
	#	Dict of mount points
	#
	variable mounts

	#
	#	Logger
	#
	@Logger variable log

	# inject file server handler as default
	@Inject( Http::NotFoundHandler ) variable defaultHandler
	
	#
	#	Initialize data-members
	#
	constructor {} {
		set mounts [dict create]
	}

	#
	#	Override the injected default handler
	#
	method setDefaultMount {handlerObject} {
		set defaultHandler $handlerObject
	}

	#
	#	Add a mount point
	#
	method add {mountPoint handlerObject} {
		if {![oo::instanceof? $handlerObject Http::Handler]} then {
			error "The handler object must be of type `Http::Handler`"
		}

		dict set mounts $mountPoint $handlerObject
	}


	#
	#	Try and find a handler for this url
	#
	method findMatchingHandler {url} {

		foreach {regex handler} $mounts {
			$log debug "mount: $regex -> $handler"

			if { [regexp -inline $regex $url] != {} } then {
				$log debug "Returning handler for mount: `$regex`"
				return [list $handler $regex]
			}
		}

		$log debug "Returning the default handler"
		return [list $defaultHandler "/"]
	}

	#
	#   Make sure `str` starts with `start`
	#
	method _startsWith {str start} {
		return [expr {[string range $str 0 [string length $start]-1] == $start}]
	}

}