namespace eval Http::Response {

	#
	#	A list of all the status codes and their phrases
	#
	set StatusPhrases {
		100 "Continue"
		101 "Switching Protocols"
		200 "OK"
		201 "Created"
		202 "Accepted"
		203 "Non-Authoritative Information"
		204 "No Content"
		205 "Reset Content"
		206 "Partial Content"
		300 "Multiple Choices"
		301 "Moved Permanently"
		302 "Found"
		303 "See Other"
		304 "Not Modified"
		305 "Use Proxy"
		307 "Temporary Redirect"
		400 "Bad Request"
		401 "Unauthorized"
		402 "Payment Required"
		403 "Forbidden"
		404 "Not Found"
		405 "Method Not Allowed"
		406 "Not Acceptable"
		407 "Proxy Authentication Required"
		408 "Request Time-out"
		409 "Conflict"
		410 "Gone"
		411 "Length Required"
		412 "Precondition Failed"
		413 "Request Entity Too Large"
		414 "Request-URI Too Large"
		415 "Unsupported Media Type"
		416 "Requested range not satisfiable"
		417 "Expectation Failed"
		500 "Internal Server Error"
		501 "Not Implemented"
		502 "Bad Gateway"
		503 "Service Unavailable"
		504 "Gateway Time-out"
		505 "HTTP Version not supported"		
	}
}

#
#	Very basic response class implementation that allows user to set
#	headers, add text output (no streaming files) and flush the constructed
#	response to the browser. 
#
oo::class create Http::Response {

	oo::property statusCode
	oo::property contentType
	oo::property output

	variable channel	
	variable headers

	#
	#	Initialize the response object
	#
	constructor {aChannel} {
		set statusCode 200
		set contentType "text/html"
		set output ""
		set headers [dict create]
		set channel $aChannel
	}

	#
	#	Set a specific header
	#
	method setHeader {name value} {
		dict set headers $name $value
	}

	#
	#	Get a specific header value
	#
	method getHeader {name} {
		return [dict get $headers $name]
	}

	#
	#	Write the output to its channel
	#
	method flush {} {
		my setHeader Content-Type $contentType
		my setHeader Content-Length [string length $output]

		puts $channel "HTTP/1.1 $statusCode [my _phraseForCode $statusCode]"
		foreach {headerName headerValue} $headers {
			puts $channel "$headerName: $headerValue"
		}
		puts $channel ""
		puts $channel $output
		flush $channel
	}

	#
	#	Add some text to the response
	#
	method puts {text} {
		append output $text
	}

	#
	#	Get the phrase
	#
	method _phraseForCode {code} {
		return [dict get $Http::Response::StatusPhrases $code]
	}

}