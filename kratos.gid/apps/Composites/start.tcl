namespace eval ::Composites {
    # Variable declaration
    variable dir
    variable kratos_name
}

proc ::Composites::Init { } {
    # Variable initialization
    variable dir
    variable kratos_name
    
    apps::LoadAppById "Dam"
    set kratos_name $::Dam::kratos_name
    
    set dir [apps::getMyDir "Composites"]
    #set ::Model::ValidSpatialDimensions [list 2D 3D]
    spdAux::SetSpatialDimmension 2D
    
    # Allow to open the tree
    set ::spdAux::TreeVisibility 1
    LoadMyFiles
    #::spdAux::CreateDimensionWindow
    
}

proc ::Composites::LoadMyFiles { } {
    variable dir
    
    uplevel #0 [list source [file join $dir xml GetFromXML.tcl]]
    uplevel #0 [list source [file join $dir write write.tcl]]
    uplevel #0 [list source [file join $dir write writeProjectParameters.tcl]]
}

::Composites::Init