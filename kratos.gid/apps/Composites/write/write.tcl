namespace eval Composites::write {

}

proc Composites::write::Init { } {

}


proc Composites::write::writeCustomFilesEvent { } {
    write::CopyFileIntoModel "python/composites_main.py"
    write::RenameFileInModel "composites_main.py" "MainKratos.py"
   
}

# MDPA Blocks
proc Composites::write::writeModelPartEvent { } {    
    Dam::write::writeModelPartEvent
}

Composites::write::Init
