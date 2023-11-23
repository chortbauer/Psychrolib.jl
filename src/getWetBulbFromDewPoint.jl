function GetTWetBulbFromTDewPoint(TDryBulb::Real, TDewPoint::Real, Pressure::Real)
    """
    Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Wet-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    # if TDewPoint > TDryBulb:
    #     raise ValueError("Dew point temperature is above dry bulb temperature")
    # end
    # HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure)
    # TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
    true #TODO
end
