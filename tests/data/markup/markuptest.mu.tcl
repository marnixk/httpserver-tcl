<html> {
	
	source "./data/markup/_head.mu.tcl"

	<body> {

		<img/> src= "http://www.ct4me.net/images/dmbtest.gif" style= "float: right"
		<h1> ' "Happy times"

		if {[param "q"] != ""} then {
			<p> ' "Your query was: [param q]"
		}

		<p> ' "Let's do some counting"
		<ul> {
			for {set idx 0} {$idx < 10} {incr idx} {
				<li> ' "Now at $idx"
			}
		}

		<form> method= "post" {
			<fieldset> {
				<label> for= "search" ' "Search keyword:"
				<input/> type= "text" name= "search" id= "search" value= "[param search]"
				<button> ' "Search"
			}
		}
	}
}