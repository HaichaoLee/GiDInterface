
proc VirtualWindTunnel::AppSelectorWindow { } {
    variable winpath
    #Init
    set winpath ".gid.wVWTAppSelector"
    set w $winpath
    
    if {[winfo exists $w]} {destroy $w}
    
    toplevel $w -class Toplevel -relief groove 
    #wm maxsize $w 500 300
    wm minsize $w 500 250
    wm overrideredirect $w 0
    wm resizable $w 1 1
    wm deiconify $w
    wm title $w [= "Analysis type"]
    wm attribute $w -topmost 1
    
    # EmbeddedFluid::xml::BoundingBox::RefreshWindow 
}

