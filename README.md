# httpserver - a simple tcl webserevr

Rudimentary implementation of HTTP server that can serve files from multiple packages.

It contains the following concepts:

* a single-threaded server that dispatches appropriately
* request object; contains all the information from the HTTP headers
* request handlers; is a service that is dispatched to when it is bound to a certain mount point. This package comes with two default handlers, 404 handler (the default) and the fileServeHandler
* mount points; a mount point is a base URI that ties a URL to a request handler

## Getting started

Below you can find the minimal code to get the web server running. 

    # instantiate and wire the DI mechanism
    DI::prepareInstances
    
    # get important services
    set resources [DI::get Http::Resources]
    set server [DI::get Http::Server]
    set mounts [DI::get Http::HandlerMounts]

    # mount all file in the public folder to the file server handler
    $mounts add "/public" [DI::get Http::FileServeHandler]

    # the file server handler looks in all the places registered in the Resources service
    $resources addBundle "./data/"
    
    # start server
    $server start 8000

It binds to `0.0.0.0` by default so make sure you plug up your firewalls ;-)

## Future work

Extend the http server to become more of a workers based server. This would allow the server to run up multiple worker threads on startup (that are provisioned appropriately), then the server thread would hand off the requests to the appropriate thread.


