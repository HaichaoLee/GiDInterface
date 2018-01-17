proc DEM::write::WriteMDPAInlet { } {
    # Headers
    write::writeModelPartData

    writeMaterials

    # Nodal coordinates (only for DEM Parts <inefficient> )
    write::writeNodalCoordinatesOnGroups [GetInletGroups]
    
    # SubmodelParts
    writeInletMeshes
}

proc DEM::write::GetInletGroups { } {
    set groups [list ]
    set xp1 "[spdAux::getRoute [GetAttribute conditions_un]]/condition\[@n = 'Inlet'\]/group"
    foreach group [[customlib::GetBaseRoot] selectNodes $xp1] {
        set groupid [$group @n]
        lappend groups [write::GetWriteGroupName $groupid]
    }
    return $groups
}

proc DEM::write::writeInletMeshes { } {
    variable inletProperties
    set printable [list PROBABILITY_DISTRIBUTION MAX_RAND_DEVIATION_ANGLE ELEMENT_TYPE STANDARD_DEVIATION INLET_NUMBER_OF_PARTICLES]
    foreach groupid [dict keys $inletProperties ] {
        set what nodal
        set gtn [write::GetConfigurationAttribute groups_type_name]
        if {![dict exists $::write::meshes [list Inlet ${groupid}]]} {
            set mid [expr [llength [dict keys $::write::meshes]] +1]
            if {$gtn ne "Mesh"} {
                set good_name [write::transformGroupName $groupid]
                set mid "Inlet_${good_name}"
            }
            dict set ::write::meshes [list Inlet ${groupid}] $mid
            set gdict [dict create]
            set f "%10i\n"
            set f [subst $f]
            set group_real_name [write::GetWriteGroupName $groupid]
            dict set gdict $group_real_name $f
            write::WriteString "Begin $gtn $mid // Group $groupid // Subtree Inlet"
            write::WriteString "    Begin ${gtn}Data"
            write::WriteString "        PROPERTIES_ID [dict get $inletProperties $groupid MID]"
            write::WriteString "        RIGID_BODY_MOTION 0"
            write::WriteString "        IDENTIFIER $mid"
            write::WriteString "        INJECTOR_ELEMENT_TYPE SphericParticle3D"
            write::WriteString "        CONTAINS_CLUSTERS 0"
            set velocity [dict get $inletProperties $groupid VELOCITY_MODULUS]
            set velocity_X [dict get $inletProperties $groupid DIRECTION_VECTORX]
            set velocity_Y [dict get $inletProperties $groupid DIRECTION_VECTORY]
            set velocity_Z [dict get $inletProperties $groupid DIRECTION_VECTORZ]
            lassign [MathUtils::VectorNormalized [list $velocity_X $velocity_Y $velocity_Z]] velocity_X velocity_Y velocity_Z
            lassign [MathUtils::ScalarByVectorProd $velocity [list $velocity_X $velocity_Y $velocity_Z] ] vx vy vz
            write::WriteString "        VELOCITY \[3\] ($vx, $vy, $vz)"
            write::WriteString "        IMPOSED_MASS_FLOW_OPTION 0"
            write::WriteString "        MASS_FLOW 0.5"
            set interval [dict get $inletProperties $groupid Interval]
            lassign [write::getInterval $interval] ini end
            write::WriteString "        INLET_START_TIME $ini"
            if {$end in [list "End" "end"]} {set end [write::getValue DEMTimeParameters EndTime]}
            write::WriteString "        INLET_STOP_TIME $end"
            set diameter [dict get $inletProperties $groupid DIAMETER]
            write::WriteString "        RADIUS [expr $diameter / 2]"
            write::WriteString "        RANDOM_ORIENTATION 1"
            write::WriteString "        ORIENTATION \[4\] (0.0, 0.0, 0.0, 1.0)]"
            
            foreach {prop value} [dict get $inletProperties $groupid] {
                if {$prop in $printable} {
                    write::WriteString "        $prop $value"
                }
            }
            write::WriteString "    End ${gtn}Data"
            write::WriteString "    Begin ${gtn}Nodes"
            GiD_WriteCalculationFile nodes -sorted $gdict
            write::WriteString "    End ${gtn}Nodes"
            write::WriteString "End $gtn"
        }

    }
}



proc DEM::write::writeMaterials { } {
    variable inletProperties
    set xp1 "[spdAux::getRoute [GetAttribute conditions_un]]/condition\[@n = 'Inlet'\]/group"
    set old_mat_dict $::write::mat_dict
    set ::write::mat_dict [dict create]
    write::processMaterials $xp1
    set inletProperties $::write::mat_dict
    set ::write::mat_dict $old_mat_dict
    # WV inletProperties

    set printable [list PARTICLE_DENSITY YOUNG_MODULUS POISSON_RATIO PARTICLE_FRICTION PARTICLE_COHESION COEFFICIENT_OF_RESTITUTION PARTICLE_MATERIAL ROLLING_FRICTION PARTICLE_SPHERICITY DEM_DISCONTINUUM_CONSTITUTIVE_LAW_NAME DEM_CONTINUUM_CONSTITUTIVE_LAW_NAME]
    
    
    write::WriteString "Begin Properties 0"
    write::WriteString "End Properties\n"

    foreach group [dict keys $inletProperties] {
        write::WriteString "Begin Properties [dict get $inletProperties $group MID] // Inlet group: [write::GetWriteGroupName $group]"
        dict set inletProperties $group DEM_DISCONTINUUM_CONSTITUTIVE_LAW_NAME [dict get $inletProperties $group ConstitutiveLaw]
        dict set inletProperties $group DEM_CONTINUUM_CONSTITUTIVE_LAW_NAME DEMContinuumConstitutiveLaw
        dict set inletProperties $group PARTICLE_FRICTION 0.9999999999999999
        foreach {prop val} [dict get $inletProperties $group] {
            if {$prop in $printable} {
                write::WriteString "    $prop $val"
            }
        }
        write::WriteString "End Properties\n"
    }
}