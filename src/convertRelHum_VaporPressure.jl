#######################################################################################################
# Conversions between dew point, or relative humidity and vapor pressure
#######################################################################################################

export GetVapPresFromRelHum, GetRelHumFromVapPres, GetTDewPointFromVapPres, GetVapPresFromTDewPoint

"""
    GetVapPresFromRelHum(TDryBulb::Real, RelHum::Real)

    Return partial pressure of water vapor as a function of relative humidity and temperature.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        RelHum : Relative humidity in range [0, 1]

    Returns:
        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
"""
function GetVapPresFromRelHum(TDryBulb::Real, RelHum::Real)
    if RelHum < 0 || RelHum > 1
        ArgumentError("Relative humidity is outside range [0, 1]")
    end

    RelHum * GetSatVapPres(TDryBulb)
end

"""
    GetRelHumFromVapPres(TDryBulb::Real, VapPres::Real)

    Return relative humidity given dry-bulb temperature and vapor pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        VapPres: Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]

    Returns:
        Relative humidity in range [0, 1]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
"""
function GetRelHumFromVapPres(TDryBulb::Real, VapPres::Real)
    if VapPres < 0
        ArgumentError("Partial pressure of water vapor in moist air cannot be negative")
    end

    VapPres / GetSatVapPres(TDryBulb)
end

"""
    dLnPws_(TDryBulb::Real)

    Helper function returning the derivative of the natural log of the saturation vapor pressure 
    as a function of dry-bulb temperature.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Derivative of natural log of vapor pressure of saturated air in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6
"""
function dLnPws_(TDryBulb::Real)
    if isIP()
        T = GetTRankineFromTFahrenheit(TDryBulb)
        if TDryBulb <= TRIPLE_POINT_WATER_IP
            dLnPws = 1.0214165E+04 / ^(T, 2) - 5.3765794E-03 + 2 * 1.9202377E-07 * T +3 * 3.5575832E-10 * ^(T, 2) - 4 * 9.0344688E-14 * ^(T, 3) + 4.1635019 / T
        else
            dLnPws = 1.0440397E+04 / ^(T, 2) - 2.7022355E-02 + 2 * 1.2890360E-05 * T -3 * 2.4780681E-09 * ^(T, 2) + 6.5459673 / T
        end
    else
        T = GetTKelvinFromTCelsius(TDryBulb)
        if TDryBulb <= TRIPLE_POINT_WATER_SI
            dLnPws = 5.6745359E+03 / ^(T, 2) - 9.677843E-03 + 2 * 6.2215701E-07 * T +3 * 2.0747825E-09 * ^(T, 2) - 4 * 9.484024E-13 * ^(T, 3) + 4.1635019 / T
        else
            dLnPws = 5.8002206E+03 / ^(T, 2) - 4.8640239E-02 + 2 * 4.1764768E-05 * T -3 * 1.4452093E-08 * ^(T, 2) + 6.5459673 / T
        end
    end

    return dLnPws
end


"""
    GetTDewPointFromVapPres(TDryBulb::Real, VapPres::Real)

    Return dew-point temperature given dry-bulb temperature and vapor pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        VapPres: Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]

    Returns:
        Dew-point temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 and 6

    Notes:
        The dew point temperature is solved by inverting the equation giving water vapor pressure
        at saturation from temperature rather than using the regressions provided
        by ASHRAE (eqn. 37 and 38) which are much less accurate and have a
        narrower range of validity.
        The Newton-Raphson (NR) method is used on the logarithm of water vapour
        pressure as a function of temperature, which is a very smooth function
        Convergence is usually achieved in 3 to 5 iterations. 
        TDryBulb is not really needed here, just used for convenience.
"""
function GetTDewPointFromVapPres(TDryBulb::Real, VapPres::Real)
    if isIP()
        BOUNDS = [-148, 392]
    else
        BOUNDS = [-100, 200]
    end

    # Validity check -- bounds outside which a solution cannot be found
    if VapPres < GetSatVapPres(BOUNDS[1]) || VapPres > GetSatVapPres(BOUNDS[2])
        ArgumentError("Partial pressure of water vapor is outside range of validity of equations")
    end

    # We use NR to approximate the solution.
    # First guess
    TDewPoint = TDryBulb        # Calculated value of dew point temperatures, solved for iteratively
    lnVP = log(VapPres)    # Partial pressure of water vapor in moist air

    index = 1

    while true
        TDewPoint_iter = TDewPoint   # TDewPoint used in NR calculation
        lnVP_iter = log(GetSatVapPres(TDewPoint_iter))

        # Derivative of function, calculated analytically
        d_lnVP = dLnPws_(TDewPoint_iter)

        # New estimate, bounded by the search domain defined above
        TDewPoint = TDewPoint_iter - (lnVP_iter - lnVP) / d_lnVP
        TDewPoint = max(TDewPoint, BOUNDS[1])
        TDewPoint = min(TDewPoint, BOUNDS[2])

        if ((abs(TDewPoint - TDewPoint_iter) <= PSYCHROLIB_TOLERANCE))
            break
        end

        if (index > MAX_ITER_COUNT)
            ArgumentError("Convergence not reached in GetTDewPointFromVapPres. Stopping.")
        end

        index = index + 1
    end

    TDewPoint = min(TDewPoint, TDryBulb)
end


"""
    GetVapPresFromTDewPoint(TDewPoint::Real)

    Return vapor pressure given dew point temperature.

    Args:
        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]

    Returns:
        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36
"""
function GetVapPresFromTDewPoint(TDewPoint::Real)
    GetSatVapPres(TDewPoint)
end
