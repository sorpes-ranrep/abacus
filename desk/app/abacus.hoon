/-  abacus, *tokenizer, *parser, realm
/+  default-agent, dbug, abacus, *tokenizer, *parser, realm
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  %0
      g=(cfg symbol:abacus)
      t-dfa=(tokenizer-dfa token-state:abacus @tD)
      si-map=(map other-base-unit:abacus [to=si-base-unit:abacus factor=@rd])
      misc-map=(jar other-base-unit:abacus [to=other-base-unit:abacus factor=@rd])
      unit-types-list=(list (pair quantity:abacus [spec=quantity-spec:abacus types=(list unit-type:abacus)]))
      unit-types=(map quantity:abacus [spec=quantity-spec:abacus types=(list unit-type:abacus)])
  ==
+$  card  card:agent:gall
+$  my-token  (token token-state:abacus @tD)
++  simple-unit
  |=  [name=(unit @t) sym=(unit @t) base-unit=?(si-base-unit:abacus other-base-unit:abacus)]
  ^-  unit-type:abacus
  =+  ?~(name (crip (snoc (trip `@t`base-unit) 's')) u.name)
  :+  -
      ?~(sym - u.sym)
      [.~1 ~[[`base-unit --1]]]
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %.n) bowl)
::
++  on-init
  ^-  (quip card _this)
  =/  prod-rules=(list (production-rule symbol:abacus))
    :~  [%expr ~[%term %after-term]]
        [%after-term ~[%plus %term %after-term]]
        [%after-term ~[%minus %term %after-term]]
        [%after-term ~]
        [%term ~[%factor %after-factor]]
        [%after-factor ~[%times %factor %after-factor]]
        [%after-factor ~[%divide %factor %after-factor]]
        [%after-factor ~]
        [%factor ~[%number %after-number]]
        [%factor ~[%minus %number %after-number]]
        [%factor ~[%lparen %expr %rparen %after-number]]
        [%after-number ~[%percent]]
        [%after-number ~]
    ==
  =/  new-dfa=(tokenizer-dfa token-state:abacus @tD)  (make-dfa [all-states:abacus `token-state:abacus`%start all-chars:abacus accepting-states:abacus])
  =.  new-dfa  (~(add-transition-list dfa new-dfa) [from=%start to=%number cs=nz-dig-chars:abacus])
  =.  new-dfa  (~(add-transition-list dfa new-dfa) [from=%number to=%number cs=dig-chars:abacus])
  =.  new-dfa  (~(add-transition dfa new-dfa) [from=%number to=%decimal0 c='.'])
  =.  new-dfa  (~(add-transition dfa new-dfa) [from=%start to=%zero c='0'])
  =.  new-dfa  (~(add-transition dfa new-dfa) [from=%zero to=%decimal0 c='.'])
  =.  new-dfa  (~(add-transition-list dfa new-dfa) [from=%decimal0 to=%decimal cs=dig-chars:abacus])
  =.  new-dfa  (~(add-transition-list dfa new-dfa) [from=%decimal to=%decimal cs=dig-chars:abacus])
  =.  new-dfa  (~(add-transition-list dfa new-dfa) [from=%start to=%op cs=op-chars:abacus])
  =.  new-dfa  (~(add-transition dfa new-dfa) [from=%start to=%lparen c='('])
  =.  new-dfa  (~(add-transition dfa new-dfa) [from=%start to=%rparen c=')'])
  ::compile (create map from accumulated list)
  =.  new-dfa  ~(compile-transitions dfa new-dfa)
  ::make map of all to si-base... and then use put-conv for to other-base...?
  ::
  ::not sure which yet
  ::maybe these should be is misc?
  =/  base-year=other-base-unit:abacus  %gregorian-year
  =/  si-map-list=(list [from=other-base-unit:abacus to=?(other-base-unit:abacus si-base-unit:abacus) factor=@rd])
    :~
      ::time
      ::
      [%planck-time %second .~5.39e-44]
      [%jiffy-phys %second .~1e-24]
      [%svedberg %second .~1e-13]
      [%shake %second .~1e-8]
      [%jiffy-elec-50 %second (div:rd .~1 .~50)]
      [%jiffy-elec-60 %second (div:rd .~1 .~60)]
      [%minute %second .~60]
      [%hour %minute .~60]
      [%day %hour .~24]
      [%week %day .~7]
      [%fortnight %week .~2]
      [%quarantine %day .~40]
      [%semester %week .~18]
      [%lunar-year %day .~354.37]
      [%common-year %day .~365]
      [%leap-year %day .~366]
      [%tropical-year %second .~31556925.216]
      [%gregorian-year %second .~31556952]
      [%sidereal-year %second .~31558149.7635456]
      [%olympiad base-year .~4]
      [%lustrum base-year .~5]
      [%decade base-year .~10]
      [%indiction base-year .~15]
      [%jubilee base-year .~50]
      [%century base-year .~100]
      [%millennium base-year .~1000]
      ::length
      ::
      [%angostrom %metre (ryld `dn`[%d & (prefix-2-pow:abacus `%pico) 100])]
      [%myriametre %metre .~10000]
      [%x-unit %metre (ryld `dn`[%d & (dif:si (prefix-2-pow:abacus `%pico) --1) 1])]
      [%inch %metre .~0.0254]
      [%thou %inch .~0.001]
      [%foot %inch .~12]
      [%yard %foot .~3]
      [%mile %foot .~5280]
      [%league %mile .~3]
      [%fathom %yard .~2]
      [%nautical-mile %metre .~1852]
      [%chain %yard .~22]
      [%rod %yard .~5.5]
      [%earth-radius %metre .~6371000]
      [%lunar-distance %metre .~384402000]
      [%au %metre .~149597870700]
      [%light-year %metre .~9460730472580800]
      [%parsec %metre .~30856775814671900]
      [%hubble-length %light-year .~14400000000]
      [%electron-radius %metre (ryld `dn`[%d & -24 2.817.940.285])]
      [%compton-elec-wl %metre (ryld `dn`[%d & -21 2.426.310.215])]
      [%compton-elec-wl-reduced %metre (ryld `dn`[%d & -23 38.615.926.764])]
      [%hydrogen-radius %metre (ryld `dn`[%d & -20 5.291.772.083])]
      [%hydrogen-wl-reduced %metre (ryld `dn`[%d & -20 9.112.670.505.509])]
      [%planck-length %metre (ryld `dn`[%d & -41 1.616.255])]
      [%stoney %metre (ryld `dn`[%d & -38 1.381])]
      [%qcd %metre (ryld `dn`[%d & -19 2.103])]
      [%ev-length %metre (ryld `dn`[%d & -9 197])]
      [%football-field %yard .~100]
      [%human-hair %metre (ryld `dn`[%d & -5 8])]
      [%furlong %mile .~0.125]
      [%horse-length %foot .~8]
      ::mass
      ::
      ::maybe tonne should be an alias for mega-gram, maybe put-conv should
      ::accept a prefix
      [%pound %gram .~453.59237]
      [%tonne %gram .~1000000]
      [%ton-uk %gram .~1016047]
      [%ton-us %pound .~2000]
      [%electron-volt-mass %gram (ryld `dn`[%d & -41 178.266.192])]
      [%dalton %gram (ryld `dn`[%d & -26 166])]
      [%slug %gram .~14593.9]
      [%ounce %pound (div:rd .~1 .~16)]
      [%troy-ounce %gram .~31.1034768]
      [%planck-mass %gram .~0.00002176434]
      [%solar-mass %gram (ryld `dn`[%d & --38 198.847])]
      [%stone %pound .~14]
      ::
      ::current - just ampere for now
      ::
      ::temperature - only for degree size, regular conversions are separate
      ::as they don't fit the factor system used for other units
      ::
      [%celsius %kelvin .~1]
      [%fahrenheit %kelvin (div:rd .~5 .~9)]
      [%rankine %kelvin (div:rd .~5 .~9)]
      ::[%delisle %kelvin (div:rd .~2 .~3)]
      ::[%newton %kelvin (div:rd .~100 .~33)]
      ::[%reaumur %kelvin .~1.25]
      ::[%romer %kelvin (div:rd .~40 .~21)]
      ::amount of substance
      ::
      [%pound-mole %mole .~453.59237]
      ::luminosity - just candela for now
      ::
      ::data
      [%byte %bit .~8]
    ==
  =/  si-map=(map other-base-unit:abacus [to=si-base-unit:abacus factor=@rd])
    (make-si-map:abacus si-map-list)
  ::maybe abstract the idea of base-units?
  ::set/list of types with representative + alternatives converting to
  ::  the base
  ::have a normal one and one for relative times (base might be month?)
  ::
  =/  misc-map-list=(list (pair other-base-unit:abacus (list [to=other-base-unit:abacus factor=@rd])))
    :~  [%year ~[[to=%month factor=.~12]]]
    ==
  ::
  =/  unit-types-list=(list (pair quantity:abacus [quantity-spec:abacus (list unit-type:abacus)]))
    :~
      ::base quantities
      :+  %time  ~[[%second --1]]
        :~  (simple-unit `[`'s' %second])
            (simple-unit `[`'m' %minute])
            (simple-unit `[`'h' %hour])
            (simple-unit `[`'d' %day])
            (simple-unit `[`'w' %week])
            (simple-unit [`'planck times' `%planck-time])
            (simple-unit [`'jiffies (physics)' `%jiffy-phys])
            (simple-unit ``%svedberg)
            (simple-unit ``%shake)
            (simple-unit [`'jiffies (electronics; 1/50s)' `%jiffy-elec-50])
            (simple-unit [`'jiffies (electronics; 1/60s)' `%jiffy-elec-60])
            (simple-unit ``%fortnight)
            (simple-unit ``%quarantine)
            (simple-unit ``%semester)
            (simple-unit [`'lunar years' `%lunar-year])
            (simple-unit [`'common years' `%common-year])
            (simple-unit [`'leap years' `%leap-year])
            (simple-unit [`'gregorian years' `%gregorian-year])
            (simple-unit [`'tropical years' `%tropical-year])
            (simple-unit [`'sidereal years' `%sidereal-year])
            (simple-unit ``%olympiad)
            (simple-unit ``%lustrum)
            (simple-unit ``%decade)
            (simple-unit ``%indiction)
            (simple-unit ``%jubilee)
            (simple-unit ``%century)
            (simple-unit ``%millennium)
        ==
      :+  %length  ~[[%metre --1]]
        :~  (simple-unit `[`'m' %metre])
            ['centimetres' 'cm' [.~1 ~[[[`%centi %metre] --1]]]]
            ['millimetres' 'mm' [.~1 ~[[[`%milli %metre] --1]]]]
            ['kilometres' 'km' [.~1 ~[[[`%kilo %metre] --1]]]]
            (simple-unit `[`'Å' %angostrom])
            (simple-unit ``%myriametre)
            (simple-unit [`'x units' `'xu' %x-unit])
            (simple-unit `[`'in' %inch])
            (simple-unit ``%thou)
            (simple-unit [`'feet' `'ft' %foot])
            (simple-unit `[`'yd' %yard])
            (simple-unit ``%mile)
            (simple-unit ``%league)
            (simple-unit ``%fathom)
            (simple-unit [`'nautical miles' `'NM' %nautical-mile])
            (simple-unit ``%chain)
            (simple-unit ``%rod)
            (simple-unit [`'earth radii' `%earth-radius])
            (simple-unit [`'lunar distances' `'LD' %lunar-distance])
            (simple-unit [`'astronomical units' `'au' %au])
            (simple-unit [`'light-years' `'ly' %light-year])
            (simple-unit `[`'pc' %parsec])
            (simple-unit [`'hubble lengths' `%hubble-length])
            (simple-unit [`'electron radii' `'re' %electron-radius])
            (simple-unit [`'electron wavelengths' `'λC' %compton-elec-wl])
            (simple-unit [`'reduced electron wavelengths' `'rλC' %compton-elec-wl-reduced])
            (simple-unit [`'hydrogen radii' `'a0' %hydrogen-radius])
            (simple-unit [`'reduced hydrogen wavelengths' `'1/R∞' %hydrogen-wl-reduced])
            (simple-unit [`'planck lengths' `'𝓁P' %planck-length])
            (simple-unit [`'stonies' `'lS' %stoney])
            (simple-unit [`'quantum chromodynamics lengths' `'qcd' %qcd])
            (simple-unit [`'electron volt lengths' `'1/eV' %ev-length])
            (simple-unit [`'football fields' `%football-field])
            (simple-unit [`'human hairs' `%human-hair])
            (simple-unit ``%furlong)
            (simple-unit [`'horse lengths' `%horse-length])
        ==
      :+  %mass  ~[[%gram --1]]
        :~  (simple-unit `[`'g' %gram])
            ['kilograms' 'kg' [.~1 ~[[[`%kilo %gram] --1]]]]
            (simple-unit `[`'lb' %pound])
            (simple-unit `[`'t' %tonne])
            (simple-unit [`'tons (uk)' `%ton-uk])
            (simple-unit [`'tons (us)' `%ton-us])
            (simple-unit [`'electron volt masses' `'eV/c2' %electron-volt-mass])
            (simple-unit `[`'Da' %dalton])
            (simple-unit `[`'sl' %slug])
            (simple-unit `[`'oz' %ounce])
            (simple-unit [`'troy ounces' `%troy-ounce])
            (simple-unit [`'planck masses' `%planck-mass])
            (simple-unit [`'solar masses' `'M☉' %solar-mass])
            (simple-unit `[`'st' %stone])
        ==
      :+  %current  ~[[%ampere --1]]
        :~  (simple-unit `[`'A' %ampere])
        ==
      :+  %temperature  ~[[%kelvin --1]]
        :~  (simple-unit [`'degrees kelvin' `'K' %kelvin])
            (simple-unit [`'degrees celsius' `'°C' %celsius])
            (simple-unit [`'degrees fahrenheit' `'°F' %fahrenheit])
            (simple-unit [`'degrees rankine' `'°R' %rankine])
            ::(simple-unit `[`'°De' %delisle])
            ::(simple-unit `[`'°N' %newton])
            ::(simple-unit [`'réaumur' `'°Ré' %reaumur])
            ::(simple-unit [`'rømer' `'°Rø' %romer])
        ==
      :+  %amount-of-substance  ~[[%mole --1]]
        :~  (simple-unit `[`'mol' %mole])
            (simple-unit `[`'lb-mol' %pound-mole])
        ==
      :+  %luminosity  ~[[%candela --1]]
        :~  (simple-unit `[`'cd' %candela])
        ==
      :+  %data  ~[[%bit --1]]
        :~  (simple-unit ``%bit)
            ['bytes' 'b' [.~1 ~[[`%byte --1]]]]
            ['kilobytes' 'KB' [.~1024 ~[[`%byte --1]]]]
            ['megabytes' 'MB' [.~1048576 ~[[`%byte --1]]]]
            ['gigabytes' 'GB' [.~1073741824 ~[[`%byte --1]]]]
            ['terabytes' 'TB' [.~1099511627776 ~[[`%byte --1]]]]
        ==
      :+  %area  ~[[%metre --2]]
        :~  ['acres' 'ac' [.~4840 ~[[`%foot --2]]]]
            ['ares' 'a' [.~100 ~[[`%metre --2]]]]
            ['hectares' 'ha' [.~10000 ~[[`%metre --2]]]]
            ['square centimetres' 'cm2' [.~1 ~[[[`%centi %metre] --2]]]]
            ['square feet' 'ft2' [.~1 ~[[`%foot --2]]]]
            ['square inches' 'in2' [.~1 ~[[`%inch --2]]]]
            ['square metres' 'm2' [.~1 ~[[`%metre --2]]]]
        ==
      :+  %volume  ~[[%metre --3]]
        :~  ['us gallons' 'gal' [.~231 ~[[`%inch --3]]]]
            ['uk gallons' 'gal' [.~4.54609 ~[[[`%deci %metre] --3]]]]
            ['litres' 'l' [.~1 ~[[[`%deci %metre] --3]]]]
            ['millilitres' 'ml' [.~1 ~[[[`%centi %metre] --3]]]]
            ['cubic centimetres' 'cm3' [.~1 ~[[[`%centi %metre] --3]]]]
            ['cubic metres' 'm3' [.~1 ~[[`%metre --3]]]]
            ['cubic inches' 'in3' [.~1 ~[[`%inch --3]]]]
            ['cubic feet' 'ft3' [.~1 ~[[`%foot --3]]]]
        ==
      ::
      :+  %speed  ~[[%metre --1] [%second -1]]
        :~  ['metres per second' 'm/s' [.~1 ~[[`%metre --1] [`%second -1]]]]
            ['metres per hour' 'm/h' [.~1 ~[[`%metre --1] [`%hour -1]]]]
            ['kilometres per second' 'km/s' [.~1 ~[[[`%kilo %metre] --1] [`%second -1]]]]
            ['kilometres per hour' 'km/h' [.~1 ~[[[`%kilo %metre] --1] [`%hour -1]]]]
            ['inches per second' 'in/s' [.~1 ~[[`%inch --1] [`%second -1]]]]
            ['inches per hour' 'in/h' [.~1 ~[[`%inch --1] [`%hour -1]]]]
            ['feet per second' 'ft/s' [.~1 ~[[`%foot --1] [`%second -1]]]]
            ['feet per hour' 'ft/h' [.~1 ~[[`%foot --1] [`%hour -1]]]]
            ['miles per second' 'mi/s' [.~1 ~[[`%mile --1] [`%second -1]]]]
            ['miles per hour' 'mi/h' [.~1 ~[[`%mile --1] [`%hour -1]]]]
            ['knots' 'kn' [.~1 ~[[`%nautical-mile --1] [`%hour -1]]]]
        ==
      ::
      :+  %frequency  ~[[%second -1]]
        :~  ['hertz' 'hz' [.~1 ~[[`%second -1]]]]
            ['rpm' 'rpm' [.~1 ~[[`%minute -1]]]]
        ==
      :+  %angle  ~
        :~  ['radians' 'rad' [.~1 ~]]
            ['degrees' 'deg' [(div:rd .~6.2831853071 .~360) ~]]
        ==
      :::+  %solid-angle
      :+  %force  force:quantity-specs:abacus
        :~  ['newtons' 'N' [.~1 newton:derived-units:abacus]]
            ['dynes' 'dyn' [.~1 dyne:derived-units:abacus]]
            ['kiloponds' 'kp' [.~9.80665 newton:derived-units:abacus]]
            ['pound-forces' 'lbf' [.~4.448222 newton:derived-units:abacus]]
            ['poundals' 'pdl' [.~1 ~[[`%pound --1] [`%foot --1] [`%second -2]]]]
        ==
      :+  %pressure  [[%metre -2] force:quantity-specs:abacus]
        :~  ['pascals' 'Pa' [.~1 [[`%metre -2] newton:derived-units:abacus]]]
            ['baryes' 'Ba' [.~1 [[[`%centi %metre] -2] dyne:derived-units:abacus]]]
            ::maybe use special char for superscript? can render on
            ::front end
            ['pounds per sq. in.' 'lbf/in2' [.~4.448222 [[`%inch -2] newton:derived-units:abacus]]]
            ['bars' 'bar' [.~100000 [[`%metre -2] newton:derived-units:abacus]]]
            ['standard atmospheres' 'atm' [.~101325 [[`%metre -2] newton:derived-units:abacus]]]
            ['technical atmospheres' 'at' [.~98066.5 [[`%metre -2] newton:derived-units:abacus]]]
        ==
      :+  %energy  ~[[%gram --1] [%metre --2] [%second -2]]
        :~  ['joules' 'J' [.~1 joule:derived-units:abacus]]
            ['kilowatt hours' 'kWh' [.~3600000 joule:derived-units:abacus]]
            ::BTU has several definitions...

        ==
    ==
  ::
  :-  ~
  %=  this
    g  [all-terminals:abacus all-non-terminals:abacus prod-rules %expr]
    t-dfa  new-dfa
    si-map  si-map
    misc-map  (malt misc-map-list)
    unit-types-list  unit-types-list
    unit-types  (malt unit-types-list)
  ==
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
    %0  `this(state old)
  ==
::
++  on-poke
  |=  [=mark =vase]
  (on-poke:def mark vase)
  ::^-  (quip card _this)
  ::|^
  ::?>  =(src.bowl our.bowl)
  ::?+    mark  (on-poke:def mark vase)
  ::    %abacus-action
  ::  =^  cards  state
  ::    (handle-poke !<(action:abacus vase))
  ::  [cards this]
  ::==
  ::::
  ::++  handle-poke
  ::  |=  =action:abacus
  ::  ^-  (quip card _state)
  ::  ?-    -.action
  ::      %eval
  ::    [~ state]
  ::  ==
  ::--
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
    ::main calculator logic,
    ::tokenize input
    ::prepare tokens to be parsed
    ::parse tokens into a parse tree
    ::recursively evaluate tree
    ::
      [%x %eval @ ~]
    =/  text=tape  (trip i.t.t.path)
    =/  tokens=(list my-token)  (~(tokenize dfa t-dfa) text)
    =|  clean-tokens=(list (pair symbol:abacus tape))
    =.  clean-tokens
      |-
      ?~  tokens
        clean-tokens
      =/  term=symbol:abacus
        ?+  p.i.tokens  !!
          %number       %number
          %decimal      %number
          %zero         %number
          %op   ?~
              q.i.tokens
            !!
          ?+  i.q.i.tokens  !!
            %'+'           %plus
            %'-'           %minus
            %'*'           %times
            %'x'           %times
            %'/'           %divide
            %'%'           %percent
          ==
          %lparen         %lparen
          %rparen         %rparen
        ==
      $(clean-tokens [[term q.i.tokens] clean-tokens], tokens t.tokens)
    =/  root-node=(pt-node symbol:abacus tape)  (parse g clean-tokens)
    :^  ~  ~  %abacus-update
    !>  ^-  update:abacus
    [%answer (eval-e:abacus root-node)]
    ::main conversion logic
    ::just a fancy call to convert-derived-unit
    ::
      [%x %convert @ @ @ @ ~]
    ~|  path
    =/  qnt-tas=@tas  i.t.t.path
    =/  qnt=quantity:abacus  ?>(?=(quantity:abacus qnt-tas) qnt-tas)
    =/  amount=@rd  (slav %rd i.t.t.t.path)
    =/  from-name=@t  i.t.t.t.t.path
    =/  to-name=@t  i.t.t.t.t.t.path
    =/  types=(list unit-type:abacus)  types:(~(got by unit-types) qnt)
    =/  from-types=_types  (skim types |=(ut=unit-type:abacus =(name.ut from-name)))
    =/  to-types=_types  (skim types |=(ut=unit-type:abacus =(name.ut to-name)))
    =/  from-unit=derived-unit:abacus  ?~(from-types !! ?~(t.from-types du.i.from-types !!))
    =/  to-unit=derived-unit:abacus  ?~(to-types !! ?~(t.to-types du.i.to-types !!))
    :^  ~  ~  %abacus-update
    !>  ^-  update:abacus
    [%answer (convert-derived-unit:abacus amount from-unit to-unit si-map misc-map)]
    ::get all unit types
    ::
      [%x %units ~]
    :^  ~  ~  %abacus-update
    !>  ^-  update:abacus
    [%unit-types `(list @t)`(turn unit-types-list |=((pair quantity:abacus [quantity-spec:abacus (list unit-type:abacus)]) p))]
    ::get all units of a type; e.g. speed, area, temperature
    ::
      [%x %units @ ~]
    =/  qnt-tas=@tas  i.t.t.path
    =/  qnt=quantity:abacus  ?>(?=(quantity:abacus qnt-tas) qnt-tas)
    :^  ~  ~  %abacus-update
    !>  ^-  update:abacus
    [%units-of-type (turn types:(~(got by unit-types) qnt) |=(ut=unit-type:abacus [name=name.ut symbol=sym.ut]))]
    ::debugging
    ::
      [%x %test ~]
    :^  ~  ~  %abacus-update
    !>  ^-  update:abacus
    [%answer (convert-derived-unit:abacus .~1 `derived-unit:abacus`[.~1 ~[[`%metre --1] [`%second -1]]] `derived-unit:abacus`[.~1 ~[[[`%milli %metre] --1] [`%hour -1]]] si-map misc-map)]
  ==
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
