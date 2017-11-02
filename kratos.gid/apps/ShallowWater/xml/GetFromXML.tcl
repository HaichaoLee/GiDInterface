namespace eval ShallowWater::xml {
    # Namespace variables declaration
    variable dir
}

proc ShallowWater::xml::Init { } {
    # Namespace variables initialization
    variable dir
    Model::InitVariables dir $ShallowWater::dir

    Model::ForgetSolutionStrategies
    Model::getSolutionStrategies Strategies.xml
    Model::ForgetElements
    Model::ForgetConstitutiveLaws
    
    Model::getElements Elements.xml
    Model::getConstitutiveLaws ConstitutiveLaws.xml

    Model::ForgetMaterial Air
}

proc ShallowWater::xml::getUniqueName {name} {
    return ${::ShallowWater::prefix}${name}
}

proc ShallowWater::xml::CustomTree { args } {
    spdAux::ConvertAllUniqueNames FL ${::ShallowWater::prefix}
}

ShallowWater::xml::Init
