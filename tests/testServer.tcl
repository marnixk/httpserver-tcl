#!/usr/bin/tclsh

source "loadSources.tcl"

DI::prepareInstances

#
#	Start server thread
#
set serverThreadId [thread::create {

	source "loadSources.tcl"

	DI::prepareInstances
	
	set resources [DI::get Http::Resources]
	set server [DI::get Http::Server]
	set mounts [DI::get Http::HandlerMounts]

	$mounts add "/public" [DI::get Http::FileServeHandler]

	# add file context	
	$resources addBundle "./data/"
	
	# start server
	$server start 8000
}]

after 500

proc simpleClient404 {} {
	set log [DI::get Std::Logger]

	$log "Starting a client that will return a 404"

	# write a HTTP request
	set chan [socket localhost 8000]
	puts $chan "GET /get-this-url.html?q=search HTTP/1.1\n"
	flush $chan

	after 1000

	set output [read $chan]
	$log "Server returned:\n$output"

	close $chan

	$log "Shutting down"
}


proc simpleClientRetrieve {} {
	set log [DI::get Std::Logger]

	$log "Starting a client that will return a file (200)"

	# write a HTTP request
	set chan [socket localhost 8000]
	puts $chan "GET /public/index.html HTTP/1.1\n"
	flush $chan

	after 1000

	set output [read $chan]
	$log "Server returned:\n$output"

	close $chan

	$log "Shutting down"
}


# wait a bit
after 1000 

simpleClient404
simpleClientRetrieve

# keep running it so that we can play around with it
vwait forever