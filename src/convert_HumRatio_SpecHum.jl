#######################################################################################################
# Conversions between humidity ratio and specific humidity
#######################################################################################################

export GetSpecificHumFromHumRatio, GetHumRatioFromSpecificHum

"""
    GetSpecificHumFromHumRatio(HumRatio::Real)

    Return the specific humidity from humidity ratio (aka mixing ratio).

    Args:
        HumRatio : Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]

    Returns:
        Specific humidity in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b
"""
function GetSpecificHumFromHumRatio(HumRatio::Real)
    if HumRatio < 0
        ArgumentError("Humidity ratio cannot be negative")
    end
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    BoundedHumRatio / (1.0 + BoundedHumRatio)
end

"""
    GetHumRatioFromSpecificHum(SpecificHum::Real)

    Return the humidity ratio (aka mixing ratio) from specific humidity.

    Args:
        SpecificHum : Specific humidity in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b (solved for humidity ratio)
"""
function GetHumRatioFromSpecificHum(SpecificHum::Real)
    if SpecificHum < 0.0 || SpecificHum >= 1.0
        ArgumentError("Specific humidity is outside range [0, 1)")
    end

    HumRatio = SpecificHum / (1.0 - SpecificHum)

    # Validity check.
    return max(HumRatio, MIN_HUM_RATIO)
end