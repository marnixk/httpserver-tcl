@Component oo::class create Http::NotFoundHandler {

	superclass Http::Handler

	@Inject( Std::Logger ) variable log

	method start {request} {

		$log info "No mounts associated with this url, returning 404: `[$request url]`"
		my pageNotFound $request

		$request destroy
	}

}