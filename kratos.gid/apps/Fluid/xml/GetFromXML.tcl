namespace eval Fluid::xml {
    # Namespace variables declaration
    variable dir
    variable lastImportMeshSize
}

proc Fluid::xml::Init { } {
    # Namespace variables inicialization
    variable dir
    variable lastImportMeshSize
    set lastImportMeshSize 1000
    Model::InitVariables dir $Fluid::dir
    
    Model::getSolutionStrategies Strategies.xml
    Model::getElements Elements.xml
    Model::getMaterials Materials.xml
    Model::getNodalConditions NodalConditions.xml
    Model::getConstitutiveLaws ConstitutiveLaws.xml
    Model::getProcesses "../../Common/xml/Processes.xml"
    Model::getProcesses Processes.xml
    Model::getConditions Conditions.xml
    Model::getSolvers "../../Common/xml/Solvers.xml"
}

proc Fluid::xml::getUniqueName {name} {
    return ${::Fluid::prefix}${name}
}

proc Fluid::xml::CustomTree { args } {
    # Hide Results Cut planes
    spdAux::SetValueOnTreeItem v time Results FileLabel
    spdAux::SetValueOnTreeItem v time Results OutputControlType
    set root [customlib::GetBaseRoot]
    if {[$root selectNodes "[spdAux::getRoute Results]/condition\[@n='Drag'\]"] eq ""} {
        gid_groups_conds::addF [spdAux::getRoute Results] include [list n Drag active 1 path {apps/Fluid/xml/Drag.spd}]
    }

    if {"WindTunnelToolBar" in [apps::getAppArguments]} {
        spdAux::SetValueOnTreeItem state normal FLImportedParts
    }
    
    customlib::ProcessIncludes $::Kratos::kratos_private(Path)
    spdAux::parseRoutes
}

# Events for wind tunnel 
proc Fluid::xml::NeedToCropVolume { } {
    return 1
}
proc Fluid::xml::WindTunnelGetFluidMaterialProperties { } {
    return [list DENSITY VISCOSITY]
}
proc Fluid::xml::NeedApplyConditionToBody { } {
    return 1
}

Fluid::xml::Init
