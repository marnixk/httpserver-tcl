package provide httpserver 1.0

package require tclcommon

set pkg_path [file dirname [info script]]

source "$pkg_path/handlerbase.tcl"
source "$pkg_path/server.tcl"
source "$pkg_path/fileservesocket.tcl"

