#######################################################################################################
# Saturated Air Calculations
#######################################################################################################

export GetSatVapPres, GetSatHumRatio, GetSatAirEnthalpy

"""
    GetSatVapPres(TDryBulb::Real)

    Return saturation vapor pressure given dry-bulb temperature.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Vapor pressure of saturated air in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6
        Important note: the ASHRAE formulae are defined above and below the freezing point but have
        a discontinuity at the freezing point. This is a small inaccuracy on ASHRAE's part: the formulae
        should be defined above and below the triple point of water (not the feezing point) in which case
        the discontinuity vanishes. It is essential to use the triple point of water otherwise function
        GetTDewPointFromVapPres, which inverts the present function, does not converge properly around
        the freezing point.
"""
function GetSatVapPres(TDryBulb::Real)
    if isIP()
        if (TDryBulb < -148 || TDryBulb > 392)
            ArgumentError("Dry bulb temperature must be in range [-148, 392]°F")
        end

        T = GetTRankineFromTFahrenheit(TDryBulb)

        if (TDryBulb <= TRIPLE_POINT_WATER_IP)
            LnPws = (-1.0214165E+04 / T - 4.8932428 - 5.3765794E-03 * T + 1.9202377E-07 * T^2 + 3.5575832E-10 * ^(T, 3) - 9.0344688E-14 * ^(T, 4) + 4.1635019 * log(T))
        else
            LnPws = -1.0440397E+04 / T - 1.1294650E+01 - 2.7022355E-02 * T + 1.2890360E-05 * T^2 - 2.4780681E-09 * ^(T, 3) + 6.5459673 * log(T)
        end
    else
        if (TDryBulb < -100 || TDryBulb > 200)
            ArgumentError("Dry bulb temperature must be in range [-100, 200]°C")
        end

        T = GetTKelvinFromTCelsius(TDryBulb)

        if (TDryBulb <= TRIPLE_POINT_WATER_SI)
            LnPws = -5.6745359E+03 / T + 6.3925247 - 9.677843E-03 * T + 6.2215701E-07 * T^2 + 2.0747825E-09 * ^(T, 3) - 9.484024E-13 * ^(T, 4) + 4.1635019 * log(T)
        else
            LnPws = -5.8002206E+03 / T + 1.3914993 - 4.8640239E-02 * T + 4.1764768E-05 * T^2 - 1.4452093E-08 * ^(T, 3) + 6.5459673 * log(T)
        end
    end

    exp(LnPws)
end

"""
    GetSatHumRatio(TDryBulb::Real, Pressure::Real)

    Return humidity ratio of saturated air given dry-bulb temperature and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio of saturated air in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
"""
function GetSatHumRatio(TDryBulb::Real, Pressure::Real)
    SatVaporPres = GetSatVapPres(TDryBulb)
    SatHumRatio = 0.621945 * SatVaporPres / (Pressure - SatVaporPres)

    # Validity check.
    max(SatHumRatio, MIN_HUM_RATIO)
end

"""
    GetSatAirEnthalpy(TDryBulb::Real, Pressure::Real)

    Return saturated air enthalpy given dry-bulb temperature and pressure.

    Args:
        TDryBulb: Dry-bulb temperature in °F [IP] or °C [SI]
        Pressure: Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Saturated air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1
"""
function GetSatAirEnthalpy(TDryBulb::Real, Pressure::Real)
    SatHumRatio = GetSatHumRatio(TDryBulb, Pressure)
    GetMoistAirEnthalpy(TDryBulb, SatHumRatio)
end
