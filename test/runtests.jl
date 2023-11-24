using Psychrolib
using Test

@testset "Psychrolib.jl SI" begin
    # set the unit system to SI
    SetUnitSystem(Psychrolib.SI)

    # Test of helper functions
    @test isapprox(293.15, GetTKelvinFromTCelsius(20), rtol=0.000001)
    @test isapprox(GetTCelsiusFromTKelvin(293.15), 20, rtol=0.000001)

    @testset "Tests at saturation" begin
        ###############################################################################
        # Tests at saturation
        ###############################################################################

        # Test saturation vapour pressure calculation
        # The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        # over the range [-100, +200] C
        # ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -60 C
        @test isapprox(GetSatVapPres(-60), 1.08, atol=0.01)
        @test isapprox(GetSatVapPres(-20), 103.24, rtol=0.0003)
        @test isapprox(GetSatVapPres(-5), 401.74, rtol=0.0003)
        @test isapprox(GetSatVapPres(5), 872.6, rtol=0.0003)
        @test isapprox(GetSatVapPres(25), 3169.7, rtol=0.0003)
        @test isapprox(GetSatVapPres(50), 12351.3, rtol=0.0003)
        @test isapprox(GetSatVapPres(100), 101418.0, rtol=0.0003)
        @test isapprox(GetSatVapPres(150), 476101.4, rtol=0.0003)

        # Test saturation humidity ratio
        # The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        # Agreement is not terrific - up to 2% difference with the values published in the table
        @test isapprox(GetSatHumRatio(-50, 101325), 0.0000243, rtol=0.01)
        @test isapprox(GetSatHumRatio(-20, 101325), 0.0006373, rtol=0.01)
        @test isapprox(GetSatHumRatio(-5, 101325), 0.0024863, rtol=0.005)
        @test isapprox(GetSatHumRatio(5, 101325), 0.005425, rtol=0.005)
        @test isapprox(GetSatHumRatio(25, 101325), 0.020173, rtol=0.005)
        @test isapprox(GetSatHumRatio(50, 101325), 0.086863, rtol=0.01)
        @test isapprox(GetSatHumRatio(85, 101325), 0.838105, rtol=0.02)

        # Test enthalpy at saturation
        # The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        # Agreement is rarely better than 1%, and close to 3% at -5 C
        @test isapprox(GetSatAirEnthalpy(-50, 101325), -50222, rtol=0.01)
        @test isapprox(GetSatAirEnthalpy(-20, 101325), -18542, rtol=0.01)
        @test isapprox(GetSatAirEnthalpy(-5, 101325), 1164, rtol=0.03)
        @test isapprox(GetSatAirEnthalpy(5, 101325), 18639, rtol=0.01)
        @test isapprox(GetSatAirEnthalpy(25, 101325), 76504, rtol=0.01)
        @test isapprox(GetSatAirEnthalpy(50, 101325), 275353, rtol=0.01)
        @test isapprox(GetSatAirEnthalpy(85, 101325), 2307539, rtol=0.01)
    end

    @testset "primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures" begin
        ###############################################################################
        # Test of primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures
        # These relationships are identified with bold arrows in the doc's diagram
        ###############################################################################

        # Test of relationships between vapour pressure and dew point temperature
        # No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above

        VapPres = GetVapPresFromTDewPoint(-20.0)
        @test isapprox(GetTDewPointFromVapPres(15.0, VapPres), -20.0, atol=0.001)

        VapPres = GetVapPresFromTDewPoint(5.0)
        @test isapprox(GetTDewPointFromVapPres(15.0, VapPres), 5.0, atol=0.001)

        VapPres = GetVapPresFromTDewPoint(50.0)
        @test isapprox(GetTDewPointFromVapPres(60.0, GetVapPresFromTDewPoint(50.0)), 50.0, atol=0.001)

        # # Test of relationships between wet bulb temperature and relative humidity
        # # This test was known to cause a convergence issue in GetTDewPointFromVapPres
        # # in versions of PsychroLib <= 2.0.0

        TWetBulb = GetTWetBulbFromRelHum(7.0, 0.61, 100000)
        @test isapprox(TWetBulb, 3.92667433781955, rtol=0.001)

        # Test that the NR in GetTDewPointFromVapPres converges.
        # This test was known problem in versions of PsychroLib <= 2.0.0
        TDryBulb = -100:1:200
        RelHum = 0:0.1:1
        Pressure = 60000:10000:120000
        @test_nowarn for T in TDryBulb
            for RH in RelHum
                for p in Pressure
                    GetTWetBulbFromRelHum(T, RH, p)
                end
            end
        end

        # Test of relationships between humidity ratio and vapour pressure
        # Humidity ratio values to test against are calculated with Excel
        HumRatio = GetHumRatioFromVapPres(3169.7, 95461)          # conditions at 25 C, std atm pressure at 500 m
        @test isapprox(HumRatio, 0.0213603998047487, rtol=0.000001)
        VapPres = GetVapPresFromHumRatio(HumRatio, 95461)
        @test isapprox(VapPres, 3169.7, atol=0.00001)

        # Test of relationships between vapour pressure and relative humidity
        VapPres = GetVapPresFromRelHum(25, 0.8)
        @test isapprox(VapPres, 3169.7 * 0.8, rtol=0.0003)
        RelHum = GetRelHumFromVapPres(25, VapPres)
        @test isapprox(RelHum, 0.8, rtol=0.0003)

        # Test of relationships between humidity ratio and wet bulb temperature
        # The formulae are tested for two conditions, one above freezing and the other below
        # Humidity ratio values to test against are calculated with Excel
        # Above freezing
        HumRatio = GetHumRatioFromTWetBulb(30, 25, 95461)
        @test isapprox(HumRatio, 0.0192281274241096, rtol=0.0003)
        TWetBulb = GetTWetBulbFromHumRatio(30, HumRatio, 95461)
        @test isapprox(TWetBulb, 25, atol=0.001)
        # Below freezing
        HumRatio = GetHumRatioFromTWetBulb(-1, -5, 95461)
        @test isapprox(HumRatio, 0.00120399819933844, rtol=0.0003)
        TWetBulb = GetTWetBulbFromHumRatio(-1, HumRatio, 95461)
        @test isapprox(TWetBulb, -5, atol=0.001)
        # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
        @test isapprox(GetTWetBulbFromHumRatio(-5, 1e-09, 95461), GetTWetBulbFromHumRatio(-5, 1e-07, 95461))
    end

    @testset "Dry air calculations" begin
        ###############################################################################
        # Dry air calculations
        ###############################################################################

        # Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
        # Note: the accuracy of the formula is not better than 0.1%, apparently
        @test isapprox(GetDryAirEnthalpy(25), 25148, rtol=0.0003)
        @test isapprox(GetDryAirVolume(25, 101325), 0.8443, rtol=0.001)
        @test isapprox(GetDryAirDensity(25, 101325), 1 / 0.8443, rtol=0.001)
        @test isapprox(GetTDryBulbFromEnthalpyAndHumRatio(81316, 0.02), 30, atol=0.001)
        @test isapprox(GetHumRatioFromEnthalpyAndTDryBulb(81316, 30), 0.02, rtol=0.001)
    end

    @testset "Moist air calculations" begin
        ###############################################################################
        # Moist air calculations
        ###############################################################################

        # Values are compared against values calculated with Excel
        @test isapprox(GetMoistAirEnthalpy(30, 0.02), 81316, rtol=0.0003)
        @test isapprox(GetMoistAirVolume(30, 0.02, 95461), 0.940855374352943, rtol=0.0003)
        @test isapprox(GetMoistAirDensity(30, 0.02, 95461), 1.08411986348219, rtol=0.0003)

        @test isapprox(GetTDryBulbFromMoistAirVolumeAndHumRatio(0.940855374352943, 0.02, 95461), 30, rtol=0.0003)
    end

    @testset "Standard atmosphere" begin
        ###############################################################################
        # Test standard atmosphere
        ###############################################################################

        # The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        @test isapprox(GetStandardAtmPressure(-500), 107478, atol=1)
        @test isapprox(GetStandardAtmPressure(0), 101325, atol=1)
        @test isapprox(GetStandardAtmPressure(500), 95461, atol=1)
        @test isapprox(GetStandardAtmPressure(1000), 89875, atol=1)
        @test isapprox(GetStandardAtmPressure(4000), 61640, atol=1)
        @test isapprox(GetStandardAtmPressure(10000), 26436, atol=1)

        @test isapprox(GetStandardAtmTemperature(-500), 18.2, atol=0.1)
        @test isapprox(GetStandardAtmTemperature(0), 15.0, atol=0.1)
        @test isapprox(GetStandardAtmTemperature(500), 11.8, atol=0.1)
        @test isapprox(GetStandardAtmTemperature(1000), 8.5, atol=0.1)
        @test isapprox(GetStandardAtmTemperature(4000), -11.0, atol=0.1)
        @test isapprox(GetStandardAtmTemperature(10000), -50.0, atol=0.1)
    end

    @testset "sea level pressure conversions" begin
        ###############################################################################
        # Test sea level pressure conversions
        ###############################################################################

        # Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267
        SeaLevelPressure = GetSeaLevelPressure(101226.5, 105, 17.19)
        @test isapprox(SeaLevelPressure, 102484.0, atol=1)
        @test isapprox(GetStationPressure(SeaLevelPressure, 105, 17.19), 101226.5, atol=1)
    end

    @testset "conversion between humidity types" begin
        ###############################################################################
        # Test conversion between humidity types
        ###############################################################################

        @test isapprox(GetSpecificHumFromHumRatio(0.006), 0.00596421471, rtol=0.01)
        @test isapprox(GetHumRatioFromSpecificHum(0.00596421471), 0.006, rtol=0.01)
    end

    @testset "Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals" begin
        ###############################################################################
        # Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        ###############################################################################

        # This is example 1. The values are provided in the text of the Handbook
        HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = CalcPsychrometricsFromTWetBulb(40, 20, 101325)
        @test isapprox(HumRatio, 0.0065, atol=0.0001)
        @test isapprox(TDewPoint, 7, atol=0.5)             # not great agreement
        @test isapprox(RelHum, 0.14, atol=0.01)
        @test isapprox(MoistAirEnthalpy, 56700, atol=100)
        @test isapprox(MoistAirVolume, 0.896, rtol=0.01)

        # Reverse calculation: recalculate wet bulb temperature from dew point temperature
        HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = CalcPsychrometricsFromTDewPoint(40, TDewPoint, 101325)
        @test isapprox(TWetBulb, 20, atol=0.1)

        # Reverse calculation: recalculate wet bulb temperature from relative humidity
        HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = CalcPsychrometricsFromRelHum(40, RelHum, 101325)
        @test isapprox(TWetBulb, 20, atol=0.1)
    end
end




