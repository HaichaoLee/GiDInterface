namespace eval Composites::xml {
    variable dir
}

proc Dam::xml::Init { } {
    variable dir
    Model::InitVariables dir $Composites::dir
    
    Model::getSolutionStrategies Strategies.xml
    Model::getElements Elements.xml
    Model::getMaterials Materials.xml
    Model::getNodalConditions NodalConditions.xml
    Model::getConstitutiveLaws ConstitutiveLaws.xml
    Model::getProcesses Processes.xml
    Model::getConditions Conditions.xml
    Model::getSolvers "../../Common/xml/Solvers.xml"
}

proc Composites::xml::getUniqueName {name} {
    return CS$name
}


proc ::Composites::xml::MultiAppEvent {args} {
    if {$args eq "init"} {
        spdAux::parseRoutes
        spdAux::ConvertAllUniqueNames Dam CS
    }
}

proc Composites::xml::CustomTree { args } {
    Dam::xml::CustomTree  
}

Composites::xml::Init
