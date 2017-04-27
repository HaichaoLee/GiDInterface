
proc Fluid::xml::ImportMeshWindow { } {
    set filenames [Browser-ramR file read .gid [_ "Read mesh file"] \
		{} [list [list {STL Mesh} {.stl }] [list [_ "All files"] {.*}]] {} 1 \
        [list [_ "Import options"] Fluid::xml::MoreImportOptions]]
    if {[llength $filenames] == 0} { return "" }
    set filename [lindex $filenames 0]
    set model_name [file rootname [file tail $filename]]
    if {[GiD_Layers exists $model_name]} {
        set i 0
        set orig $model_name
        while {[GiD_Layers exists $model_name]} {
            set model_name ${orig}$i
            incr i
        }
    }
    GidUtils::DisableGraphics
    GiD_Layers create $model_name
    GiD_Layers edit to_use $model_name
    GiD_Process 'Layers Color $model_name 255193060 
    
    if {[lindex [GiD_Info Mesh] 0]} {
        GiD_Process Mescape Files STLRead Append $filename
    } else {
        GiD_Process Mescape Files STLRead $filename
    }


    if {![GiD_Groups exists $model_name]} {GiD_Groups create $model_name}

    GiD_Process Mescape Geometry Edit ReConstruction OneSurfForEachElement Layer:$model_name escape
    if {[apps::ExecuteOnCurrentXML NeedToCropVolume]} {GiD_Process Mescape Utilities Collapse model Yes }
    GiD_EntitiesGroups assign $model_name surfaces [GiD_EntitiesLayers get $model_name surfaces]
    GiD_EntitiesGroups assign $model_name lines [GiD_EntitiesLayers get $model_name lines]
    GiD_EntitiesGroups assign $model_name points [GiD_EntitiesLayers get $model_name points]

    GiD_Process Mescape Meshing AssignSizes Surfaces $Fluid::xml::lastImportMeshSize Layer:$model_name escape escape


    GidUtils::EnableGraphics
    GidUtils::UpdateWindow GROUPS
    GidUtils::UpdateWindow LAYER

    GiD_Process 'Zoom Frame

    GidUtils::SetWarnLine [= "STL %s imported!" $model_name]

    set group_id $model_name
    set mesh_size $Fluid::xml::lastImportMeshSize

    set basepath [spdAux::getRoute FLImportedParts]
    set gNode [spdAux::AddConditionGroupOnXPath $basepath $group_id]
    set xpath [$gNode toXPath]
    gid_groups_conds::addF $xpath value [list n MeshSize pn {Mesh size} v $mesh_size state disabled]
    [$gNode parent] setAttribute tree_state open
    $gNode setAttribute open_window 1
    apps::ExecuteOnCurrentXML WindTunnelImportPart [dict create group $model_name size $mesh_size]
    apps::ExecuteOnCurrentXML WindTunnelImportCheck $model_name

    spdAux::RequestRefresh
}

proc Fluid::xml::WindTunnelImportCheck { model_name } {
    if {[GiD_Info layers -count -entities lines -higherentity 1 $model_name] > 0 } {
        W "The imported geometry is not watertight. Please check lines with higher entity value equal to 1 to find volume holes."
        GiD_Process Mescape Utilities DrawHigher Lines
    }
}

proc Fluid::xml::MoreImportOptions { f } {
    if {$Fluid::xml::lastImportMeshSize == 0} {set Fluid::xml::lastImportMeshSize 1000}
    ttk::label $f.lblGeometry -text [= "Mesh size"]:
    ttk::entry $f.entGeometry -textvariable Fluid::xml::lastImportMeshSize
    grid columnconfigure $f 1 -weight 1
    grid $f.lblGeometry $f.entGeometry -sticky w

    variable export_dir
    if { ![info exists export_dir] } {
        #trick to show the more options
        set export_dir open
    }
    return Fluid::xml::export_dir
}

Fluid::xml::Init
