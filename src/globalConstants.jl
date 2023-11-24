#######################################################################################################
# Global constants
#######################################################################################################

ZERO_FAHRENHEIT_AS_RANKINE = 459.67
"""float: Zero degree Fahrenheit (°F) expressed as degree Rankine (°R)

    Units:
        °R

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 39

"""

ZERO_CELSIUS_AS_KELVIN = 273.15
"""float: Zero degree Celsius (°C) expressed as Kelvin (K)

    Units:
        K

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 39

"""

R_DA_IP = 53.350
"""float: Universal gas constant for dry air (IP version)

    Units:
        ft lb_Force lb_DryAir⁻¹ R⁻¹

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

"""

R_DA_SI = 287.042
"""float: Universal gas constant for dry air (SI version)

    Units:
        J kg_DryAir⁻¹ K⁻¹

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

"""

MAX_ITER_COUNT = 100
"""int: Maximum number of iterations before exiting while loops.

"""

MIN_HUM_RATIO = 1e-7
"""float: Minimum acceptable humidity ratio used/returned by any functions.
          Any value above 0 or below the MIN_HUM_RATIO will be reset to this value.

"""

FREEZING_POINT_WATER_IP = 32.0
"""float: Freezing point of water in Fahrenheit.

"""

FREEZING_POINT_WATER_SI = 0.0
"""float: Freezing point of water in Celsius.

"""

TRIPLE_POINT_WATER_IP = 32.018
"""float: Triple point of water in Fahrenheit.

"""

TRIPLE_POINT_WATER_SI = 0.01
"""float: Triple point of water in Celsius.

"""
