
namespace eval WindTunnelWizard::Wizard {
    # Namespace variables declaration
    variable entrywidth
    variable borderwidth
    variable curr_image
    variable intervalcurrframe
    variable intervaltable
    variable intervalselected
    variable futureIntervals
}

proc WindTunnelWizard::Wizard::Init { } {
    variable entrywidth
    set entrywidth 8
    variable borderwidth
    set borderwidth 10
    
    variable curr_image
    set curr_image ""
    variable intervalcurrframe
    set intervalcurrframe(pipo) ""
    variable intervaltable
    set intervaltable ""
    variable intervalselected
    set intervalselected ""
    set ::Wizard::wprops(Conditions,modified) 1
    variable futureIntervals
    set  futureIntervals [list ]
}

proc WindTunnelWizard::Wizard::Fluid { win } {
    variable entrywidth
    variable borderwidth
    set gid_height [winfo screenheight .gid]
    set gid_width [winfo screenwidth .gid]
    set goodH [expr int($gid_height*0.65)]
    if {$::tcl_platform(platform) eq "windows"} {set goodH [expr int($gid_height*0.6)]}
    Wizard::SetWindowSize [expr int($gid_width *0.4)] $goodH

    # Left frame
    set labfr1 [ttk::labelframe $win.lfr1 -text [= "Fluid properties"] ]

    # Rigth frame
    set fr2 [ttk::labelframe $win.fr2 -text [= "Preview"] -padding 4  -borderwidth $borderwidth]
    set labIm [ttk::label $fr2.lIm]
    variable curr_image
    set curr_image $labIm

    # Fluid frame
    set props [GetFluidProperties]

    set i 0
    foreach prop $props {
        set pn $::Wizard::wprops(Material,$prop,name)
        set unit $::Wizard::wprops(Material,$prop,unit)
        set lab$i [ttk::label $labfr1.l$i -text "${pn}:"]
        set ent$i [ttk::entry $labfr1.e$i -textvariable ::Wizard::wprops(Material,$prop,value) -width $entrywidth]
        set labun$i [ttk::label $labfr1.u$i -text "${unit}"]
        wcb::callback $labfr1.e$i before insert wcb::checkEntryForReal
        set txt [= "Enter a value for $pn"]
        tooltip::tooltip $labfr1.e$i "${txt}."
        incr i
    }
    

    grid $fr2 -column 1 -sticky nsew
    
     grid columnconfigure $win 1 -weight 1
     grid rowconfigure $win 0 -weight 1
     grid $labIm -sticky nsew

     # Label frames
     grid $labfr1 -column 0 -row 0 -sticky wesn -padx 5

     for {set j 0} {$j < $i} {incr j} {
        set lab "lab$j"
        set ent "ent$j"
        set labun "labun$j"
        
        grid [expr $$lab] -column 1 -row $j -sticky w -pady 2
        grid [expr $$ent] -column 2 -row $j -sticky w -pady 2
        grid [expr $$labun] -column 3 -row $j -sticky w
          
     }
    
    update
    $labIm configure -image [GetImage $fr2]
}
proc WindTunnelWizard::Wizard::NextFluid { } {
    if {![GiD_Groups exists "FluidBox"]} {W "Fluid group must be named as 'FluidBox'"; return ""}
    gid_groups_conds::delete "[spdAux::getRoute FLParts]/group"
    set gnode [spdAux::AddConditionGroupOnXPath [spdAux::getRoute FLParts] "FluidBox"]
    [$gnode selectNodes "./value\[@n = 'DENSITY'\]"] setAttribute v $::Wizard::wprops(Material,DENSITY,value)
    [$gnode selectNodes "./value\[@n = 'VISCOSITY'\]"] setAttribute v $::Wizard::wprops(Material,VISCOSITY,value)
    spdAux::RequestRefresh
}
proc WindTunnelWizard::Wizard::GetFluidProperties { } {
    set props [list DENSITY VISCOSITY]
    foreach prop $props {
        set node [[customlib::GetBaseRoot] selectNodes "[spdAux::getRoute FLParts]/group"]
        if {$node eq ""} {set node [[customlib::GetBaseRoot] selectNodes [spdAux::getRoute FLParts]]}
        set node [$node selectNodes "./value\[@n='$prop'\]"]
        set ::Wizard::wprops(Material,$prop,name)  [get_domnode_attribute $node pn]
        set ::Wizard::wprops(Material,$prop,value) [get_domnode_attribute $node v]
        set ::Wizard::wprops(Material,$prop,unit)  [get_domnode_attribute $node units]
    }
    
    return $props
}
proc WindTunnelWizard::Wizard::GetImage {fr} {
    set h [expr int([winfo height $fr]*0.85)]
    set wfr [winfo width $fr]
    set hfr [winfo height $fr]
    set wre [winfo width .gid.central.s]
    set hre [winfo height .gid.central.s]
    set ar [expr double($wre) / double($hre)]
    set w [expr int($h * $ar)]
    if {$w > $wfr} {
        set h [expr int($wfr / $ar)]
        set w $wfr
    }
    set w [expr int($w*0.95)]
    set img1 [ image create photo -data [ GiD_Thumbnail get $w $h ]]
    return $img1
}
proc WindTunnelWizard::Wizard::Conditions { win } {
    variable entrywidth
    variable borderwidth
    GiD_Process 'Rotate Angle -150 30
    GiD_Process 'Zoom frame
    # Left frame
    # set fr1 [ttk::frame $win.fr1 -padding 4  -borderwidth $borderwidth]

    # Rigth frame
    set fr2 [ttk::labelframe $win.fr2 -text [= "Preview"] -padding 4  -borderwidth $borderwidth]
    set labIm [ttk::label $fr2.lIm]
    variable curr_image
    set curr_image $labIm
    
    # Fluid frame
    set labfr1 [ttk::labelframe $win.lfr1 -text [= "Boundary conditions"] ]
    
    set values [list Front Back Top Bottom Left Right]
    # labelframe para el inlet
        # De las caras libres, inlet value
        set labinl [ttk::labelframe $labfr1.inlet -text [= "Inlet"] -padding 10 ]
        set inllbl [ttk::label $labinl.inllbl -text "Inlet face:"]
        if {![info exists ::Wizard::wprops(Conditions,inlet,value)] || $::Wizard::wprops(Conditions,inlet,value) eq ""} {
            set ::Wizard::wprops(Conditions,inlet,value) [lindex $values 0]
        }
        set comboinlet [ttk::combobox $labinl.cbinlet -values $values -textvariable ::Wizard::wprops(Conditions,inlet,value) -width $entrywidth -state readonly]
        bind $comboinlet <<ComboboxSelected>> [list set ::Wizard::wprops(Conditions,modified) 1] 
        set ::Wizard::wprops(Conditions,inlet,combo) $comboinlet
        set inletButton [ttk::button $labinl.but -image [gid_themes::GetImage group_draw.png small_icons] \
        -command [list WindTunnelWizard::Wizard::DrawConditions inlet] -style IconButton]
        # Tabla para intervalos con init, end, check(val/func), val/func

    # labelframe para el outlet
        # De las caras libres, pressure value
        set labout [ttk::labelframe $labfr1.outlet -text [= "Outlet"] -padding 10 ]
        set outlbl [ttk::label $labout.outlbl -text "Outlet face:"]
        if {![info exists ::Wizard::wprops(Conditions,outlet,value)] || $::Wizard::wprops(Conditions,outlet,value) eq ""} {
            set ::Wizard::wprops(Conditions,outlet,value) [lindex $values 1]
        }
        set combooutlet [ttk::combobox $labout.cboutlet -values $values -textvariable ::Wizard::wprops(Conditions,outlet,value) -width $entrywidth -state readonly]
        bind $combooutlet <<ComboboxSelected>>  [list set ::Wizard::wprops(Conditions,modified) 1] 
        set ::Wizard::wprops(Conditions,outlet,combo) $combooutlet
        set outletButton [ttk::button $labout.but -image [gid_themes::GetImage group_draw.png small_icons] \
        -command [list WindTunnelWizard::Wizard::DrawConditions outlet] -style IconButton]

    # labelframe para el slip
        # De las caras libres
        set labslip [ttk::labelframe $labfr1.slip -text [= "Slip"] -padding 10 ]
        set sliplbl [ttk::label $labslip.sliplbl -text "Slip faces:"]
        if {![info exists ::Wizard::wprops(Conditions,slip,value)]} {
            set ::Wizard::wprops(Conditions,slip,value) [list Left Right]
        }
        foreach v $values {if {$v in $::Wizard::wprops(Conditions,slip,value)} {set ::Wizard::wprops(Conditions,slip,$v) 1} {set ::Wizard::wprops(Conditions,slip,$v) 0}}
        set checkslipframe [ttk::frame $labslip.checkslipframe]
        foreach value $values {
            set labelslip$value [ttk::label $checkslipframe.label$value -text $value]
            set checkslip$value [ttk::checkbutton $checkslipframe.check$value -variable ::Wizard::wprops(Conditions,slip,$value) -command [list WindTunnelWizard::Wizard::UpdateCheckBox slip $value]]
        }
        set slipButton [ttk::button $labslip.but -image [gid_themes::GetImage group_draw.png small_icons] \
        -command [list WindTunnelWizard::Wizard::DrawConditions slip] -style IconButton]
    # labelframe para el noslip
        # De las caras libres
        set labnoslip [ttk::labelframe $labfr1.noslip -text [= "No slip"] -padding 10 ]
        set nosliplbl [ttk::label $labnoslip.sliplbl -text "No slip faces:"]
        if {![info exists ::Wizard::wprops(Conditions,noslip,value)]} {
            set ::Wizard::wprops(Conditions,noslip,value) [list Top Bottom]
        }
        foreach v $values {if {$v in $::Wizard::wprops(Conditions,noslip,value)} {set ::Wizard::wprops(Conditions,noslip,$v) 1} {set ::Wizard::wprops(Conditions,noslip,$v) 0}}
        set checknoslipframe [ttk::frame $labnoslip.checkslipframe]
        foreach value $values {
            set labelnoslip$value [ttk::label $checknoslipframe.label$value -text $value]
            set checknoslip$value [ttk::checkbutton $checknoslipframe.check$value -variable ::Wizard::wprops(Conditions,noslip,$value) -command [list WindTunnelWizard::Wizard::UpdateCheckBox noslip $value]]
        }
        set noslipButton [ttk::button $labnoslip.but -image [gid_themes::GetImage group_draw.png small_icons] \
        -command [list WindTunnelWizard::Wizard::DrawConditions noslip] -style IconButton]
    # labelframe para el immersedbody solo fluid
        #slip/noslip
        set labimm [ttk::labelframe $labfr1.immersed -text [= "Immersed body"] -padding 10 ]
        set immlbl [ttk::label $labimm.immlbl -text "Body skin:"]
        if {![array exists ::Wizard::wprops(Conditions,body,value)]} {
            set ::Wizard::wprops(Conditions,body,value) Slip
        }
        set combobody [ttk::combobox $labimm.cbinlet -values {Slip "No slip"} -textvariable ::Wizard::wprops(Conditions,body,value) -width $entrywidth -state readonly]
        # bind $combobody <<ComboboxSelected>> [list WindTunnelWizard::Wizard::ChangeCondition %W] 
        set ::Wizard::wprops(Conditions,inlet,combo) $combobody

    grid $fr2 -column 1 -sticky nsew
    
     grid columnconfigure $win 1 -weight 1
     grid rowconfigure $win 0 -weight 1

     grid $labIm -sticky nsew
    
     # Label frames
     grid $labfr1 -column 0 -row 0 -sticky nswe -padx 5
        # Inlet
        grid $labinl -column 1 -row 0 -sticky we -ipadx 2
        grid $inllbl -column 1 -row 0 -sticky we -ipadx 2
        grid $comboinlet -column 2 -row 0 -sticky we -ipadx 2
        grid $inletButton -column 3 -row 0 -sticky we -ipadx 2
        
        # Outlet
        grid $labout -column 1 -row 1 -sticky we -ipadx 2
        grid $outlbl -column 1 -row 0 -sticky we -ipadx 2
        grid $combooutlet -column 2 -row 0 -sticky we -ipadx 2 
        grid $outletButton -column 3 -row 0 -sticky we -ipadx 2
        # grid $presslbl -column 1 -row 1 -sticky we -ipadx 2
        # grid $entpres -column 2 -row 1 -sticky we -ipadx 2
        # grid $labunpres -column 3 -row 1 -sticky we -ipadx 2
        # Slip
        grid $labslip -column 1 -row 2 -sticky we -ipadx 2
        grid $sliplbl -column 1 -row 0 -sticky we -ipadx 2
        grid $slipButton -column 2 -row 0 -sticky w -ipadx 2
        grid $checkslipframe -column 1 -row 1 -sticky we -ipadx 2 -columnspan 2
        set c 0
        foreach {v1 v2} $values {
            set l1 labelslip$v1
            set l2 labelslip$v2
            grid [set $l1] -column $c -row 0 -sticky we
            grid [set $l2] -column $c -row 1 -sticky we
            incr c
            set b1 checkslip$v1
            set b2 checkslip$v2
            grid [set $b1] -column $c -row 0 -sticky we
            grid [set $b2] -column $c -row 1 -sticky we
            incr c
        }
        # No slip
        grid $labnoslip -column 1 -row 3 -sticky we -ipadx 2
        grid $nosliplbl -column 1 -row 0 -sticky we -ipadx 2
        grid $noslipButton -column 2 -row 0 -sticky w -ipadx 2
        grid $checknoslipframe -column 1 -row 1 -sticky we -ipadx 2 -columnspan 2
        set c 0
        foreach {v1 v2} $values {
            set l1 labelnoslip$v1
            set l2 labelnoslip$v2
            grid [set $l1] -column $c -row 0 -sticky we
            grid [set $l2] -column $c -row 1 -sticky we
            incr c
            set b1 checknoslip$v1
            set b2 checknoslip$v2
            grid [set $b1] -column $c -row 0 -sticky we
            grid [set $b2] -column $c -row 1 -sticky we
            incr c
        }
        # Body
        grid $labimm -column 1 -row 4 -sticky we -ipadx 2
        grid $immlbl -column 1 -row 0 -sticky we -ipadx 2
        grid $combobody -column 2 -row 0 -sticky we -ipadx 2
        # W "pollo [winfo width $win]"
        update
        $labIm configure -image [GetImage $fr2]
}
proc WindTunnelWizard::Wizard::UpdateCheckBox { let sel } {
    set ::Wizard::wprops(Conditions,modified) 1
    if {$::Wizard::wprops(Conditions,$let,$sel)} {
        lappend ::Wizard::wprops(Conditions,$let,value) $sel
    } {
        set ::Wizard::wprops(Conditions,$let,value) [lsearch -all -inline -not -exact $::Wizard::wprops(Conditions,$let,value) $sel]
    }
}
proc WindTunnelWizard::Wizard::DrawConditions { but } {
    variable curr_image
    catch {GiD_Groups end_draw}
    set gNodes [[customlib::GetBaseRoot] selectNodes "[spdAux::getRoute FLImportedParts]/group"]
    set groups [list ]
    foreach node $gNodes {lappend groups [$node @n]}
    GiD_Groups draw [concat $::Wizard::wprops(Conditions,${but},value) $groups]
    GiD_Process 'Redraw
    set fr .gid.activewizard.w.layoutFrame.wiz.layout.fr2
    $curr_image configure -image [GetImage $fr]
    GiD_Groups end_draw
    GiD_Process 'Redraw
}
proc WindTunnelWizard::Wizard::NextConditions { } {
    variable futureIntervals
    if {$::Wizard::wprops(Conditions,modified)} {
        set futureIntervals [WindTunnelWizard::Wizard::GetIntervals]
        gid_groups_conds::delete "[spdAux::getRoute FLBC]/condition/group"
        # spdAux::AddConditionGroupOnXPath "[spdAux::getRoute FLBC]/condition\[@n='AutomaticInlet3D'\]" $::Wizard::wprops(Conditions,inlet,value)
        spdAux::AddConditionGroupOnXPath "[spdAux::getRoute FLBC]/condition\[@n='Outlet3D'\]" $::Wizard::wprops(Conditions,outlet,value)
        foreach v $::Wizard::wprops(Conditions,slip,value) {spdAux::AddConditionGroupOnXPath "[spdAux::getRoute FLBC]/condition\[@n='Slip3D'\]" $v}
        foreach v $::Wizard::wprops(Conditions,noslip,value) {spdAux::AddConditionGroupOnXPath "[spdAux::getRoute FLBC]/condition\[@n='NoSlip3D'\]" $v}
        spdAux::RequestRefresh
        set ::Wizard::wprops(Conditions,modified) 0
    }
}
proc WindTunnelWizard::Wizard::ConditionValues { win } {
    variable entrywidth
    variable borderwidth
    variable intervaltable
    GiD_Process 'Rotate Angle -150 30
    
    # Left frame
    set labfr1 [ttk::labelframe $win.lfr1 -text [= "Boundary conditions"] ]
    
    # labelframe para el inlet
        # De las caras libres, inlet value
        set labinl [ttk::labelframe $labfr1.inlet -text [= "Inlet"] -padding 10 ]
        set sw [ScrolledWindow $labinl.lf ]
    
    package require tablelist_tile
    set intervaltable [tablelist::tablelist $sw.table \
            -selectmode single \
            -columns [list \
                12 [_ "Init time"] left \
                9 [_ "End time"] left \
                3 [_ "v/f"] left \
                8 [_ "Function"] left \
                8 [_ "Value"] center \
                ] \
            -stretch end ]
    $sw setwidget $intervaltable
    bind $intervaltable <<TablelistSelect>> [list WindTunnelWizard::Wizard::ChangeSelectInterval] 
    set botones [ttk::frame $labinl.buts]
    set bAdd [ttk::button $botones.b1 -text "Add interval"      -command [list WindTunnelWizard::Wizard::AddIntervalRow ]]
    set bDel [ttk::button $botones.b2 -text "Remove interval"   -command [list WindTunnelWizard::Wizard::DelIntervalRow ]]
        variable intervalcurrframe
        set frcu [ttk::labelframe $labinl.curr -text "Selected interval"]
        set intervalcurrframe(frame) $frcu
        set inilbl [ttk::label $frcu.lin -text "Init time:"]
        set inient [ttk::entry $frcu.ein -textvariable ::WindTunnelWizard::Wizard::intervalcurrframe(ini) -width $entrywidth]
        wcb::callback $inient before insert wcb::checkEntryForReal
        set endlbl [ttk::label $frcu.len -text "End time:"]
        set endent [ttk::entry $frcu.een -textvariable ::WindTunnelWizard::Wizard::intervalcurrframe(end) -width $entrywidth]
        wcb::callback $endent before insert wcb::checkEntryForReal
        set byflbl [ttk::label $frcu.byf -text "By function/value:"]
        set byfcbt [ttk::checkbutton $frcu.byc -variable ::WindTunnelWizard::Wizard::intervalcurrframe(byf) -command [list WindTunnelWizard::Wizard::ChangedByFuncButton] ]
        set funlbl [ttk::label $frcu.fun -text "Function:"]
        set ::WindTunnelWizard::Wizard::intervalcurrframe(lblFun) $funlbl
        set funent [ttk::entry $frcu.efu -textvariable ::WindTunnelWizard::Wizard::intervalcurrframe(fun) -width [expr 8*$entrywidth]]
        set ::WindTunnelWizard::Wizard::intervalcurrframe(entFun) $funent
        set vallbl [ttk::label $frcu.val -text "Value:"]
        set ::WindTunnelWizard::Wizard::intervalcurrframe(lblVal) $vallbl
        set valent [ttk::entry $frcu.eva -textvariable ::WindTunnelWizard::Wizard::intervalcurrframe(val) -width [expr 8*$entrywidth]]
        wcb::callback $valent before insert wcb::checkEntryForReal
        set ::WindTunnelWizard::Wizard::intervalcurrframe(entVal) $valent
        set valuni [ttk::label $frcu.valuni -text "m/s"]
        set ::WindTunnelWizard::Wizard::intervalcurrframe(uniVal) $valuni

        set bsave [ttk::button $frcu.bsave -text "Save" -command [list WindTunnelWizard::Wizard::SaveInterval] ]
    # labelframe para el outlet
        # De las caras libres, pressure value
        set labout [ttk::labelframe $labfr1.outlet -text [= "Outlet"] -padding 10 ]
        set presslbl [ttk::label $labout.presslbl -text "Pressure:"]
        set ::Wizard::wprops(ConditionValues,pressure,value) 0.0
        set entpres [ttk::entry $labout.entpres -textvariable ::Wizard::wprops(ConditionValues,pressure,value) -width $entrywidth]
        set labunpres [ttk::label $labout.upres -text "Pa"]
        wcb::callback $labout.entpres before insert wcb::checkEntryForReal
    
     # Label frames
     grid $labfr1 -padx 5 -sticky ewns
     grid columnconfigure $win 0 -weight 1
     grid rowconfigure $win 0 -weight 1
        # Inlet
        grid $labinl -sticky wens -ipadx 2
        grid columnconfigure $labfr1 0 -weight 1
        grid rowconfigure $labfr1 0 -weight 1
        grid $sw -sticky nsew
        grid $botones -sticky nsew
        grid $bAdd $bDel
        grid columnconfigure $labinl 0 -weight 1
        grid rowconfigure $labinl 0 -weight 1
            # current
            # grid $frcu -sticky wens
            grid $inilbl -column 0 -row 0 -sticky w
            grid $endlbl -column 0 -row 1 -sticky w
            grid $byflbl -column 2 -row 0 -sticky w -padx 15
            grid $funlbl -column 2 -row 1 -sticky w -padx 15
            grid $inient -column 1 -row 0 -sticky w
            grid $endent -column 1 -row 1 -sticky w
            grid $byfcbt -column 3 -row 0 -sticky w
            grid $funent -column 3 -row 1 -sticky w
            grid $bsave -column 5 -row 0 -rowspan 2 -sticky ens
        # Outlet
        grid $labout -row 1 -sticky we -ipadx 2
        grid $presslbl -column 1 -row 0 -sticky we -ipadx 2
        grid $entpres -column 2 -row 0 -sticky we -ipadx 2
        grid $labunpres -column 3 -row 0 -sticky we -ipadx 2
   
   LoadIntervals     
}

proc WindTunnelWizard::Wizard::GetIntervals { } {
    set ints [list ]
    foreach group [[customlib::GetBaseRoot] selectNodes "[spdAux::getRoute FLBC]/condition\[@n='AutomaticInlet3D'\]/group"] {
        lassign [write::getInterval [get_domnode_attribute [$group find n Interval] v] ] ini end
        set byf [get_domnode_attribute [$group find n ByFunction] v]
        set fun [get_domnode_attribute [$group find n function_modulus] v]
        set val [get_domnode_attribute [$group find n modulus] v]
        lappend ints [list $ini $end [expr $byf == Yes ? 1 : 0] $fun $val]
    }
    return $ints
}
proc WindTunnelWizard::Wizard::LoadIntervals { } {
    variable futureIntervals
    set intervals $futureIntervals
    if {$intervals eq ""} {set intervals [GetIntervals]} {set futureIntervals [list ]}
    foreach interval $intervals {
        lassign $interval ini end byf fun val
        AddIntervalRow $ini $end $byf $fun $val
    }
    SortTable
} 
proc WindTunnelWizard::Wizard::SaveInterval { } { 
    variable intervalcurrframe
    DelIntervalRow
    AddIntervalRow $intervalcurrframe(ini) $intervalcurrframe(end) $intervalcurrframe(byf) $intervalcurrframe(fun) $intervalcurrframe(val)
    SortTable
    # grid forget $intervalcurrframe(frame)
}
proc WindTunnelWizard::Wizard::ChangeSelectInterval { } {
    variable intervalcurrframe
    variable intervaltable
    variable intervalselected
    set intervalselected [$intervaltable curselection]
    set frcu $intervalcurrframe(frame)
    grid $frcu -sticky wens
    grid columnconfigure $frcu 3 -weight 1
    lassign [$intervaltable get $intervalselected] intervalcurrframe(ini) intervalcurrframe(end) intervalcurrframe(byf) intervalcurrframe(fun) intervalcurrframe(val)
    ChangedByFuncButton
}

proc WindTunnelWizard::Wizard::SortTable { } {
    variable intervaltable
    $intervaltable sortbycolumn 0
}
proc WindTunnelWizard::Wizard::AddIntervalRow {{ini "0.0"} {end "10"} {byf 1} {fun "sin(x)"} {val "10.0"} } {
    variable intervaltable
    if {$byf} {set val ""} {set fun ""}
    $intervaltable insert 0 [list $ini $end $byf $fun $val]
}
proc WindTunnelWizard::Wizard::DelIntervalRow { } {
    variable intervalcurrframe
    variable intervaltable
    variable intervalselected
    $intervaltable delete $intervalselected
    grid forget $intervalcurrframe(frame)
}

proc WindTunnelWizard::Wizard::ChangedByFuncButton { } {
    variable intervalcurrframe
    if {$intervalcurrframe(byf)} {
        grid forget $intervalcurrframe(entVal)
        grid $intervalcurrframe(entFun) -column 3 -row 1 -sticky w
        grid forget $intervalcurrframe(lblVal)
        grid $intervalcurrframe(lblFun) -column 2 -row 1 -sticky w  -padx 15
        grid forget $intervalcurrframe(uniVal)
    } else {
        grid $intervalcurrframe(entVal) -column 3 -row 1 -sticky w
        grid forget $intervalcurrframe(entFun)
        grid $intervalcurrframe(lblVal) -column 2 -row 1 -sticky w  -padx 15
        grid forget $intervalcurrframe(lblFun)
        grid $intervalcurrframe(uniVal) -column 4 -row 1 -sticky w
    }
    
}
proc WindTunnelWizard::Wizard::NextConditionValues { } {
    variable intervaltable
    # Crear los intervalos
    set i 0
    set inlet_group $::Wizard::wprops(Conditions,inlet,value)
    gid_groups_conds::delete "[spdAux::getRoute FLBC]/condition\[@n='AutomaticInlet3D'\]/group"
    set max_end 0
    foreach row [$intervaltable get 0 end] {
        incr i
        
        gid_groups_conds::delete "[spdAux::getRoute Intervals]/blockdata\[@name = 'Interval_$i'\]"
        set interval [gid_groups_conds::add [spdAux::getRoute Intervals] blockdata [list n "Interval" pn "Interval" name "Interval_$i" sequence "1" editable_name "unique" sequence_type "non_void_disabled" help "Interval"]]
        lassign $row ini end byf fun val
        gid_groups_conds::add [$interval toXPath] value [list n "IniTime" pn "Start time" v $ini state "normal" help "When do the interval starts?"]
        gid_groups_conds::add [$interval toXPath] value [list n "EndTime" pn "End time"   v $end state "normal" help "When do the interval ends?"]
        if {$end > $max_end} {set max_end $end}

        # Pasar info a inlet
        set gname ${inlet_group}
        # if {![GiD_Groups exists $gname]} {GiD_Groups create $gname}
        set inlet [spdAux::AddConditionGroupOnXPath "[spdAux::getRoute FLBC]/condition\[@n='AutomaticInlet3D'\]" $gname]
        
        [$inlet selectNodes "./value\[@n='ByFunction'\]"] setAttribute v [expr $byf ? Yes : No]
        [$inlet selectNodes "./value\[@n='function_modulus'\]"] setAttribute v $fun
        [$inlet selectNodes "./value\[@n='modulus'\]"] setAttribute v $val
        [$inlet selectNodes "./value\[@n='Interval'\]"] setAttribute v "Interval_$i"
        
        spdAux::ProcOkNewCondition [$inlet parent]
    }
    
    set ::Wizard::wprops(Simulation,end_time,value) $max_end

    # Pasar info a outlet
    [[customlib::GetBaseRoot] selectNodes "[spdAux::getRoute FLBC]/condition\[@n='Outlet3D'\]/group/value\[@n='value'\]"] setAttribute v $::Wizard::wprops(ConditionValues,pressure,value)

    GidUtils::UpdateWindow GROUPS
    gid_groups_conds::check_dependencies
    spdAux::RequestRefresh
}
proc WindTunnelWizard::Wizard::Simulation { win } {
    variable entrywidth
    variable borderwidth
    
    # Fluid frame
    set sections [GetSimulationValues]

    foreach section $sections {
        set sec_id [dict get $section id]
        set sec_pn [dict get $section pn]
        set fr_$sec_id [ttk::labelframe $win.$sec_id -text $sec_pn  -padding 10 ]
        set currfr [set fr_$sec_id]
        foreach prop [dict get $section props] {
            set pn $::Wizard::wprops(Simulation,$prop,name)
            set lab$prop [ttk::label $currfr.l$prop -text "${pn}:"]
            if {$::Wizard::wprops(Simulation,$prop,type) ne "combo"} {
                set ent$prop [ttk::entry $currfr.e$prop -textvariable ::Wizard::wprops(Simulation,$prop,value) -width $entrywidth]
                wcb::callback $currfr.e$prop before insert wcb::checkEntryForReal
            } else {
                set ent$prop [ttk::combobox $currfr.e$prop -textvariable ::Wizard::wprops(Simulation,$prop,value) -values $::Wizard::wprops(Simulation,$prop,values) -width $entrywidth -state readonly]
            }
            set labun$prop [ttk::label $currfr.u$prop]
            set txt [= "Enter a value for $pn"]
            tooltip::tooltip $currfr.e$prop "${txt}."
        }
    }

    foreach section $sections {
        set sec_id [dict get $section id]
        set sec fr_$sec_id
        grid [set $sec] -padx 15 -column [dict get $section col] -row [dict get $section row] -sticky new
        set j 0
        foreach prop [dict get $section props] {
            set lab "lab$prop"
            set ent "ent$prop"
            set labun "labun$prop"
            
            grid [expr $$lab] -column 1 -row $j -sticky w -pady 2
            grid [expr $$ent] -column 2 -row $j -sticky w -pady 2
            grid [expr $$labun] -column 3 -row $j -sticky w
            incr j
        }
    }
    
    set buttons_frame [ttk::frame $win.buttons_frame -padding 15 ]
    set button_save [ttk::button $buttons_frame.btnsave -text "Save" -command [list WindTunnelWizard::Wizard::SaveButton]]
    set button_mesh [ttk::button $buttons_frame.btnmesh -text "Mesh" -command [list WindTunnelWizard::Wizard::MeshButton]]
    set button_run  [ttk::button $buttons_frame.btnrun  -text "Run"  -command [list WindTunnelWizard::Wizard::RunButton]]

    grid $buttons_frame -column 1 -row 2 -sticky new
    grid $button_save -sticky new
    grid $button_mesh -sticky new
    grid $button_run -sticky new

    grid columnconfigure $buttons_frame 0 -weight 2
}
proc WindTunnelWizard::Wizard::GetSimulationValues { } {
    set meshprops [dict create col 0 row 1 id "mesh" pn "Mesh settings" props [list immersed_size volume_size]]
    set timeprops [dict create col 0 row 0 id "time" pn "Time settings" props [list time_step end_time]]
    set paraprops [dict create col 1 row 0 id "parallel" pn "Parallelism settings" props [list parallel_type n_threads]]
    set advaprops [dict create col 0 row 2 id "advanced" pn "Advanced settings" props [list max_iter dyn_tau abs_toler rel_toler]]
    set resuprops [dict create col 1 row 1 id "results" pn "Results" props [list time_bet drag]]
    return [list $meshprops $timeprops $paraprops $advaprops $resuprops]
}

proc WindTunnelWizard::Wizard::SaveButton { } {
    # $::ChangeVarInfo(LoadMeshingPrefOfModel) 
    NextSimulation
    GiD_Process escape Files Save 
}

proc WindTunnelWizard::Wizard::MeshButton { } {
    NextSimulation
    # Quitar en GiD 13.1.7d
    if {![info exists ::ChangeVarInfo(LoadMeshingPrefOfModel) ]} {set ::ChangeVarInfo(LoadMeshingPrefOfModel) 0}
    MeshGenerationOKDo 0.5
}

proc WindTunnelWizard::Wizard::RunButton { } {
    # $::ChangeVarInfo(LoadMeshingPrefOfModel) 
    NextSimulation
    GiD_Process Mescape Utilities Calculate escape
}
proc WindTunnelWizard::Wizard::NextSimulation { } {
    # Cosas al arbol
    set root [customlib::GetBaseRoot]
    
    # Time settings
    [$root selectNodes "[spdAux::getRoute FLTimeParameters]/value\[@n = 'EndTime'\]"] setAttribute v $::Wizard::wprops(Simulation,end_time,value)
    [$root selectNodes "[spdAux::getRoute FLTimeParameters]/value\[@n = 'DeltaTime'\]"] setAttribute v $::Wizard::wprops(Simulation,time_step,value)
    # Parallel settings
    [$root selectNodes "[spdAux::getRoute Parallelization]/value\[@n = 'ParallelSolutionType'\]"] setAttribute v $::Wizard::wprops(Simulation,parallel_type,value)
    [$root selectNodes "[spdAux::getRoute Parallelization]/value\[@n = 'OpenMPNumberOfThreads'\]"] setAttribute v $::Wizard::wprops(Simulation,n_threads,value)
    # Strategy settings
    [$root selectNodes "[spdAux::getRoute FLStratParams]/value\[@n = 'maximum_iterations'\]"] setAttribute v $::Wizard::wprops(Simulation,max_iter,value)
    [$root selectNodes "[spdAux::getRoute FLStratParams]/value\[@n = 'dynamic_tau'\]"] setAttribute v $::Wizard::wprops(Simulation,dyn_tau,value)
    [$root selectNodes "[spdAux::getRoute FLStratParams]/value\[@n = 'relative_velocity_tolerance'\]"] setAttribute v $::Wizard::wprops(Simulation,rel_toler,value)
    [$root selectNodes "[spdAux::getRoute FLStratParams]/value\[@n = 'absolute_velocity_tolerance'\]"] setAttribute v $::Wizard::wprops(Simulation,abs_toler,value)
    [$root selectNodes "[spdAux::getRoute FLStratParams]/value\[@n = 'relative_pressure_tolerance'\]"] setAttribute v $::Wizard::wprops(Simulation,rel_toler,value)
    [$root selectNodes "[spdAux::getRoute FLStratParams]/value\[@n = 'absolute_pressure_tolerance'\]"] setAttribute v $::Wizard::wprops(Simulation,abs_toler,value)
    # Results settings
    [$root selectNodes "[spdAux::getRoute Results]/value\[@n = 'OutputDeltaTime'\]"] setAttribute v $::Wizard::wprops(Simulation,time_bet,value)

    
    gid_groups_conds::delete "[spdAux::getRoute Results]/condition\[@n='Drag'\]/group"
    if { [write::isBooleanTrue $::Wizard::wprops(Simulation,drag,value) ]} {
        foreach node [$root selectNodes "[spdAux::getRoute FLImportedParts]/group"] {
            set dr_gr [spdAux::AddConditionGroupOnXPath "[spdAux::getRoute Results]/condition\[@n='Drag'\]" [$node @n]]
        }
    }

    gid_groups_conds::check_dependencies
    spdAux::RequestRefresh
}


WindTunnelWizard::Wizard::Init

