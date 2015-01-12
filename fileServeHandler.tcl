#
#   Default fallback for requests coming into the server.
#
@Component oo::class create Http::FileServeHandler {
	
	superclass Http::Handler

	#
	#	Injects the logger
	#
	@Logger variable log

	#
	#	Hooks into the resource bundles
	#
	@Inject( Http::Resources ) variable resources

	#
	#	List of common, supported mimetypes
	#
	variable mimetypes

	#
	#	Initialize data-members
	#
	constructor {} {
		lappend contexts

		set mimetypes {
			.html text/html
			.css text/css
			.js text/javascript
			.json text/json
			.xml text/xml

			.jpg image/jpeg 
			.png image/png 
			.gif image/gif
		}

	}


	#
	#   Try to find the file in the registered bases and stream it efficiently
	#
	method start {request} {

		set uri [my _sanitizeUrl [$request path]]

		$log debug "Sanitized uri: $uri"

		# get a file to match
		array set FileInfo [$resources findResource $uri]

		# nothing found? return 404.
		if { [array size FileInfo] == 0 } then {
			my pageNotFound $request
			$request destroy
			return
		} 

		# get filestat from `info` key
		array set FileStat $FileInfo(info)

		# get the mimetype for this file by custom mapping
		set fileType [my _getMimetypeFor $FileInfo(name)] 

		# output channel
		set chan [$request chan]

		# return the OK code and the mimetype
		puts $chan "HTTP/1.1 200 OK"
		puts $chan "Connection: close"
		puts $chan "Content-Length: $FileStat(size)" 
		puts $chan "Content-Type: $fileType"
		puts $chan ""

		fconfigure $chan -translation binary
		fconfigure $chan -buffering none

		# stream the file contents
		set streamfile [open $FileInfo(name) "rb"]
		while { 1 } {
			set input [read $streamfile 16000]

			puts -nonewline $chan $input

			if {[ eof $streamfile ]} then {
				break
			}
		}
		close $streamfile

		# closing socket
		$request destroy
	}


	method _getMimetypeFor {name} {

		array set mimemap $mimetypes
		set extension [file ext $name]

		if {![info exists mimemap($extension)]} {
			$log debug "Unknown extension $extension"
			return "application/octet-stream"
		} 

		return $mimemap($extension)
	}

	#
	#	@private 
	#
	#	Method that cleans up the url
	#
	method _sanitizeUrl {url} {

		# is just a slash? rewrite to index.html
		if { $url == "/" } then {
			set url "/index.html"
		}

		set qmIdx [string first "?" $url]
		if {$qmIdx != -1} then {
			return [string range $url 0 $qmIdx-1]
		} else {
			return $url
		}
	}
	
}