#######################################################################################################
# Conversions between dew point, wet bulb, and relative humidity
#######################################################################################################

export GetTWetBulbFromTDewPoint, GetTWetBulbFromRelHum, GetRelHumFromTDewPoint, GetRelHumFromTWetBulb, GetTDewPointFromRelHum, GetTDewPointFromTWetBulb

"""
    GetTWetBulbFromTDewPoint(TDryBulb::Real, TDewPoint::Real, Pressure::Real)

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
function GetTWetBulbFromTDewPoint(TDryBulb::Real, TDewPoint::Real, Pressure::Real)
    if TDewPoint > TDryBulb
        ArgumentError("Dew point temperature is above dry bulb temperature")
    end
    HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure)
    TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
end

"""
    GetTWetBulbFromRelHum(TDryBulb::Real, RelHum::Real, Pressure::Real)

    Return wet-bulb temperature given dry-bulb temperature, relative humidity, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        RelHum : Relative humidity in range [0, 1]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Wet-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

"""
function GetTWetBulbFromRelHum(TDryBulb::Real, RelHum::Real, Pressure::Real)
    if RelHum < 0 || RelHum > 1
        ArgumentError("Relative humidity is outside range [0, 1]")
    end
    HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
    TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
end

"""
    GetRelHumFromTDewPoint(TDryBulb::Real, TDewPoint::Real)

    Return relative humidity given dry-bulb temperature and dew-point temperature.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]

    Returns:
        Relative humidity in range [0, 1]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22
"""
function GetRelHumFromTDewPoint(TDryBulb::Real, TDewPoint::Real)
    if TDewPoint > TDryBulb
        ArgumentError("Dew point temperature is above dry bulb temperature")
    end

    VapPres = GetSatVapPres(TDewPoint)
    SatVapPres = GetSatVapPres(TDryBulb)
    RelHum = VapPres / SatVapPres
end

"""
    GetRelHumFromTWetBulb(TDryBulb::Real, TWetBulb::Real, Pressure::Real)

    Return relative humidity given dry-bulb temperature, wet bulb temperature and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Relative humidity in range [0, 1]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1
"""
function GetRelHumFromTWetBulb(TDryBulb::Real, TWetBulb::Real, Pressure::Real)
    if TWetBulb > TDryBulb
        ArgumentError("Wet bulb temperature is above dry bulb temperature")
    end
    HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
end

"""
    GetTDewPointFromRelHum(TDryBulb::Real, RelHum::Real)

    Return dew-point temperature given dry-bulb temperature and relative humidity.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        RelHum: Relative humidity in range [0, 1]

    Returns:
        Dew-point temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1
"""
function GetTDewPointFromRelHum(TDryBulb::Real, RelHum::Real)
    if RelHum < 0 || RelHum > 1
        ArgumentError("Relative humidity is outside range [0, 1]")
    end

    VapPres = GetVapPresFromRelHum(TDryBulb, RelHum)
    TDewPoint = GetTDewPointFromVapPres(TDryBulb, VapPres)
end

"""
    GetTDewPointFromTWetBulb(TDryBulb::Real, TWetBulb::Real, Pressure::Real)

    Return dew-point temperature given dry-bulb temperature, wet-bulb temperature, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Dew-point temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1
"""
function GetTDewPointFromTWetBulb(TDryBulb::Real, TWetBulb::Real, Pressure::Real)
    if TWetBulb > TDryBulb
        ArgumentError("Wet bulb temperature is above dry bulb temperature")
    end
    HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
end
