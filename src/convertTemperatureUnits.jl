#######################################################################################################
# Conversion between temperature units
#######################################################################################################

export GetTRankineFromTFahrenheit,
    GetTFahrenheitFromTRankine, GetTKelvinFromTCelsius, GetTCelsiusFromTKelvin

"""
    GetTRankineFromTFahrenheit(TFahrenheit::Real)

    Utility function to convert temperature to degree Rankine (°R)
    given temperature in degree Fahrenheit (°F).

    Args:
        TRankine: Temperature in degree Fahrenheit (°F)

    Returns:
        Temperature in degree Rankine (°R)

    Reference:
        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3

    Notes:
        Exact conversion.
"""
function GetTRankineFromTFahrenheit(TFahrenheit::Real)
    TFahrenheit + ZERO_FAHRENHEIT_AS_RANKINE
end

"""
    GetTFahrenheitFromTRankine(TRankine::Real)

    Utility function to convert temperature to degree Fahrenheit (°F)
    given temperature in degree Rankine (°R).

    Args:
        TRankine: Temperature in degree Rankine (°R)

    Returns:
        Temperature in degree Fahrenheit (°F)

    Reference:
        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3

    Notes:
        Exact conversion.
"""
function GetTFahrenheitFromTRankine(TRankine::Real)
    TRankine - ZERO_FAHRENHEIT_AS_RANKINE
end

"""
    GetTKelvinFromTCelsius(TCelsius::Real)

    Utility function to convert temperature to Kelvin (K)
    given temperature in degree Celsius (°C).

    Args:
        TCelsius: Temperature in degree Celsius (°C)

    Returns:
        Temperature in Kelvin (K)

    Reference:
        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3

    Notes:
        Exact conversion.
"""
function GetTKelvinFromTCelsius(TCelsius::Real)
    TCelsius + ZERO_CELSIUS_AS_KELVIN
end

"""
    GetTCelsiusFromTKelvin(TKelvin::Real)

    Utility function to convert temperature to degree Celsius (°C)
    given temperature in Kelvin (K).

    Args:
        TKelvin: Temperature in Kelvin (K)

    Returns:
        Temperature in degree Celsius (°C)

    Reference:
        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3

    Notes:
        Exact conversion.
"""
function GetTCelsiusFromTKelvin(TKelvin::Real)
    TKelvin - ZERO_CELSIUS_AS_KELVIN
end