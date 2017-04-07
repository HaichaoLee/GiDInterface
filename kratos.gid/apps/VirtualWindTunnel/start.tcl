namespace eval ::VirtualWindTunnel {
    # Variable declaration
    variable dir
    variable prefix
    variable attributes
    variable kratos_name
}

proc ::VirtualWindTunnel::Init { } {
    # Variable initialization
    variable dir
    variable prefix
    variable attributes
    
    set dir [apps::getMyDir "VirtualWindTunnel"]
    set attributes [dict create]

    set prefix VWTFL

    set ::Model::ValidSpatialDimensions [list 3D]
    spdAux::SetSpatialDimmension "3D"

    # Allow to open the tree
    set ::spdAux::TreeVisibility 0

    dict set attributes UseIntervals 0

    LoadMyFiles
    VirtualWindTunnel::AppSelectorWindow
}

proc ::VirtualWindTunnel::LoadMyFiles { } {
    variable dir
    uplevel #0 [list source [file join $dir xml AppSelectorWindowController.tcl]]
}

proc ::VirtualWindTunnel::CustomToolbarItems { } {
    return -1
}

proc ::VirtualWindTunnel::GetAttribute {name} {
    variable attributes
    set value ""
    if {[dict exists $attributes $name]} {set value [dict get $attributes $name]}
    return $value
}


::VirtualWindTunnel::Init
