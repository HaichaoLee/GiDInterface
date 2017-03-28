namespace eval Composites::xml {
    variable dir
}

proc Composites::xml::Init { } {
    variable dir
    Model::InitVariables dir $Composites::dir
    
    Model::ForgetMaterials
    Model::getMaterials Materials.xml
}

proc Composites::xml::getUniqueName {name} {
    return CS$name
}


proc ::Composites::xml::MultiAppEvent {args} {
    ::Dam::xml::MultiAppEvent $args
    if {$args eq "init"} {
        spdAux::parseRoutes
        spdAux::ConvertAllUniqueNames Dam CS
    }
}

proc Composites::xml::CustomTree { args } {
    Dam::xml::CustomTree
    
    
}

Composites::xml::Init
