#######################################################################################################
# Conversions between humidity ratio and vapor pressure
#######################################################################################################

export GetHumRatioFromVapPres, GetVapPresFromHumRatio

"""
    GetHumRatioFromVapPres(VapPres::Real, Pressure::Real)

    Return humidity ratio given water vapor pressure and atmospheric pressure.

    Args:
        VapPres : Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
"""
function GetHumRatioFromVapPres(VapPres::Real, Pressure::Real)
    if VapPres < 0
        ArgumentError("Partial pressure of water vapor in moist air cannot be negative")
    end

    HumRatio = 0.621945 * VapPres / (Pressure - VapPres)

    # Validity check.
    return max(HumRatio, MIN_HUM_RATIO)
end

"""
    GetVapPresFromHumRatio(HumRatio::Real, Pressure::Real)

    Return vapor pressure given humidity ratio and pressure.

    Args:
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
"""
function GetVapPresFromHumRatio(HumRatio::Real, Pressure::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio is negative")
    end
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    Pressure * BoundedHumRatio / (0.621945 + BoundedHumRatio)
end