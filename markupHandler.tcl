@Component oo::class create Http::MarkupHandler {
	
	superclass Http::Handler

	@Inject( Std::Logger ) variable log
	@Inject( Http::Resources ) variable resources

	method _templateName {url} {
		set lastPeriod [string last "." $url]
		set urlWithoutExtension [string range $url 0 $lastPeriod-1]
		return "${urlWithoutExtension}.mu.tcl"
	}

	method start {request} {

		set lastPeriod [string last "." [$request url]]
		set urlWithoutExtension [string range [$request url] 0 $lastPeriod-1]
		set tplName [my _templateName [$request url]]
		$log debug "Searching for $tplName"

		set resource [$resources findResource $tplName]

		if {$resource == {}} then {
			my pageNotFound $request
		} else {

			interp alias {} param {} $request param

			set filename [file normalize [dict get $resource name]]
			set markupOutput [html::render {
				source $filename
			}]

			$request puts $markupOutput
		}
		$request destroy
	}

}