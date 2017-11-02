# Project Parameters
proc FSI::write::getParametersDict { } {

   # Fluid section
   UpdateUniqueNames Fluid
   apps::setActiveAppSoft Fluid
   write::SetConfigurationAttribute parts_un FLParts
   
   set FluidParametersDict [Fluid::write::getParametersDict]

   #set current [dict get $FluidParametersDict solver_settings model_import_settings input_filename]
#    dict set FluidParametersDict gravity 9.81
   return $FluidParametersDict
}

proc FSI::write::writeParametersEvent { } {
   set projectParametersDict [getParametersDict]
   write::SetParallelismConfiguration
   write::WriteJSON $projectParametersDict
}
