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
    variable kratos_name

    apps::LoadAppById "Fluid"
    set kratos_name $::Fluid::kratos_name

    set dir [apps::getMyDir "VirtualWindTunnel"]
    set attributes [dict create]

    set prefix VWTFL

    set ::Model::ValidSpatialDimensions [list 3D]
    spdAux::SetSpatialDimmension "3D"

    # Allow to open the tree
    set ::spdAux::TreeVisibility 1

    dict set attributes UseIntervals 1

    LoadMyFiles
    set ::GidPriv(DuplicateEntities) 1

    #::spdAux::CreateDimensionWindow
}

proc ::VirtualWindTunnel::LoadMyFiles { } {
    variable dir

}

proc ::VirtualWindTunnel::GetAttribute {name} {
    variable attributes
    set value ""
    if {[dict exists $attributes $name]} {set value [dict get $attributes $name]}
    return $value
}


::VirtualWindTunnel::Init
