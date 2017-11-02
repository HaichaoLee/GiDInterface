namespace eval ShallowWater::write {

}

proc ShallowWater::write::Init { } {

}

# Events
proc ShallowWater::write::writeModelPartEvent { } {
    write::writeAppMDPA Fluid
}

proc ShallowWater::write::writeCustomFilesEvent { } {
    catch {Fluid::write::WriteMaterialsFile}
}


FSI::write::Init
