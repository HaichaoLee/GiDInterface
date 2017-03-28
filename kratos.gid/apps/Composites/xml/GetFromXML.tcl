namespace eval Composites::xml {
    variable dir
}

proc Composites::xml::Init { } {
    variable dir
    Model::InitVariables dir $Composites::dir
    
    Model::ForgetMaterials
    Model::getMaterials Materials.xml
    
    CleanConditions
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
    if {[catch {Dam::xml::CustomTree} fid]} {
        W "Error during Dam::xml::CustomTree\n$fid"
    }
    
    set TypeOfProblem [[customlib::GetBaseRoot] selectNodes [spdAux::getRoute DamTypeofProblem]]
    $TypeOfProblem setAttribute values Mechanical
    $TypeOfProblem setAttribute state disabled
}

proc Composites::xml::CleanConditions { } {
    set NodalConditions [list ]
    foreach nc [Model::GetNodalConditions] {
        if {[$nc getName] in [list DISPLACEMENT VELOCITY ACCELERATION]} {lappend NodalConditions $nc}
    }
    set Model::NodalConditions $NodalConditions
    
    set Conditions [list ]
    foreach c [Model::GetConditions] {
        if {[$c getName] in [list SelfWeight3D SelfWeight2D PointLoad2D PointLoad3D LineLoad2D LineLoad3D SurfaceLoad3D]} {lappend Conditions $c}
    }
    set Model::Conditions $Conditions
}
Composites::xml::Init
