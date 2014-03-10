#
#   Default fallback for requests coming into the server.
#
namespace eval FileServeSocket {

	proc add-context {base_path} {
		puts "Adding $base_path"
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
			puts ".. done reading headers"
			set HttpServer::state($chan) read-messages
			send-handshake $chan
		}
	}

}