# Psychrolib.jl (version 0.1.0) (https://github.com/chortbauer/Psychrolib.jl)
# Adapted from PsychroLib (version 2.5.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
# Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
# Licensed under the MIT License.

""" Psychrolib.jl

Contains functions for calculating thermodynamic properties of gas-vapor mixtures
and standard atmosphere suitable for most engineering, physical and meteorological
applications.

Most of the functions are an implementation of the formulae found in the
2017 ASHRAE Handbook - Fundamentals, in both International System (SI),
and Imperial (IP) units. Please refer to the information included in
each function for their respective reference.

Example
    >>> using Psychrolib
    >>> # Set the unit system, for example to SI (can be either psychrolib.SI or psychrolib.IP)
    >>> SetUnitSystem(Psychrolib.SI)
    >>> # Calculate the dew point temperature for a dry bulb temperature of 25 C and a relative humidity of 80%
    >>> TDewPoint = GetTDewPointFromRelHum(25.0, 0.80)
    21.309397163329322

Copyright
    - For the current library implementation
        Copyright (c) 2018-2020 The PsychroLib Contributors.
    - For equations and coefficients published ASHRAE Handbook — Fundamentals, Chapter 1
        Copyright (c) 2017 ASHRAE Handbook — Fundamentals (https://www.ashrae.org)

License
    MIT (https://github.com/psychrometrics/psychrolib/LICENSE.txt)

Note from the Authors
    We have made every effort to ensure that the code is adequate, however, we make no
    representation with respect to its accuracy. Use at your own risk. Should you notice
    an error, or if you have a suggestion, please notify us through GitHub at
    https://github.com/psychrometrics/psychrolib/issues.


"""
module Psychrolib

include("unitSystemHandling.jl")
include("globalConstants.jl")
include("convertTemperatureUnits.jl")
include("convertDewPointWetBulb_RelHum.jl")
include("convertRelHum_VaporPressure.jl")
include("convertRelHum_HumRatio.jl")
include("convertHumRatio_VaporPressure.jl")
include("convertHumRatio_SpecificHum.jl")
include("dryAirCalculatioins.jl")
include("saturatedAirCalculations.jl")
include("moistAirCalculations.jl")
include("standardAtmosphere.jl")
include("allPsychroValues.jl")

end
