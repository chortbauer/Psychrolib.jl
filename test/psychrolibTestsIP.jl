@testset "Psychrolib.jl IP" begin
    # set the unit system to Imperial
    SetUnitSystem(Psychrolib.IP)

    @testset "Test of helper functions" begin
        # Test of helper functions
        @test isapprox(GetTRankineFromTFahrenheit(70), 529.67, rtol=0.000001)
        @test isapprox(GetTFahrenheitFromTRankine(529.67), 70, rtol=0.000001)
    end

    @testset "Tests at saturation" begin
        ###############################################################################
        # Tests at saturation
        ###############################################################################

        # Test saturation vapour pressure calculation
        # The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        # over the range [-148, +392] F
        # ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -76 F
        @test isapprox(GetSatVapPres(-76), 0.000157, atol=0.00001)
        @test isapprox(GetSatVapPres(-4), 0.014974, rtol=0.0003)
        @test isapprox(GetSatVapPres(23), 0.058268, rtol=0.0003)
        @test isapprox(GetSatVapPres(41), 0.12656, rtol=0.0003)
        @test isapprox(GetSatVapPres(77), 0.45973, rtol=0.0003)
        @test isapprox(GetSatVapPres(122), 1.79140, rtol=0.0003)
        @test isapprox(GetSatVapPres(212), 14.7094, rtol=0.0003)
        @test isapprox(GetSatVapPres(300), 67.0206, rtol=0.0003)

        # Test that the NR in GetTDewPointFromVapPres converges.
        # This test was known problem in versions of PsychroLib <= 2.0.0
        TDryBulb = -148:1:392
        RelHum = 0:0.1:1
        Pressure = 8.6:1:17.4
        @test_nowarn for T in TDryBulb
            for RH in RelHum
                for p in Pressure
                    GetTWetBulbFromRelHum(T, RH, p)
                end
            end
        end

        # Test saturation humidity ratio
        # The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        # Agreement is not terrific - up to 2% difference with the values published in the table
        @test isapprox(GetSatHumRatio(-58, 14.696), 0.0000243, rtol=0.01)
        @test isapprox(GetSatHumRatio(-4, 14.696), 0.0006373, rtol=0.01)
        @test isapprox(GetSatHumRatio(23, 14.696), 0.0024863, rtol=0.005)
        @test isapprox(GetSatHumRatio(41, 14.696), 0.005425, rtol=0.005)
        @test isapprox(GetSatHumRatio(77, 14.696), 0.020173, rtol=0.005)
        @test isapprox(GetSatHumRatio(122, 14.696), 0.086863, rtol=0.01)
        @test isapprox(GetSatHumRatio(185, 14.696), 0.838105, rtol=0.02)

        # Test enthalpy at saturation
        # The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        # Agreement is rarely better than 1%, and close to 3% at -5 C
        @test isapprox(GetSatAirEnthalpy(-58, 14.696), -13.906, rtol=0.01)
        @test isapprox(GetSatAirEnthalpy(-4, 14.696), -0.286, rtol=0.01)
        @test isapprox(GetSatAirEnthalpy(23, 14.696), 8.186, rtol=0.03)
        @test isapprox(GetSatAirEnthalpy(41, 14.696), 15.699, rtol=0.01)
        @test isapprox(GetSatAirEnthalpy(77, 14.696), 40.576, rtol=0.01)
        @test isapprox(GetSatAirEnthalpy(122, 14.696), 126.066, rtol=0.01)
        @test isapprox(GetSatAirEnthalpy(185, 14.696), 999.749, rtol=0.01)
    end

    @testset "Test of primary relationships" begin
        ###############################################################################
        # Test of primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures
        # These relationships are identified with bold arrows in the doc's diagram
        ###############################################################################

        # Test of relationships between vapour pressure and dew point temperature
        # No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
        VapPres = GetVapPresFromTDewPoint(-4.0)
        @test isapprox(GetTDewPointFromVapPres(59.0, VapPres), -4.0, atol=0.001)
        VapPres = GetVapPresFromTDewPoint(41.0)
        @test isapprox(GetTDewPointFromVapPres(59.0, VapPres), 41.0, atol=0.001)
        VapPres = GetVapPresFromTDewPoint(122.0)
        @test isapprox(GetTDewPointFromVapPres(140.0, VapPres), 122.0, atol=0.001)

        ## Test of relationships between humidity ratio and vapour pressure
        ## Humidity ratio values to test against are calculated with Excel
        HumRatio = GetHumRatioFromVapPres(0.45973, 14.175)          # conditions at 77 F, std atm pressure at 1000 ft
        @test isapprox(HumRatio, 0.0208473311024865, rtol=0.000001)
        VapPres = GetVapPresFromHumRatio(HumRatio, 14.175)
        @test isapprox(VapPres, 0.45973, atol=0.00001)

        ## Test of relationships between vapour pressure and relative humidity
        VapPres = GetVapPresFromRelHum(77, 0.8)
        @test isapprox(VapPres, 0.45973 * 0.8, rtol=0.0003)
        RelHum = GetRelHumFromVapPres(77, VapPres)
        @test isapprox(RelHum, 0.8, rtol=0.0003)

        ## Test of relationships between humidity ratio and wet bulb temperature
        ## The formulae are tested for two conditions, one above freezing and the other below
        ## Humidity ratio values to test against are calculated with Excel
        # Above freezing
        HumRatio = GetHumRatioFromTWetBulb(86, 77, 14.175)
        @test isapprox(HumRatio, 0.0187193288418892, rtol=0.0003)
        TWetBulb = GetTWetBulbFromHumRatio(86, HumRatio, 14.175)
        @test isapprox(TWetBulb, 77, atol=0.001)
        # Below freezing
        HumRatio = GetHumRatioFromTWetBulb(30.2, 23.0, 14.175)
        @test isapprox(HumRatio, 0.00114657481090184, rtol=0.0003)
        TWetBulb = GetTWetBulbFromHumRatio(30.2, HumRatio, 14.1751)
        @test isapprox(TWetBulb, 23.0, atol=0.001)
        # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
        @test GetTWetBulbFromHumRatio(25, 1e-09, 95461) == GetTWetBulbFromHumRatio(25, 1e-07, 95461)
    end

    @testset "Dry air calculations" begin
        ###############################################################################
        # Dry air calculations
        ###############################################################################

        # Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
        # Note: the accuracy of the formula is not better than 0.1%, apparently
        @test isapprox(GetDryAirEnthalpy(77), 18.498, rtol=0.001)
        @test isapprox(GetDryAirVolume(77, 14.696), 13.5251, rtol=0.001)
        @test isapprox(GetDryAirDensity(77, 14.696), 1 / 13.5251, rtol=0.001)
        @test isapprox(GetTDryBulbFromEnthalpyAndHumRatio(42.6168, 0.02), 85.97, atol=0.05)
        @test isapprox(GetHumRatioFromEnthalpyAndTDryBulb(42.6168, 86), 0.02, rtol=0.001)
    end

    @testset "Moist air calculations" begin
        ###############################################################################
        # Moist air calculations
        ###############################################################################

        # Values are compared against values calculated with Excel
        @test isapprox(GetMoistAirEnthalpy(86, 0.02), 42.6168, rtol=0.0003)
        @test isapprox(GetMoistAirVolume(86, 0.02, 14.175), 14.7205749002918, rtol=0.0003)
        @test isapprox(GetMoistAirDensity(86, 0.02, 14.175), 0.0692907720594378, rtol=0.0003)

        @test isapprox(GetTDryBulbFromMoistAirVolumeAndHumRatio(14.7205749002918, 0.02, 14.175), 86, rtol=0.0003)
    end

    @testset "Test standard atmosphere" begin
        ###############################################################################
        # Test standard atmosphere
        ###############################################################################

        # The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        @test isapprox(GetStandardAtmPressure(-1000), 15.236, atol=1)
        @test isapprox(GetStandardAtmPressure(0), 14.696, atol=1)
        @test isapprox(GetStandardAtmPressure(1000), 14.175, atol=1)
        @test isapprox(GetStandardAtmPressure(3000), 13.173, atol=1)
        @test isapprox(GetStandardAtmPressure(10000), 10.108, atol=1)
        @test isapprox(GetStandardAtmPressure(30000), 4.371, atol=1)

        @test isapprox(GetStandardAtmTemperature(-1000), 62.6, atol=0.1)
        @test isapprox(GetStandardAtmTemperature(0), 59.0, atol=0.1)
        @test isapprox(GetStandardAtmTemperature(1000), 55.4, atol=0.1)
        @test isapprox(GetStandardAtmTemperature(3000), 48.3, atol=0.1)
        @test isapprox(GetStandardAtmTemperature(10000), 23.4, atol=0.1)
        @test isapprox(GetStandardAtmTemperature(30000), -47.8, atol=0.2)          # Doesn't work with atol = 0.1
    end

    @testset "Test sea level pressure conversions" begin
        ###############################################################################
        # Test sea level pressure conversions
        ###############################################################################

        # Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267,
        # converted to IP
        SeaLevelPressure = GetSeaLevelPressure(14.681662559, 344.488, 62.942)
        @test isapprox(SeaLevelPressure, 14.8640475, atol=0.0001)
        @test isapprox(GetStationPressure(SeaLevelPressure, 344.488, 62.942), 14.681662559, atol=0.0001)
    end
    @testset "Test conversion between humidity types" begin
        ###############################################################################
        # Test conversion between humidity types
        ###############################################################################

        @test isapprox(GetSpecificHumFromHumRatio(0.006), 0.00596421471, rtol=0.01)

        @test isapprox(GetHumRatioFromSpecificHum(0.00596421471), 0.006, rtol=0.01)
    end
    @testset "Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals" begin
        ###############################################################################
        # Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        ###############################################################################

        # This is example 1. The values are provided in the text of the Handbook
        HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = CalcPsychrometricsFromTWetBulb(100, 65, 14.696)
        @test isapprox(HumRatio, 0.00523, atol=0.001)
        @test isapprox(TDewPoint, 40, atol=1.0)             # not great agreement
        @test isapprox(RelHum, 0.13, atol=0.01)
        @test isapprox(MoistAirEnthalpy, 29.80, atol=0.1)
        @test isapprox(MoistAirVolume, 14.22, rtol=0.01)

        # Reverse calculation: recalculate wet bulb temperature from dew point temperature
        HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = CalcPsychrometricsFromTDewPoint(100, TDewPoint, 14.696)
        @test isapprox(TWetBulb, 65, atol=0.1)

        # Reverse calculation: recalculate wet bulb temperature from relative humidity
        HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation = CalcPsychrometricsFromRelHum(100, RelHum, 14.696)
        @test isapprox(TWetBulb, 65, atol=0.1)
    end
end