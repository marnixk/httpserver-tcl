#
#	The Http::Request object is generated when a new connection

#
#
oo::class create Http::Request {

	# the file descriptor for this request
	variable channel

	# the object that represents the current state handler
	variable handler

	# the current hook of the handler
	variable hook

	# the complete request URL
	variable url

	# container for the request headers
	variable headers

	# container for the URL query parameters
	variable params

	# container for attributes 
	variable attributes

	# POST/GET/PUT/DELETE etc.
	variable method

	# the base path of the handler for this request
	variable mountPath

	# logger
	variable log

	#
	#	Initialize database
	#
	constructor {aChannel} {
		set channel $aChannel
		set hook "readUrl"
		set handler {}
		set url ""
		set mountPath "/"

		set headers [dict create]
		set params [dict create]
		set attributes [dict create]

		set method {}

		set log [DI::get Std::Logger]
	}

	destructor {
		$log info "Connection closing"
		::close $channel
	}

	method chan {} {
		return $channel
	}

	method hook {} {
		return $hook
	}

	method handler {} {
		return $handler
	}

	method url {} {
		return $url
	}

	method path {} {
		return [string range $url [string length $mountPath] end]
	}

	method method {} {
		return $method
	}

	method mountPath {} {
		return $mountPath
	}

	method hasParam? {name} {
		return [expr {[my param $name] != ""}]
	}

	method param {name} {
		return [dict get $params $name]
	}

	method hasHandler? {} {
		return [expr {[my handler] != ""}]
	}

	method setHook {aHook} {
		set hook $aHook
	}

	method setConnected {aConnected} {
		set connected $aConnected
	}

	method setHandler {aHandler} {
		set handler $aHandler
	}

	method setMountPath {aMountPath} {
		set mountPath $aMountPath
	}

	method setMethod {aMethod} {
		set method $aMethod
	}

	method setUrl {aUrl} {
		set url $aUrl
		my _parseRequestParameters
	}

	#
	#	Parse request parameters
	#
	method _parseRequestParameters {} {
		set params [dict create]

		# parse query parameters?
		set qmIdx [string first "?" $url]
		if {$qmIdx != -1} then {
			set queryParams [string range $url $qmIdx+1 end]
			set queryParamsList [split $queryParams "&"]
			foreach keyValuePair $queryParamsList {
				lassign [split $keyValuePair "="] key value
				dict set params $key $value
			}

			$log debug "Query parameters: $params"
		}
	}

	#
	#	Header Management
	#
	method addHeader {key value} {
		dict set headers $key $value
	}

	method getHeader {key} {
		return [dict get $headers $key]
	}

	method getHeaders {} {
		return $headers
	}
}