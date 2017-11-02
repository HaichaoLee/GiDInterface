namespace eval ::ShallowWater {
    # Variable declaration
    variable dir
    variable prefix
    variable attributes
    variable kratos_name
}

proc ::ShallowWater::Init { } {
    # Variable initialization
    variable dir
    variable prefix
    variable kratos_name
    variable attributes
    
    set kratos_name ShallowWaterApplication
    
    #W "Sourced FSI"
    set dir [apps::getMyDir "ShallowWater"]
    set prefix SW
    
    apps::LoadAppById "Fluid"
    
    # Intervals 
    dict set attributes UseIntervals 1

    # Allow to open the tree
    set ::spdAux::TreeVisibility 1
    
    set ::Model::ValidSpatialDimensions [list 2D]
    LoadMyFiles
    #::spdAux::CreateDimensionWindow
}

proc ::ShallowWater::LoadMyFiles { } {
    variable dir
    
    uplevel #0 [list source [file join $dir xml GetFromXML.tcl]]
    uplevel #0 [list source [file join $dir write write.tcl]]
    uplevel #0 [list source [file join $dir write writeProjectParameters.tcl]]
}


proc ::ShallowWater::GetAttribute {name} {
    variable attributes
    set value ""
    if {[dict exists $attributes $name]} {set value [dict get $attributes $name]}
    return $value
}

::ShallowWater::Init
