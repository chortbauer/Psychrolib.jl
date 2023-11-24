#######################################################################################################
# Helper functions for unit system handling
#######################################################################################################

export SetUnitSystem

@enum UnitSystem IP SI

PSYCHROLIB_UNITS = missing

# Tolerance of temperature calculations
PSYCHROLIB_TOLERANCE = 1.0

"""
    SetUnitSystem(Units::UnitSystem)

    Set the system of units to use (SI or IP).

    Args:
        Units: string indicating the system of units chosen (SI or IP)

    Notes:
        This function *HAS TO BE CALLED* before the library can be used.
"""
function SetUnitSystem(Units::UnitSystem)

    global PSYCHROLIB_UNITS = Units

    # Define tolerance on temperature calculations
    # The tolerance is the same in IP and SI
    if Units == IP
        global PSYCHROLIB_TOLERANCE = 0.001 * 9.0 / 5.0
    else
        global PSYCHROLIB_TOLERANCE = 0.001
    end
    return nothing
end

"""
    GetUnitSystem()

    Return system of units in use.    
"""
function GetUnitSystem()
    PSYCHROLIB_UNITS
end

"""
    isIP()

    Check whether the system in use is IP or SI. 
"""
function isIP()
    if ismissing(PSYCHROLIB_UNITS)
        ArgumentError("Unit system has not been set. Use SetUnitSystem() with IP / SI")
    elseif PSYCHROLIB_UNITS == IP
        return true
    elseif PSYCHROLIB_UNITS == SI
        return false
    else
        ArgumentError("Invalid Unit system: $PSYCHROLIB_UNITS")
    end
end
