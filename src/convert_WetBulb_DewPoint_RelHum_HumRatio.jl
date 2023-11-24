#######################################################################################################
# Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
#######################################################################################################

# using Roots

export GetTWetBulbFromHumRatio, GetHumRatioFromTWetBulb, GetHumRatioFromRelHum, GetRelHumFromHumRatio, GetHumRatioFromTDewPoint, GetTDewPointFromHumRatio

"""
    GetTWetBulbFromHumRatio(TDryBulb::Real, HumRatio::Real, Pressure::Real)

    Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Wet-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
"""
function GetTWetBulbFromHumRatio(TDryBulb::Real, HumRatio::Real, Pressure::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio cannot be negative")
    end


    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, BoundedHumRatio, Pressure)

    # Initial guesses
    TWetBulbSup = TDryBulb
    TWetBulbInf = TDewPoint
    TWetBulb = (TWetBulbInf + TWetBulbSup) / 2

    index = 1
    # Bisection loop
    while (TWetBulbSup - TWetBulbInf > PSYCHROLIB_TOLERANCE)

        # Compute humidity ratio at temperature Tstar
        Wstar = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)

        # Get new bounds
        if Wstar > BoundedHumRatio
            TWetBulbSup = TWetBulb
        else
            TWetBulbInf = TWetBulb
        end

        # New guess of wet bulb temperature
        TWetBulb = (TWetBulbSup + TWetBulbInf) / 2

        if (index >= MAX_ITER_COUNT)
            ArgumentError("Convergence not reached in GetTWetBulbFromHumRatio. Stopping.")
        end

        index = index + 1
    end
    return TWetBulb


    # HACK used Roots Package
    # TODO respect tolerance
    # fun(TWetBulb) = HumRatio - GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    # find_zero(fun, TDryBulb)
end

"""
    GetHumRatioFromTWetBulb(TDryBulb::Real, TWetBulb::Real, Pressure::Real)

    Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35
"""
function GetHumRatioFromTWetBulb(TDryBulb::Real, TWetBulb::Real, Pressure::Real)
    if TWetBulb > TDryBulb
        ArgumentError("Wet bulb temperature is above dry bulb temperature")
    end

    Wsstar = GetSatHumRatio(TWetBulb, Pressure)

    if isIP()
       if TWetBulb >= FREEZING_POINT_WATER_IP
           HumRatio = ((1093 - 0.556 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb)) / (1093 + 0.444 * TDryBulb - TWetBulb)
       else
           HumRatio = ((1220 - 0.04 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb)) / (1220 + 0.444 * TDryBulb - 0.48*TWetBulb)
       end
    else
       if TWetBulb >= FREEZING_POINT_WATER_SI
           HumRatio = ((2501. - 2.326 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb)) / (2501. + 1.86 * TDryBulb - 4.186 * TWetBulb)
       else
           HumRatio = ((2830. - 0.24 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb)) / (2830. + 1.86 * TDryBulb - 2.1 * TWetBulb)
       end
    end

    # Validity check.
    return max(HumRatio, MIN_HUM_RATIO)
end

"""
    GetHumRatioFromRelHum(TDryBulb::Real, RelHum::Real, Pressure::Real)

    Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        RelHum : Relative humidity in range [0, 1]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1
"""
function GetHumRatioFromRelHum(TDryBulb::Real, RelHum::Real, Pressure::Real)
    if RelHum < 0 || RelHum > 1
        ArgumentError("Relative humidity is outside range [0, 1]")
    end

    VapPres = GetVapPresFromRelHum(TDryBulb, RelHum)
    GetHumRatioFromVapPres(VapPres, Pressure)
end

"""
    GetRelHumFromHumRatio(TDryBulb::Real, HumRatio::Real, Pressure::Real)

    Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Relative humidity in range [0, 1]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1
"""
function GetRelHumFromHumRatio(TDryBulb::Real, HumRatio::Real, Pressure::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio cannot be negative")
    end

    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    GetRelHumFromVapPres(TDryBulb, VapPres)
end

"""
    GetHumRatioFromTDewPoint(TDewPoint::Real, Pressure::Real)

    Return humidity ratio given dew-point temperature and pressure.

    Args:
        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 13
"""
function GetHumRatioFromTDewPoint(TDewPoint::Real, Pressure::Real)
    VapPres = GetSatVapPres(TDewPoint)
    GetHumRatioFromVapPres(VapPres, Pressure)
end

"""
    GetTDewPointFromHumRatio(TDryBulb::Real, HumRatio::Real, Pressure::Real)

    Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Dew-point temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1
"""
function GetTDewPointFromHumRatio(TDryBulb::Real, HumRatio::Real, Pressure::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio cannot be negative")
    end

    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    GetTDewPointFromVapPres(TDryBulb, VapPres)
end
