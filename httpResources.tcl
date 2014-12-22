@Component oo::class create Http::Resources {

	variable sources

	@Inject( Std::Logger ) variable log

	constructor {} {
		lappend sources
	}

	#
	#	Add a resource bundle base
	#
	method addBundle {path} {
		variable sources
		$log "Adding bundle location: `$path`"
		lappend sources $path
	}

	#
	#	Find the resource with a specific filename by iterating
	#	through a list of resource bases
	#
	method findResource {filename} {
		variable sources
		foreach ctx $sources {
			set lookingfor "$ctx/$filename"
			if { [file exists $lookingfor] } then {
				file stat $lookingfor stat
				return [list info [array get stat] name $lookingfor]
			}
		}

		return {}
	}


	#
	#	Find the resource with a specific filename by iterating
	#	through a list of resource bases
	#
	method findAllResources {filename} {
		variable sources

		lappend results
		foreach ctx $sources {
			set lookingfor "$ctx/$filename"
			if { [file exists $lookingfor] } then {
				file stat $lookingfor stat
				lappend results [list info [array get stat] name $lookingfor]
			}
		}

		return $results
	}
}
