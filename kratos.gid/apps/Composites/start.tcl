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
    set ::Model::ValidSpatialDimensions [list 2D]
    spdAux::SetSpatialDimmension 2D
    
    # Allow to open the tree
    set ::spdAux::TreeVisibility 1
    
    # Enable the Wizard Module
    Kratos::LoadWizardFiles
    LoadMyFiles
    #::spdAux::CreateDimensionWindow
    
}

proc ::Composites::LoadMyFiles { } {
    variable dir
    
    uplevel #0 [list source [file join $dir xml GetFromXML.tcl]]
    uplevel #0 [list source [file join $dir write write.tcl]]
    uplevel #0 [list source [file join $dir write writeProjectParameters.tcl]]
    
    ::Wizard::LoadWizardDoc [file join $dir wizard Wizard_default.wiz]
    uplevel #0 [list source [file join $dir wizard Wizard_Steps.tcl]]
    Wizard::ImportWizardData
    
    # Init the Wizard Window
    after 600 [::Composites::StartWizardWindow]
}

proc ::Composites::StartWizardWindow { } {
    gid_groups_conds::close_all_windows
    Wizard::CreateWindow
    
}

::Composites::Init
