#######################################################################################################
# Dry Air Calculations
#######################################################################################################

export GetDryAirEnthalpy, GetDryAirDensity, GetDryAirVolume, GetTDryBulbFromEnthalpyAndHumRatio, GetHumRatioFromEnthalpyAndTDryBulb

"""
    GetDryAirEnthalpy(TDryBulb::Real)

    Return dry-air enthalpy given dry-bulb temperature.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Dry air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 28
"""
function GetDryAirEnthalpy(TDryBulb::Real)
    if isIP()
        DryAirEnthalpy = 0.240 * TDryBulb
    else
        DryAirEnthalpy = 1006 * TDryBulb
    end
    return DryAirEnthalpy
end

"""
    GetDryAirDensity(TDryBulb::Real, Pressure::Real)

    Return dry-air density given dry-bulb temperature and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Dry air density in lb ft⁻³ [IP] or kg m⁻³ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    Notes:
        Eqn 14 for the perfect gas relationship for dry air.
        Eqn 1 for the universal gas constant.
        The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².
"""
function GetDryAirDensity(TDryBulb::Real, Pressure::Real)
    if isIP()
        DryAirDensity = (144 * Pressure) / R_DA_IP / GetTRankineFromTFahrenheit(TDryBulb)
    else
        DryAirDensity = Pressure / R_DA_SI / GetTKelvinFromTCelsius(TDryBulb)
    end
    return DryAirDensity
end

"""
    GetDryAirVolume(TDryBulb::Real, Pressure::Real)

    Return dry-air volume given dry-bulb temperature and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Dry air volume in ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    Notes:
        Eqn 14 for the perfect gas relationship for dry air.
        Eqn 1 for the universal gas constant.
        The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².
"""
function GetDryAirVolume(TDryBulb::Real, Pressure::Real)
    if isIP()
        DryAirVolume = R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) / (144 * Pressure)
    else
        DryAirVolume = R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) / Pressure
    end
    return DryAirVolume
end

"""
    GetTDryBulbFromEnthalpyAndHumRatio(MoistAirEnthalpy::Real, HumRatio::Real)

    Return dry bulb temperature from enthalpy and humidity ratio.


    Args:
        MoistAirEnthalpy : Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Returns:
        Dry-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30

    Notes:
        Based on the `GetMoistAirEnthalpy` function, rearranged for temperature.
"""
function GetTDryBulbFromEnthalpyAndHumRatio(MoistAirEnthalpy::Real, HumRatio::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio is negative")
    end
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    if isIP()
        TDryBulb  = (MoistAirEnthalpy - 1061.0 * BoundedHumRatio) / (0.240 + 0.444 * BoundedHumRatio)
    else
        TDryBulb  = (MoistAirEnthalpy / 1000.0 - 2501.0 * BoundedHumRatio) / (1.006 + 1.86 * BoundedHumRatio)
    end
    return TDryBulb
end

"""
    GetHumRatioFromEnthalpyAndTDryBulb(MoistAirEnthalpy::Real, TDryBulb::Real)

    Return humidity ratio from enthalpy and dry-bulb temperature.


    Args:
        MoistAirEnthalpy : Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.

    Notes:
        Based on the `GetMoistAirEnthalpy` function, rearranged for humidity ratio.
"""
function GetHumRatioFromEnthalpyAndTDryBulb(MoistAirEnthalpy::Real, TDryBulb::Real)
    if isIP()
        HumRatio  = (MoistAirEnthalpy - 0.240 * TDryBulb) / (1061.0 + 0.444 * TDryBulb)
    else
        HumRatio  = (MoistAirEnthalpy / 1000.0 - 1.006 * TDryBulb) / (2501.0 + 1.86 * TDryBulb)
    end

    # Validity check.
    return max(HumRatio, MIN_HUM_RATIO)
end
