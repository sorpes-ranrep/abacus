/-  tokenizer
|%
::  symbols used by parser
+$  symbol
  $?  ?(%number)
      ?(%plus %minus %times %divide %percent)
      ?(%lparen %rparen)
      ?(%expr %term %factor %after-term %after-factor %after-number)
  ==
::  used in factor => factor after-factor
+$  af-cmd
  $@  ~
  $%  [%times f=@rd af=af-cmd]
      [%divide f=@rd af=af-cmd]
  ==
::  used in term => term after-term
+$  at-cmd
  $@  ~
  $%  [%plus t=@rd at=at-cmd]
      [%minus t=@rd at=at-cmd]
  ==
::  states used by tokenizer/dfa
+$  token-state
  $?  %start
      %number  %decimal0  %decimal
      %lparen  %rparen  %op
      %zero
  ==
::  return type; only used in on-peek for now
+$  update
  $%
    [%answer ans=@rd]
    [%unit-types types=(list @t)]
    [%units-of-type units=(list [name=@t symbol=@t])]
  ==
::  fundamental types from which everything else
::  is defined
+$  si-base-unit
  $?  ::time is weird, some units only make sense relative to others
      %second
      %metre
      ::technically should be kilogram, but this makes prefixes easier
      %gram
      %ampere
      ::THIS IS NOT FOR SIMPLE TEMPERATURE CONVERSIONS
      ::THIS IS FOR USE IN COMPOUND UNITS I.E. DEGREE SIZE
      ::It will work as expected when converting from temp to temp
      %kelvin
      %mole
      %candela
      %bit
  ==
+$  si-prefix
  $?  %yotta
      %zetta
      %exa
      %peta
      %tera
      %giga
      %mega
      %kilo
      %hecto
      %deka
      %deci
      %centi
      %milli
      %micro
      %nano
      %pico
      %femto
      %atto
      %zepto
      %yocto
  ==
::  other individual units
+$  other-base-unit
  $?
      ::time
      ::
      %planck-time
      %jiffy-phys
      %svedberg
      %shake
      %jiffy-elec-50
      %jiffy-elec-60
      %minute
      %hour
      %day
      %week
      %fortnight
      %lunar-month
      %month
      %quarantine
      %semester
      %lunar-year
      %year
      %common-year
      %tropical-year
      %gregorian-year
      %sidereal-year
      %leap-year
      %olympiad
      %lustrum
      %decade
      %indiction
      %jubilee
      %century
      %millennium
      ::length
      ::
      %angostrom
      %myriametre
      %x-unit
      %thou
      %inch
      %foot
      %yard
      %mile
      %league
      %fathom
      %nautical-mile
      %chain
      %rod
      %earth-radius
      %lunar-distance
      %au
      %light-year
      %parsec
      %hubble-length
      %electron-radius
      %compton-elec-wl
      %compton-elec-wl-reduced
      %hydrogen-radius
      %hydrogen-wl-reduced
      %planck-length
      %stoney
      %qcd
      %ev-length
      %football-field
      %human-hair
      %furlong
      %horse-length
      ::mass
      ::
      %pound
      %tonne
      %ton-uk  ::"long ton"
      %ton-us  ::"short ton"
      %electron-volt-mass
      %dalton
      %slug
      %ounce
      %troy-ounce
      %planck-mass
      %solar-mass
      %stone
      ::current
      ::
      ::just ampere?
      ::temperature
      ::
      %celsius
      %fahrenheit
      %rankine
      ::%delisle
      ::%newton
      ::%reaumur
      ::%romer
      ::amount of substance
      ::
      %pound-mole
      ::luminosity intensity
      ::
      ::just candela?
      ::
      ::data
      ::
      %byte
  ==
:: unit type
+$  quantity
  $%
      ::base
      %time
      %length
      %mass
      %current
      %temperature
      %amount-of-substance
      %luminosity
      %data
      ::"named units"
      ::
      %frequency
      %angle
      %solid-angle
      %force
      %pressure
      %energy
      %power
      %charge
      %voltage
      %electrical-capacitance
      %electrical-resistance
      %electrical-conductance
      %magnetic-flux
      %magnetic-induction
      %electrical-inductance
      %illuminance
      %radioactivity
      %absorbed-dose
      %equivalent-dose
      %catalytic-activity
      ::kinematic units
      ::
      %speed
      %acceleration
      %jerk
      %snap
      %angular-velocity
      %angular-acceleration
      %frequency-drift
      %volumetric-flow
      ::mechanical units
      ::
      %area
      %volume
      %momentum
      %angular-momentum
      %torque
      %yank
      %wavenumber
      %area-density
      %mass-density
      %specific-volume
      %action
      %specific-energy
      %energy-density
      %surface-tension
      %irradiance
      %kinematic-viscosity
      %dynamic-viscosity
      %linear-mass-density
      %mass-flow-rate
      %radiance
      %spectral-radiance
      %spectral-power
      %absorbed-dose-rate
      %fuel-efficiency
      %spectral-irradiance
      %energy-flux-density
      %compressibility
      %radiant-exposure
      %moment-of-inertia
      %specific-angular-momentum
      %radiant-intensity
      %spectral-intensity
      ::molar units
      ::
      %molarity
      %molar-volume
      %molar-heat-capacity
      %molar-energy
      %molar-conductivity
      %molality
      %molar-mass
      %catalytic-efficiency
      ::electromagnetic units
      ::
      %electric-displacement-field
      %electric-charge-density
      %electric-current-density
      %electrical-conductivity
      %permittivity
      %magnetic-permeability
      %electric-field-strength
      %magnetization
      %exposure
      %resistivity
      %linear-charge-density
      %magnetic-dipole-moment
      %electron-mobility
      %magnetic-reluctance
      %magnetic-vector-potential
      %magnetic-moment
      %magnetic-rigidity
      %magnetomotive-force
      %magnetic-susceptibility
      ::photometric unit
      ::
      %luminous-energy
      %luminous-exposure
      %luminance
      %luminous-efficacy
      ::thermodynamic units
      ::
      %heat-capacity
      %specific-heat-capacity
      %thermal-conductivity
      %thermal-resistance
      %thermal-expansion-coefficient
      %temperature-gradient
  ==
::  individual unit with optional prefix
+$  tinu
  [pre=(unit si-prefix) base-unit=?(si-base-unit other-base-unit)]
::  a unit that is a product of other units with an amount
::  for convenience
+$  derived-unit
  [amount=@rd (list [base=tinu pow=@s])]
::  the derived unit equivalent of quantity
::  could be used to validate user provided units
+$  quantity-spec
  (list [base=si-base-unit pow=@s])
+$  unit-type
  [name=@t sym=@t du=derived-unit]
--
