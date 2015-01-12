package provide httpserver 1.0

package require TclOO
package require tclcommon

set pkg_path [file dirname [info script]]

source "$pkg_path/httpResources.tcl"
source "$pkg_path/httpRequest.tcl"
source "$pkg_path/httpResponse.tcl"
source "$pkg_path/httpHandler.tcl"
source "$pkg_path/httpServer.tcl"

source "$pkg_path/httpHelper.tcl"

# handlers
source "$pkg_path/notFoundHandler.tcl"
source "$pkg_path/fileServeHandler.tcl"

