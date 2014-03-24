#
#	This module is includeable
#
module HttpServer::HandlerBase {

	variable debug 0

	#
	#   Read from the http socket and dispatch it to the current state's handler
	#
	public read-from-socket {chan} {

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
	public read-headers {chan line} {

		set calling_ns [uplevel 3 namespace current]

		set headername [string range [lindex $line 0] 0 end-1]
		set value [string range $line [expr {2 + [string length $headername]}] end]

		set HttpServer::state($chan,$headername) $value

		if {$line == ""} then {
			send-contents $chan
		}
	}
}
