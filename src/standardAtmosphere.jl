#######################################################################################################
# Standard atmosphere
#######################################################################################################

export GetStandardAtmPressure, GetStandardAtmTemperature, GetSeaLevelPressure, GetStationPressure

"""
    GetStandardAtmPressure(Altitude::Real)

    Return standard atmosphere barometric pressure, given the elevation (altitude).

    Args:
        Altitude: Altitude in ft [IP] or m [SI]

    Returns:
        Standard atmosphere barometric pressure in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3
"""
function GetStandardAtmPressure(Altitude::Real)
    if isIP()
        StandardAtmPressure = 14.696 * ^(1 - 6.8754e-06 * Altitude, 5.2559)
    else
        StandardAtmPressure = 101325 * ^(1 - 2.25577e-05 * Altitude, 5.2559)
    end
    return StandardAtmPressure
end

"""
    GetStandardAtmTemperature(Altitude::Real)

    Return standard atmosphere temperature, given the elevation (altitude).

    Args:
        Altitude: Altitude in ft [IP] or m [SI]

    Returns:
        Standard atmosphere dry-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
"""
function GetStandardAtmTemperature(Altitude::Real)
    if isIP()
        StandardAtmTemperature = 59 - 0.00356620 * Altitude
    else
        StandardAtmTemperature = 15 - 0.0065 * Altitude
    end
    return StandardAtmTemperature
end

"""
    GetSeaLevelPressure(StationPressure::Real, Altitude::Real, TDryBulb::Real)

    Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.

    Args:
        StationPressure : Observed station pressure in Psi [IP] or Pa [SI]
        Altitude: Altitude in ft [IP] or m [SI]
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Sea level barometric pressure in Psi [IP] or Pa [SI]

    Reference:
        Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
        ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
        Brooks/Cole 2000, ch. 1.

    Notes:
        The standard procedure for the US is to use for TDryBulb the average
        of the current station temperature and the station temperature from 12 hours ago.
"""
function GetSeaLevelPressure(StationPressure::Real, Altitude::Real, TDryBulb::Real)
    if isIP()
        # Calculate average temperature in column of air, assuming a lapse rate
        # of 3.6 °F/1000ft
        TColumn = TDryBulb + 0.0036 * Altitude / 2

        # Determine the scale height
        H = 53.351 * GetTRankineFromTFahrenheit(TColumn)
    else
        # Calculate average temperature in column of air, assuming a lapse rate
        # of 6.5 °C/km
        TColumn = TDryBulb + 0.0065 * Altitude / 2

        # Determine the scale height
        H = 287.055 * GetTKelvinFromTCelsius(TColumn) / 9.807

        # Calculate the sea level pressure
    end
    StationPressure * exp(Altitude / H)
end

"""
    GetStationPressure(SeaLevelPressure::Real, Altitude::Real, TDryBulb::Real)

    Return station pressure from sea level pressure.

    Args:
        SeaLevelPressure : Sea level barometric pressure in Psi [IP] or Pa [SI]
        Altitude: Altitude in ft [IP] or m [SI]
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Station pressure in Psi [IP] or Pa [SI]

    Reference:
        See 'GetSeaLevelPressure'

    Notes:
        This function is just the inverse of 'GetSeaLevelPressure'.
"""
function GetStationPressure(SeaLevelPressure::Real, Altitude::Real, TDryBulb::Real)
    SeaLevelPressure / GetSeaLevelPressure(1, Altitude, TDryBulb)
end
