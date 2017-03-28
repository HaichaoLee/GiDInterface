### Project Parameters
proc Composites::write::getParametersDict { } {
    set projectParametersDict [Dam::write::getParametersDict]
    
    return $projectParametersDict
}

proc Dam::write::writeParametersEvent { } {
    set projectParametersDict [getParametersDict]
    write::WriteJSON $projectParametersDict
}
