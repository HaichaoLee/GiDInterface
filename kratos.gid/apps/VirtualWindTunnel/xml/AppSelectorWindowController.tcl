proc VirtualWindTunnel::AppSelectorWindow { } {
    #Init
    set w ".gid.wVWTAppSelector"
    if {[winfo exist $w]} {destroy $w}
    toplevel $w
    wm withdraw $w
    
    
    set x [expr [winfo rootx .gid]+[winfo width .gid]/2-[winfo width $w]/2]
    set y [expr [winfo rooty .gid]+[winfo height .gid]/2-[winfo height $w]/2]
    
    wm geom $w +$x+$y
    wm transient $w .gid  

    InitWindow $w [_ "Virtual Wind Tunnel"] Kratos "" "" 1
    set initwind $w
    ttk::frame $w.top
    ttk::label $w.top.title_text -text [_ "Select analysis type"]
    ttk::frame $w.information -relief ridge 
    
    set appsid [list "Fluid" "EmbeddedFluid"]
    set appspn [list "Body fitted" "Embedded mesh"]
    set images [list "mesh_body_fitted.png" "mesh_embedded.png"]
    
    set col 0
    set row 0
    foreach appname $appspn appid $appsid imgid $images {
        set img  [apps::getImgFrom VirtualWindTunnel $imgid]
        ttk::button $w.information.img$appid -image $img -command [list VirtualWindTunnel::changetoApp $w $appid]
        ttk::label $w.information.text$appid -text $appname
        
        grid $w.information.img$appid -column $col -row 0
        grid $w.information.text$appid -column $col -row 1
        incr col
    }
    
    grid $w.top
    grid $w.top.title_text
    
    grid $w.information
}
proc VirtualWindTunnel::changetoApp {w appid} {
    if {[winfo exist $w]} {destroy $w}
    spdAux::deactiveApp "VirtualWindTunnel"
    apps::addAppArgument "LoadTree"
    apps::addAppArgument "WindTunnelToolBar"
    apps::setActiveApp $appid
    set ::Model::ValidSpatialDimensions [list 3D]
    spdAux::SetSpatialDimmension "3D"
}    
