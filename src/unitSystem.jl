#######################################################################################################
# Helper functions for unit system handling
#######################################################################################################

export SetUnitSystem

macro exported_enum(name, args...)
    esc(quote
        @enum($name, $(args...))
        export $name
        $([:(export $arg) for arg in args]...)
    end)
end

@exported_enum UnitSystem IP SI

PSYCHROLIB_UNITS = missing

PSYCHROLIB_TOLERANCE = 1.0 # TODO this seems high to me
# Tolerance of temperature calculations

"""
    SetUnitSystem(Units::UnitSystem)

    Set the system of units to use (SI or IP).

    Args:
        Units: string indicating the system of units chosen (SI or IP)

    Notes:
        This function *HAS TO BE CALLED* before the library can be used.
"""
function SetUnitSystem(Units::UnitSystem)

    # TODO I think this check is redundent because of the type spec in the function declaration
    # if not isinstance(Units, UnitSystem):
    #     ArgumentError("The system of units has to be either SI or IP.")

    PSYCHROLIB_UNITS = Units

    # Define tolerance on temperature calculations
    # The tolerance is the same in IP and SI
    if Units == IP
        PSYCHROLIB_TOLERANCE = 0.001 * 9.0 / 5.0
    else
        PSYCHROLIB_TOLERANCE = 0.001
    end
    return nothing
end

"""
    GetUnitSystem()

    Return system of units in use.    
"""
function GetUnitSystem()

    return PSYCHROLIB_UNITS
end

"""
    isIP()

    Check whether the system in use is IP or SI. 
"""
function isIP()
    if PSYCHROLIB_UNITS == IP
        return True
    elseif PSYCHROLIB_UNITS == SI
        return False
    else
        ArgumentError("The system of units has not been defined.")
    end
end
