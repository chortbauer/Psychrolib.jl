# Unit system to use.
# class UnitSystem(Enum):
#     """
#     Private class not exposed used to set automatic enumeration values.
#     """
#     IP = auto()
#     SI = auto()

# IP = UnitSystem.IP
# SI = UnitSystem.SI

@enum UnitSystem IP SI

PSYCHROLIB_UNITS = missing

PSYCHROLIB_TOLERANCE = 1.0
# Tolerance of temperature calculations

function SetUnitSystem(Units::UnitSystem)
    """
    Set the system of units to use (SI or IP).

    Args:
        Units: string indicating the system of units chosen (SI or IP)

    Notes:
        This function *HAS TO BE CALLED* before the library can be used

    """
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

function GetUnitSystem()
    """
    Return system of units in use.

    """
    return PSYCHROLIB_UNITS
end

function isIP()
    """
    Check whether the system in use is IP or SI.

    """
    if PSYCHROLIB_UNITS == IP
        return True
    elseif PSYCHROLIB_UNITS == SI
        return False
    else
        ArgumentError("The system of units has not been defined.")
    end
end
