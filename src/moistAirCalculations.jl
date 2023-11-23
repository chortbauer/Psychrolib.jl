#######################################################################################################
# Moist Air Calculations
#######################################################################################################

export GetVaporPressureDeficit, GetDegreeOfSaturation, GetMoistAirEnthalpy, GetMoistAirVolume, GetTDryBulbFromMoistAirVolumeAndHumRatio, GetMoistAirDensity

"""
    GetVaporPressureDeficit(TDryBulb::Real, HumRatio::Real, Pressure::Real)

    Return Vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Vapor pressure deficit in Psi [IP] or Pa [SI]

    Reference:
        Oke (1987) eqn 2.13a
"""
function GetVaporPressureDeficit(TDryBulb::Real, HumRatio::Real, Pressure::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio is negative")
    end

    RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    GetSatVapPres(TDryBulb) * (1 - RelHum)
end

"""
    GetDegreeOfSaturation(TDryBulb::Real, HumRatio::Real, Pressure::Real)

    Return the degree of saturation (i.e humidity ratio of the air / humidity ratio of the air at saturation
    at the same temperature and pressure) given dry-bulb temperature, humidity ratio, and atmospheric pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Degree of saturation in arbitrary unit

    Reference:
        ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn 12

    Notes:
        This definition is absent from the 2017 Handbook. Using 2009 version instead.
"""
function GetDegreeOfSaturation(TDryBulb::Real, HumRatio::Real, Pressure::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio is negative")
    end
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    SatHumRatio = GetSatHumRatio(TDryBulb, Pressure)
    BoundedHumRatio / SatHumRatio
end

"""
    GetMoistAirEnthalpy(TDryBulb::Real, HumRatio::Real)

    Return moist air enthalpy given dry-bulb temperature and humidity ratio.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Returns:
        Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
"""
function GetMoistAirEnthalpy(TDryBulb::Real, HumRatio::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio is negative")
    end
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    if isIP()
        MoistAirEnthalpy = 0.240 * TDryBulb + BoundedHumRatio * (1061 + 0.444 * TDryBulb)
    else
        MoistAirEnthalpy = (1.006 * TDryBulb + BoundedHumRatio * (2501. + 1.86 * TDryBulb)) * 1000
    end
    return MoistAirEnthalpy
end

"""
    GetMoistAirVolume(TDryBulb::Real, HumRatio::Real, Pressure::Real)

    Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Specific volume of moist air in ft³ lb⁻¹ of dry air [IP] or in m³ kg⁻¹ of dry air [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26

    Notes:
        In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
        The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
"""
function GetMoistAirVolume(TDryBulb::Real, HumRatio::Real, Pressure::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio is negative")
    end
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    if isIP()
        MoistAirVolume = R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) * (1 + 1.607858 * BoundedHumRatio) / (144 * Pressure)
    else
        MoistAirVolume = R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) * (1 + 1.607858 * BoundedHumRatio) / Pressure
    end
    return MoistAirVolume
end

"""
    GetTDryBulbFromMoistAirVolumeAndHumRatio(MoistAirVolume::Real, HumRatio::Real, Pressure::Real)

    Return dry-bulb temperature given moist air specific volume, humidity ratio, and pressure.

    Args:
        MoistAirVolume: Specific volume of moist air in ft³ lb⁻¹ of dry air [IP] or in m³ kg⁻¹ of dry air [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26

    Notes:
        In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
        The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
        Based on the `GetMoistAirVolume` function, rearranged for dry-bulb temperature.
"""
function GetTDryBulbFromMoistAirVolumeAndHumRatio(MoistAirVolume::Real, HumRatio::Real, Pressure::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio is negative")
    end
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    if isIP()
        TDryBulb = GetTFahrenheitFromTRankine(MoistAirVolume * (144 * Pressure) / (R_DA_IP * (1 + 1.607858 * BoundedHumRatio)))
    else
        TDryBulb = GetTCelsiusFromTKelvin(MoistAirVolume * Pressure / (R_DA_SI * (1 + 1.607858 * BoundedHumRatio)))
    end
    return TDryBulb
end

"""
    GetMoistAirDensity(TDryBulb::Real, HumRatio::Real, Pressure::Real)

    Return moist air density given humidity ratio, dry bulb temperature, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        MoistAirDensity: Moist air density in lb ft⁻³ [IP] or kg m⁻³ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 11
"""
function GetMoistAirDensity(TDryBulb::Real, HumRatio::Real, Pressure::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio is negative")
    end
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    MoistAirVolume = GetMoistAirVolume(TDryBulb, BoundedHumRatio, Pressure)
    (1 + BoundedHumRatio) / MoistAirVolume
end
