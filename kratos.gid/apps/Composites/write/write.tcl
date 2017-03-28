namespace eval Composites::write {

}

proc Composites::write::Init { } {

}


proc Composites::write::writeCustomFilesEvent { } {
    write::CopyFileIntoModel "python/dam_main.py"
    write::RenameFileInModel "dam_main.py" "MainKratos.py"
   
}

# MDPA Blocks
proc Composites::write::writeModelPartEvent { } {    
    Dam::write::writeModelPartEvent
}

Composites::write::Init
