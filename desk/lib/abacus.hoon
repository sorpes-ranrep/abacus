/-  *parser, *abacus
|%
::  Convert return type to JSON
++  enjs-update
  =,  enjs:format
  |=  upd=update
  ^-  json
  ?-    -.upd
    ::  Used for results of calculator expressions
    ::  and conversions
      %answer
    ::  {ans: number}
    =+  ans=(frond 'ans' (enjs-rd ans.upd))  ::(crip ~(ram re (cain !>(ans.upd)))))
    ::~&  ans
    ans
    ::  the list of unit types (e.g. time, area, speed)
      %unit-types
    =/  ans=json
      ::  {units: string[]}
      %+  frond
        'types'
      a+(turn types.upd |=(name=@t s+name))
    :: ~&  ans
    ans
      %units-of-type
    =/  ans=json
      :: {units: {name: string, symbol: string}[]}
      %+  frond
        'units'
      a+(turn units.upd |=([name=@t symbol=@t] (pairs ~[['name' s+name] ['symbol' s+symbol]])))
    ::~&  ans
    ans
  ==
++  enjs-rd
  =,  enjs:format
  |=  n=@rd
  ^-  json
  ::  trims off the .~ at the begining of a rendered @rd
  ::  probably not the best way
  n+(crip =>((text !>(n)) ?~(. !! ?~(t.. !! t.t..))))
::TODO: make all return types a head tagged union
::each recursive call needs a switch to check type
::
::  these eval-* arms are for evaluating
::  the parse-tree
::
::  eval expr
++  eval-e
  |=  n=(pt-node symbol tape)
  ^-  @rd
  ::  expr is always a node
  ?>  ?=([%node *] n)
  ?~  children.n
    !!
  ::  the first child is a term node
  ?>  ?=([%node *] i.children.n)
  =/  t=@rd  (eval-t i.children.n)
  ?~  t.children.n
    !!
  ::  the second child is an after-term node
  ?>  ?=([%node *] i.t.children.n)
  =/  cmd=at-cmd  (eval-at i.t.children.n)
  ::  recursively add/sub all terms in after-term
  ::  due to ll(1) parsing technical detail
  |-
  ?~  cmd
    t
  ?-  -.cmd
    %plus   $(t (add:rd t t.cmd), cmd at.cmd)
    %minus  $(t (sub:rd t t.cmd), cmd at.cmd)
  ==
::  eval after-term
::  i.e. +/- term after-term
::  returns a command (a number to add/sub)
::    and a command to do next
::  this gives left associativity from the
::  parse tree's right ...
++  eval-at
  |=  n=(pt-node symbol tape)
  ^-  at-cmd
  ::  always a node
  ?>  ?=([%node *] n)
  ?~  children.n
    ~
  :: first child is a leaf/terminal
  :: always +/-
  ?>  ?=([%leaf *] i.children.n)
  ::  second child is a term
  ?~  t.children.n
    !!
  ::  third child is an after-term
  ?~  t.t.children.n
    !!
  ::  get value of term
  =/  t=@rd  (eval-t i.t.children.n)
  ::  recursively get inner command
  =/  cmd=at-cmd  $(n i.t.t.children.n)
  ?+  s.i.children.n  !!
    %plus   [%plus t cmd]
    %minus  [%minus t cmd]
  ==
::  eval term
++  eval-t
  |=  n=(pt-node symbol tape)
  ^-  @rd
  ::  always a node
  ?>  ?=([%node *] n)
  ?~  children.n
    !!
  :: first child is a factor
  ?>  ?=([%node *] i.children.n)
  =/  f=@rd  (eval-f i.children.n)
  ?~  t.children.n
    !!
  :: second child is an after-factor
  ?>  ?=([%node *] i.t.children.n)
  =/  cmd=af-cmd  (eval-af i.t.children.n)
  ::  recursively mult/div all factors in
  ::  after-factor
  ::  due to technicality analogous to that
  ::    in eval-e
  |-
  ?~  cmd
    f
  ?-  -.cmd
    %times   $(f (mul:rd f f.cmd), cmd af.cmd)
    %divide  $(f (div:rd f f.cmd), cmd af.cmd)
  ==
::  evaluate after-term
::  returns a command similar to that in eval-at
++  eval-af
  |=  n=(pt-node symbol tape)
  ^-  af-cmd
  ::  always a node
  ?>  ?=([%node *] n)
  ?~  children.n
    ~
  ::  first child is times/divide
  ?>  ?=([%leaf *] i.children.n)
  ::  second is factor
  ?~  t.children.n
    !!
  ::  third is after-factor
  ?~  t.t.children.n
    !!
  ::  get value of factor
  =/  f=@rd  (eval-f i.t.children.n)
  ::  recursively get inner command
  =/  cmd=af-cmd  $(n i.t.t.children.n)
  ?+  s.i.children.n  !!
    %times  [%times f cmd]
    %divide  [%divide f cmd]
  ==
::  evaluate factor
::  the numbers is the switch correspond
::    to the index in the prod-rules list in (app/abacus.hoon now)
++  eval-f
  |=  n=(pt-node symbol tape)
  ^-  @rd
  ::  always a node
  ?>  ?=([%node *] n)
  ?~  children.n
    !!
  ::  print rule on crash
  ::~|  rule.n
  ::  each of these (8-10 as of writing)
  ::  is followed by after-number which is
  ::  currently just an optional % sign
  ?+    rule.n  !!
      %8  ::  factor => number after-number
    ::  first child is a number
    ?>  ?=([%leaf *] i.children.n)
    ?>  =(s.i.children.n %number)
    ?~  t.children.n
      !!
    ::  parse number and process with after-number
    (apply-after-number (scan ['~' b.i.children.n] royl-rd:so) i.t.children.n)
      %9  ::  factor => - number after-number
    ::  first child is a - sign
    ?>  ?=([%leaf *] i.children.n)
    ?>  =(s.i.children.n %minus)
    ?~  t.children.n
      !!
    ::  second child is a number
    ?>  ?=([%leaf *] i.t.children.n)
    ?>  =(s.i.t.children.n %number)
    ?~  t.t.children.n
      !!
    ::  parse number and process with after-number
    (apply-after-number (scan ['~' '-' b.i.t.children.n] royl-rd:so) i.t.t.children.n)
      %10  ::  factor => ( expr ) after-number
    ::  first child is (
    ?>  ?=([%leaf *] i.children.n)
    ?>  =(s.i.children.n %lparen)
    ?~  t.children.n
      !!
    ::  second child is expr
    ?>  ?=([%node *] i.t.children.n)
    ?~  t.t.children.n
      !!
    ::  third child is )
    ?>  ?=([%leaf *] i.t.t.children.n)
    ?~  t.t.t.children.n
      !!
    ::  evaluate expr and process with after-number
    (apply-after-number (eval-e i.t.children.n) i.t.t.t.children.n)
  ==
::  currently just used to conditionally
::  divide by 100 for percent sign
::  uses rule indices in prod-rules
++  apply-after-number
  |=  [amount=@rd an-node=(pt-node symbol tape)]
  ^-  @rd
  ::  always a node
  ?>  ?=([%node *] an-node)
  ::  with percent sign
  ?:  =(rule.an-node 11)
    (div:rd amount .~100)
  ::  without percent sign
  ?:  =(rule.an-node 12)
    amount
  !!
::  parser data arms
::
++  all-terminals
  ^-  (set symbol)
  (silt `(list symbol)`~[%number %plus %minus %times %divide %lparen %rparen %percent])
++  all-non-terminals
  ^-  (set symbol)
  (silt `(list symbol)`~[%expr %term %factor %after-term %after-factor %after-number])
::  tokenizer data arms
::
++  all-states
  ^-  (set token-state)
  (silt `(list token-state)`~[%start %number %decimal0 %decimal %op %lparen %rparen %zero])
++  accepting-states
  ^-  (set token-state)
  (silt `(list token-state)`~[%number %decimal %op %zero %lparen %rparen])
++  alpha-chars
  ^-((list @tD) (weld (gulf 'a' 'z') (gulf 'A' 'Z')))
++  dig-chars
  ^-((list @tD) (gulf '0' '9'))
++  op-chars
  ^-((list @tD) ~['+' '-' '*' '/' '^' 'x' '%'])
++  other-chars
  ^-((list @tD) ~['\\' '{' '}' '(' ')' t-sep d-sep])
++  all-chars
  ^-  (set @tD)
  (silt ;:(weld alpha-chars dig-chars op-chars other-chars))
++  alpha-numeric-chars
  ^-  (list @tD)
  (weld alpha-chars dig-chars)
++  nz-dig-chars
  ^-((list @tD) (gulf '1' '9'))
::  not sure if these are used
::
++  t-sep
  ','
++  d-sep
  '.'
::  convert data arms
++  time-units
  ^-  (set ?(si-base-unit other-base-unit))
  %-  silt
  ^-  (list ?(si-base-unit other-base-unit))
  :~  %second
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
  ==
++  length-units
  ^-  (set ?(si-base-unit other-base-unit))
  %-  silt
  ^-  (list ?(si-base-unit other-base-unit))
  :~  %metre
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
  ==
++  mass-units
  ^-  (set ?(si-base-unit other-base-unit))
  %-  silt
  ^-  (list ?(si-base-unit other-base-unit))
  :~  %gram
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
  ==
++  current-units
  ^-  (set ?(si-base-unit other-base-unit))
  %-  silt
  ^-  (list ?(si-base-unit other-base-unit))
  :~  %ampere
  ==
++  temperature-units
  ^-  (set ?(si-base-unit other-base-unit))
  %-  silt
  ^-  (list ?(si-base-unit other-base-unit))
  :~  %kelvin
      %celsius
      %fahrenheit
      %rankine
      ::%delisle
      ::%newton
      ::%reaumur
      ::%romer
  ==
::  map from temperature scale to
::  degrees kelvin at 0 degrees key
::  used for the noraml temperature conversion case
++  temp-bases
  ^-  (map other-base-unit @rd)
  %-  malt
  ^-  (list (pair other-base-unit @rd))
  :~
    [%celsius .~273.15]
    [%fahrenheit .~255.37]
    [%rankine .~0]
  ==
++  amount-units
  ^-  (set ?(si-base-unit other-base-unit))
  %-  silt
  ^-  (list ?(si-base-unit other-base-unit))
  :~  %mole
      %pound-mole
  ==
++  luminosity-units
  ^-  (set ?(si-base-unit other-base-unit))
  %-  silt
  ^-  (list ?(si-base-unit other-base-unit))
  :~  %candela
  ==
++  data-units
  ^-  (set ?(si-base-unit other-base-unit))
  %-  silt
  ^-  (list ?(si-base-unit other-base-unit))
  :~  %bit
  ==
::  used by base-unit-lth
::
++  base-unit-idx
  |=  base-unit=?(si-base-unit other-base-unit)
  ^-  @u
  ?:  (~(has in time-units) base-unit)
    0
  ?:  (~(has in length-units) base-unit)
    1
  ?:  (~(has in mass-units) base-unit)
    2
  ?:  (~(has in current-units) base-unit)
    3
  ?:  (~(has in temperature-units) base-unit)
    4
  ?:  (~(has in amount-units) base-unit)
    5
  ?:  (~(has in luminosity-units) base-unit)
    6
  ?:  (~(has in data-units) base-unit)
    7
  !!
::  used to sort the components of a derived-unit
::  so that conversions are always between units of the same type
::
++  base-unit-lth
  |=  [lhs=(pair tinu ?) rhs=(pair tinu ?)]
  ^-  ?
  (lth (base-unit-idx base-unit.p.lhs) (base-unit-idx base-unit.p.rhs))
::  map a prefix to the power of 10 it represents
::
++  prefix-2-pow
  |=  pre=(unit si-prefix)
  ^-  @s
  ?~  pre
    --0
  ?-  u.pre
    ::&/| deprecated? use %.y/%.n?
    %yotta  (new:si & 24)
    %zetta  (new:si & 21)
    %exa    (new:si & 18)
    %peta   (new:si & 15)
    %tera   (new:si & 12)
    %giga   (new:si & 9)
    %mega   (new:si & 6)
    %kilo   (new:si & 3)
    %hecto  (new:si & 2)
    %deka   (new:si & 1)
    %deci   (new:si | 1)
    %centi  (new:si | 2)
    %milli  (new:si | 3)
    %micro  (new:si | 6)
    %nano   (new:si | 9)
    %pico   (new:si | 12)
    %femto  (new:si | 15)
    %atto   (new:si | 18)
    %zepto  (new:si | 21)
    %yocto  (new:si | 24)
  ==
::
::  TODO
::
::  would like to make it easy to switch from @rd to @rq of fl
::
::can't use wet gate + ?='ing amount
::could probably move the logic to a gate
::  that takes a $% or atom aura pair (dime?) to switch
::  between rd, rq, etc. cores
::then just have one gate for each amount aura which
::  calls the logic with the appropriate args
::
::
::  converts the powers of units to flags and repeats the bases as
::    needed
::  e.g.  ~[[metre --2] [second -1]] => ~[[metre &] [metre &] [second |]]
::
++  expand-unit
  |=  deriv=derived-unit
  ::  list of units and a flag where & => positive power
  =|  expanded=(list (pair tinu ?))
  ^-  [@rd _expanded]
  ::  iterate over the components of deriv
  |-
  ?~  +.deriv
    ::  all components added, sort and return
    [amount.deriv (sort expanded base-unit-lth)]
  ::  record pow (number of times the unit must be repeated)
  =/  c=@u  (abs:si pow.i.+.deriv)
  ::  record sign as flag
  =/  s=?   (syn:si pow.i.+.deriv)
  ::  add unit c times
  |-
  ?:  =(c 0)
    ::  added c times, go to top of outer loop
    ^$(+.deriv t.+.deriv)
  $(expanded [[base.i.+.deriv s] expanded], c (sub c 1))
::
::  main conversion function
::
++  convert-derived-unit
  |=  $:  amount=@rd
          from-unit=derived-unit
          to-unit=derived-unit
          si-map=(map other-base-unit [to=si-base-unit factor=@rd])
          misc-map=(jar other-base-unit [to=other-base-unit factor=@rd])
      ==
  ^-  @rd
  ::  expand types for ease of processing
  ::  undoing this later may make for more intelligible errors
  ::
  =/  [from-amount=@rd exp-from=(list (pair tinu ?))]  (expand-unit from-unit)
  =/  [to-amount=@rd exp-to=(list (pair tinu ?))]  (expand-unit to-unit)
  ::
  ::temperature special case
  ::
  =/  is-temp-conv=?
    ?~  exp-from
      %.n
    ?~  t.exp-from
      ?~  exp-to
        %.n
      ?~  t.exp-to
        ?&  =(from-amount .~1)
            =(to-amount .~1)
            q.i.exp-from
            q.i.exp-to
            =(pre.p.i.exp-from ~)
            =(pre.p.i.exp-to ~)
            (~(has in temperature-units) base-unit.p.i.exp-from)
            (~(has in temperature-units) base-unit.p.i.exp-to)
        ==
      %.n
    %.n
  ?:  is-temp-conv
    ?~  exp-from
      !!
    ?~  exp-to
      !!
    =/  from-type=?(si-base-unit other-base-unit)  base-unit.p.i.exp-from
    =/  to-type=?(si-base-unit other-base-unit)  base-unit.p.i.exp-to
    ::convert from from-temp to kelvin
    ::
    =?  amount  ?=(other-base-unit from-type)
      (add:rd (mul:rd amount factor:(~(got by si-map) from-type)) (~(got by temp-bases) from-type))
    ::convert from kelvin to to-temp
    ::
    =?  amount  ?=(other-base-unit to-type)
      (div:rd (sub:rd amount (~(got by temp-bases) to-type)) factor:(~(got by si-map) to-type))
    ::
    amount
  ::
  ::regular case
  ::
  ::account for top-level amounts
  ::
  =.  amount  (mul:rd from-amount (div:rd amount to-amount))
  |-
  ?~  exp-from
    ?~  exp-to
      ::  all units of from and to processed
      ::  return amount
      amount
    ::  too many units in to-unit
    !!
  ?~  exp-to
    ::  too many units in from-unit
    !!
  ::
  ::  first check for strage units that only convert to a handful
  ::  of others it their type, not used now
  ::
  ::  else
  ::1) convert from to si-unit
  ::2) convert si-unit to to
  ::3) convert prefix
  ::
  ?:  &(?=(other-base-unit base-unit.p.i.exp-from) (~(has by misc-map) base-unit.p.i.exp-from))
    ::"strange" conversion; such as relative times (year, month)
    ::probably need special ordering to make these work in compound
    ::units
    =+  convs=(~(got by misc-map) base-unit.p.i.exp-from)
    |-
    ?~  convs
      !!
    ?:  =(to.i.convs base-unit.p.i.exp-from)
      ^$(exp-from t.exp-from, exp-to t.exp-to, amount (mul:rd amount factor.i.convs))
    $(convs t.convs)
  ::1) convert to si-unit
  ::  record which si-unit is converted to and
  ::  update amount
  =^  si-unit=si-base-unit  amount
    ::  get si-unit and factor from si-map
    ?:  ?=(other-base-unit base-unit.p.i.exp-from)
      =+  (~(got by si-map) base-unit.p.i.exp-from)
      [to ?:(q.i.exp-from (mul:rd amount factor) (div:rd amount factor))]
    ::  already an si-unit, just return it and amount unchanged
    [base-unit.p.i.exp-from amount]
  ::2) convert to to base-unit
  =.  amount
    ::  if to-unit is already si then
    ?:  ?=(si-base-unit base-unit.p.i.exp-to)
      ::  it should be same as what base-unit became
      ?>  =(si-unit base-unit.p.i.exp-to)
      ::  and amount is unchanged
      amount
    ::  assert above?
    ?<  =(si-unit base-unit.p.i.exp-to)
    ::  get factor from si-map
    =+  (~(got by si-map) base-unit.p.i.exp-to)
    ::  divide or multiply if to-unit is a numerator or denominator
    ::  respectively
    ?:(q.i.exp-to (div:rd amount factor) (mul:rd amount factor))
  ::3) convert prefix and recurse
  =/  pow-diff=@s  (dif:si (prefix-2-pow pre.p.i.exp-from) (prefix-2-pow pre.p.i.exp-to))
  $(exp-from t.exp-from, exp-to t.exp-to, amount (mul:rd amount (ryld `dn`[%d & pow-diff 1])))
::
::  helper to efficiently make list to map
::  but allow references to previous units
++  make-si-map
  |=  si-map-list=(list [from=other-base-unit to=?(si-base-unit other-base-unit) factor=@rd])
  ^-  (map other-base-unit [to=si-base-unit factor=@rd])
  =/  [to-si-list=(list (pair other-base-unit [to=si-base-unit factor=@rd])) rem=_si-map-list]  [~ ~]
  =.  -
    |-
    ?~  si-map-list
      [to-si-list rem]
    =?  to-si-list  ?=(si-base-unit to.i.si-map-list)
      [[from.i.si-map-list to.i.si-map-list factor.i.si-map-list] to-si-list]
    =?  rem  ?=(other-base-unit to.i.si-map-list)
      [i.si-map-list rem]
    $(si-map-list t.si-map-list)
  =/  si-map=(map other-base-unit [to=si-base-unit factor=@rd])  (malt to-si-list)
  =|  new-rem=_rem
  |-
  ?~  rem
    si-map
  =.  new-rem  ~
  |-
  ?>  ?=(other-base-unit to.i.rem)
  =/  defin=(unit [to=si-base-unit factor=@rd])  (~(get by si-map) to.i.rem)
  =.  si-map
    ?~  defin
      si-map
    (~(put by si-map) from.i.rem [to.u.defin (mul:rd factor.i.rem factor.u.defin)])
  =.  new-rem
    ?~  defin
      [i.rem new-rem]
    new-rem
  ?~  t.rem
    ^$(rem new-rem)
  $(rem t.rem)
::  helpers for derived units used inside
::  of other derived units like energy = Nm
++  derived-units
  |%
  ++  newton
    ^-  (list [base=tinu pow=@s])
    ~[[[`%kilo %gram] --1] [`%metre --1] [`%second -2]]
  ++  dyne
    ^-  (list [base=tinu pow=@s])
    ~[[`%gram --1] [[`%centi %metre] --1] [`%second -2]]
  ++  joule
    ^-  (list [base=tinu pow=@s])
    ~[[[`%kilo %gram] --1] [`%metre --2] [`%second -2]]
  --
::  helpers for quantity specs used within
::  other specs
++  quantity-specs
  |%
  ++  force
    ^-  quantity-spec
    ~[[%gram --1] [%metre --1] [%second -2]]
  --
--
