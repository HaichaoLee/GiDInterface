
namespace eval WindTunnelWizard::Wizard {
    # Namespace variables declaration
    variable entrywidth
    variable borderwidth
    variable curr_image
}

proc WindTunnelWizard::Wizard::Init { } {
    variable entrywidth
    set entrywidth 16
    variable borderwidth
    set borderwidth 10
    
    variable curr_image
    set curr_image ""
}

proc WindTunnelWizard::Wizard::Fluid { win } {
    variable entrywidth
    variable borderwidth
    set gid_height [winfo screenheight .gid]
    set gid_width [winfo screenwidth .gid]
    Wizard::SetWindowSize [expr int($gid_width *0.5)] [expr int($gid_height *0.7)]
    # Left frame
    set labfr1 [ttk::labelframe $win.lfr1 -text [= "Fluid properties"] -padding 10 ]

    # Rigth frame
    set fr2 [ttk::labelframe $win.fr2 -text [= "Preview"] -padding 10 ]
    set labIm [ttk::label $fr2.lIm -image [GetImage]]
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
    

    # grid $fr1 -column 1 -row 0 -sticky nw
    grid $fr2 -column 2 -row 0 -sticky ne

    
     grid $labIm -column 0 -row 0 -sticky ne -rowspan 3
    
     # Label frames
     grid $labfr1 -column 1 -row 0 -sticky wen -padx 2

     for {set j 0} {$j < $i} {incr j} {
        set lab "lab$j"
        set ent "ent$j"
        set labun "labun$j"
        
        grid [expr $$lab] -column 1 -row $j -sticky w -pady 2
        grid [expr $$ent] -column 2 -row $j -sticky w -pady 2
        grid [expr $$labun] -column 3 -row $j -sticky w
          
     }
    
}
proc WindTunnelWizard::Wizard::NextFluid { } {
    if {![GiD_Groups exists "FluidBox"]} {W "Fluid group must be named as 'FluidBox'"; return ""}
    gid_groups_conds::delete "[spdAux::getRoute FLParts]/group"
    set gnode [spdAux::AddConditionGroupOnXPath [spdAux::getRoute FLParts] "FluidBox"]
    [$gnode selectNodes "./value\[@n = 'DENSITY'\]"] setAttribute v $::Wizard::wprops(Material,DENSITY,value)
    [$gnode selectNodes "./value\[@n = 'VISCOSITY'\]"] setAttribute v $::Wizard::wprops(Material,VISCOSITY,value)
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
proc WindTunnelWizard::Wizard::GetImage {{w -1} {h -1}} {
    if {$h eq -1} {set h [ expr int(450)]}
    if {$w eq -1} {set w [ expr int(600)]}
    set img1 [ image create photo -data [ GiD_Thumbnail get $w $h ]]
    return $img1
}
proc WindTunnelWizard::Wizard::Conditions { win } {
    variable entrywidth
    variable borderwidth
    GiD_Process 'Rotate Angle -150 30
    # Left frame
    # set fr1 [ttk::frame $win.fr1 -padding 4  -borderwidth $borderwidth]

    # Rigth frame
    set fr2 [ttk::labelframe $win.fr2 -text [= "Preview"] -padding 4  -borderwidth $borderwidth]
    set labIm [ttk::label $fr2.lIm -image [GetImage]]
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
        bind $comboinlet <<ComboboxSelected>> [list WindTunnelWizard::Wizard::ChangeCondition %W] 
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
        bind $combooutlet <<ComboboxSelected>> [list WindTunnelWizard::Wizard::ChangeCondition %W] 
        set ::Wizard::wprops(Conditions,outlet,combo) $combooutlet
        set presslbl [ttk::label $labout.presslbl -text "Pressure:"]
        set ::Wizard::wprops(Conditions,pressure,value) 0.0
        set entpres [ttk::entry $labout.entpres -textvariable ::Wizard::wprops(Conditions,pressure,value) -width $entrywidth]
        set labunpres [ttk::label $labout.upres -text "Pa"]
        wcb::callback $labout.entpres before insert wcb::checkEntryForReal
        set outletButton [ttk::button $labout.but -image [gid_themes::GetImage group_draw.png small_icons] \
        -command [list WindTunnelWizard::Wizard::DrawConditions outlet] -style IconButton]

    # labelframe para el slip
        # De las caras libres
        set labslip [ttk::labelframe $labfr1.slip -text [= "Slip"] -padding 10 ]
        set sliplbl [ttk::label $labslip.sliplbl -text "Slip faces:"]
        if {![info exists ::Wizard::wprops(Conditions,slip,values)] || $::Wizard::wprops(Conditions,slip,value) eq ""} {
            set ::Wizard::wprops(Conditions,slip,value) [list [lindex $values 2] [lindex $values 3]]
        }
        set checkslipframe [ttk::frame $labslip.checkslipframe]
        foreach value $values {
            set labelslip$value [ttk::label $checkslipframe.label$value -text $value]
            set checkslip$value [ttk::checkbutton $checkslipframe.check$value]
        }
        set slipButton [ttk::button $labslip.but -image [gid_themes::GetImage group_draw.png small_icons] \
        -command [list WindTunnelWizard::Wizard::DrawConditions slip] -style IconButton]
    # labelframe para el noslit
        # De las caras libres
        set labnoslip [ttk::labelframe $labfr1.noslip -text [= "No slip"] -padding 10 ]
        set nosliplbl [ttk::label $labnoslip.sliplbl -text "No slip faces:"]
        if {![info exists ::Wizard::wprops(Conditions,noslip,values)] || $::Wizard::wprops(Conditions,noslip,value) eq ""} {
            set ::Wizard::wprops(Conditions,noslip,value) [list [lindex $values 2] [lindex $values 3]]
        }
        set checknoslipframe [ttk::frame $labnoslip.checkslipframe]
        foreach value $values {
            set labelnoslip$value [ttk::label $checknoslipframe.label$value -text $value]
            set checknoslip$value [ttk::checkbutton $checknoslipframe.check$value]
        }
        set noslipButton [ttk::button $labnoslip.but -image [gid_themes::GetImage group_draw.png small_icons] \
        -command [list WindTunnelWizard::Wizard::DrawConditions noslip] -style IconButton]
    # labelframe para el immersedbody solo fluid
        #slip/noslip
        set labimm [ttk::labelframe $labfr1.immersed -text [= "Immersed body"] -padding 10 ]
        set immlbl [ttk::label $labimm.immlbl -text "Body skin:"]
        if {![info exists ::Wizard::wprops(Conditions,body,value)] || $::Wizard::wprops(Conditions,body,value) eq ""} {
            set ::Wizard::wprops(Conditions,body,value) Slip
        }
        set combobody [ttk::combobox $labimm.cbinlet -values {Slip "No slip"} -textvariable ::Wizard::wprops(Conditions,body,value) -width $entrywidth -state readonly]
        bind $combobody <<ComboboxSelected>> [list WindTunnelWizard::Wizard::ChangeCondition %W] 
        set ::Wizard::wprops(Conditions,inlet,combo) $combobody

    # grid $fr1 -column 0 -row 0 -sticky n
    grid $fr2 -column 2 -row 0 -sticky n

    
     grid $labIm -column 0 -row 0 -sticky ne -rowspan 3
    
     # Label frames
     grid $labfr1 -column 1 -row 0 -sticky we -padx 5
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
        grid $presslbl -column 1 -row 1 -sticky we -ipadx 2
        grid $entpres -column 2 -row 1 -sticky we -ipadx 2
        grid $labunpres -column 3 -row 1 -sticky we -ipadx 2
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
}
proc WindTunnelWizard::Wizard::ChangeCondition { inl } {
    
}
proc WindTunnelWizard::Wizard::DrawConditions { but } {
    variable curr_image
    catch {GiD_Groups end_draw}
    set gNodes [[customlib::GetBaseRoot] selectNodes "[spdAux::getRoute FLImportedParts]/group"]
    set groups [list ]
    foreach node $gNodes {lappend groups [$node @n]}
    GiD_Groups draw [concat $::Wizard::wprops(Conditions,${but},value) $groups]
    GiD_Process 'Redraw
    $curr_image configure -image [GetImage]
    GiD_Groups end_draw
    GiD_Process 'Redraw
}
proc WindTunnelWizard::Wizard::NextConditions { } {

}
proc WindTunnelWizard::Wizard::ConditionValues { win } {
     
}
proc WindTunnelWizard::Wizard::NextConditionValues { } {

}
proc WindTunnelWizard::Wizard::Simulation { win } {
     
}
proc WindTunnelWizard::Wizard::NextSimulation { } {

}


WindTunnelWizard::Wizard::Init

