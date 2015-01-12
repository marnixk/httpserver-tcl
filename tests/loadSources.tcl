lappend auto_path "../../../packages/tclcommon"

package require TclOO
package require tclcommon
package require Thread

source "../httpRequest.tcl"
source "../httpResponse.tcl"
source "../httpHandler.tcl"
source "../httpHandlerMounts.tcl"
source "../httpServer.tcl"
source "../httpResources.tcl"
source "../httpHelper.tcl"

source "../handlers/notFoundHandler.tcl"
source "../handlers/fileServeHandler.tcl"
source "../handlers/markupHandler.tcl"

