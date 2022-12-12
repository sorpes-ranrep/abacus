!:
|=  text=tape
=<
=/  tm=transitionmap  transitions
=/  st=state  %start
=/  tokens=(list token)  ~
=/  buffer=tape  ~
|-
^-  [(list [terminal tape]) (list production-rule)]
?~  text
  =.  tokens  (flop [[(need (accept [st (flop buffer)])) (flop buffer)] tokens])
  [tokens (remove-unit-productions production-rules)]
=/  rhs=(unit state)  (~(get by tm) [st i.text])
=/  newvals  ?~  rhs
  [nextstate=%start bffr=~ tkns=[[(need (accept [st (flop buffer)])) (flop buffer)] tokens] txt=text]
[nextstate=u.rhs bffr=[i.text buffer] tkns=tokens txt=t.text]
$(st nextstate.newvals, buffer bffr.newvals, tokens tkns.newvals, text txt.newvals)
=>
::Common
|%
  +$  terminal           ?(%number %id %frac %unit %plus %minus %times %divide %exponent %lparen %rparen)
  +$  token              (pair terminal tape)
--
::Tokenizer
:-
|%
  +$  state              ?(%start %onedigit %twodigits %wholenumber %tsep1 %tsep2 %tsep3 %dsep %decimalnumber %op %id0 %id %cmdescape %cmd0 %cmd %cmdlbrace %cmdrbrace0 %cmdrbrace %cmdarg %cmdargsep %lparen %rparen)
  +$  transitionmaplist  (list (pair (pair state @t) state))
  +$  transitionmap      (map (pair state @t) state)
  ::::
  ::::
  ++  transitions
    ^-  transitionmap
    ::all transition rules
    ::
    =/  tm=transitionmaplist  ~
    ::number rules
    ::
    =.  tm  (add-non-zero-transitions [%start %onedigit tm])
    =.  tm  (add-digit-transitions [%onedigit %twodigits tm])
    =.  tm  (add-digit-transitions [%twodigits %wholenumber tm])
    =.  tm  [[[%onedigit thousandsseparator] %tsep1] tm]
    =.  tm  [[[%twodigits thousandsseparator] %tsep1] tm]
    =.  tm  [[[%wholenumber thousandsseparator] %tsep1] tm]
    =.  tm  (add-digit-transitions [%tsep1 %tsep2 tm])
    =.  tm  (add-digit-transitions [%tsep2 %tsep3 tm])
    =.  tm  (add-digit-transitions [%tsep3 %wholenumber tm])
    =.  tm  [[[%onedigit decimalseparator] %dsep] tm]
    =.  tm  [[[%twodigits decimalseparator] %dsep] tm]
    =.  tm  [[[%wholenumber decimalseparator] %dsep] tm]
    =.  tm  (add-digit-transitions [%dsep %decimalnumber tm])
    =.  tm  (add-digit-transitions [%decimalnumber %decimalnumber tm])
    ::operator rules
    ::
    =.  tm  [[[%start '+'] %op] tm]
    =.  tm  [[[%start '-'] %op] tm]
    =.  tm  [[[%start '*'] %op] tm]
    =.  tm  [[[%start '/'] %op] tm]
    =.  tm  [[[%start '^'] %op] tm]
    ::parens
    ::
    =.  tm  [[[%start '('] %lparen] tm]
    =.  tm  [[[%start ')'] %rparen] tm]
    ::id rules
    ::ids are for constants and function names
    ::
    ::first character must be a letter
    =.  tm  (add-alpha-transitions [%start %id0 tm])
    ::subsequent may be a letter or a digit
    =.  tm  (add-all-transitions [%id0 %id tm])
    =.  tm  (add-all-transitions [%id %id tm])
    ::commands, special sequences for fractions, units, maybe other
    ::stuff later
    ::commands are denoted by the \ prefix
    ::
    =.  tm  [[[%start '\\'] %cmdescape] tm]
    ::first character must be a letter
    ::
    =.  tm  (add-alpha-transitions [%cmdescape %cmd0 tm])
    ::subsequent may be a letter or a digit
    ::
    =.  tm  (add-all-transitions [%cmd0 %cmd tm])
    =.  tm  (add-all-transitions [%cmd %cmd tm])
    =.  tm  [[[%cmd0 '{'] %cmdlbrace] tm]
    =.  tm  [[[%cmd '{'] %cmdlbrace] tm]
    =.  tm  (add-all-transitions [%cmdlbrace %cmdarg tm])
    =.  tm  (add-all-transitions [%cmdarg %cmdarg tm])
    =.  tm  [[[%cmdarg ','] %cmdargsep] tm]
    =.  tm  (add-all-transitions [%cmdargsep %cmdarg tm])
    =.  tm  [[[%cmdlbrace '/'] %cmdrbrace0] tm]
    =.  tm  [[[%cmdarg '/'] %cmdrbrace0] tm]
    =.  tm  [[[%cmdrbrace0 '}'] %cmdrbrace] tm]
    (malt tm)
  ++  add-transitions-for-range
    |=  [from=state to=state b=@t e=@t tm=transitionmaplist]
    ^-  transitionmaplist
    |-
    ?:  (gth b e)
      tm
    $(b `@t`(add b 1), tm [[[from b] to] tm])
  ++  accept
    |=  [st=state buffer=tape]
    ^-  (unit terminal)
    ?+  st  ~
      %onedigit       (some %number)
      %twodigits      (some %number)
      %wholenumber    (some %number)
      %decimalnumber  (some %number)
      %op   ?~
          buffer
        !!
      ?+  i.buffer  ~
        %'+'           (some %plus)
        %'-'           (some %minus)
        %'*'           (some %times)
        %'/'           (some %divide)
        %'^'           (some %exponent)
      ==
      %lparen         (some %lparen)
      %rparen         (some %rparen)
      %id0            (some %id)
      %id             (some %id)
      %cmdrbrace    ?~  buffer
                      !!
                    =+  (trim 4 t.buffer)
                    ?:  =(p "frac")
                      (some %frac)
                    ?:  =(p "unit")
                      (some %unit)
                    !!
    ==
  ++  add-digit-transitions
    |=  [from=state to=state tm=transitionmaplist]
    ^-  transitionmaplist
    (add-transitions-for-range [from to '0' '9' tm])
  ++  add-non-zero-transitions
    |=  [from=state to=state tm=transitionmaplist]
    ^-  transitionmaplist
    (add-transitions-for-range [from to '1' '9' tm])
  ++  add-alpha-transitions
    |=  [from=state to=state tm=transitionmaplist]
    ^-  transitionmaplist
    =.  tm  (add-transitions-for-range [from to 'a' 'z' tm])
    (add-transitions-for-range [from to 'A' 'Z' tm])
  ++  add-all-transitions
    |=  in=[from=state to=state tm=transitionmaplist]
    ^-  transitionmaplist
    =.  tm.in  (add-digit-transitions in)
    (add-alpha-transitions in)
  ++  thousandsseparator  ','
  ++  decimalseparator    '.'
--
::::Parser
|%
  +$  non-terminal     ?(%expr %term %factor %literal)
  +$  production-rule  [lhs=non-terminal rhs=(list ?(non-terminal terminal))]
  +$  predict-table    (map (pair non-terminal terminal) production-rule)
  ::+$  parse-tree-node  [prod-rule=production-rule val=tape child-nodes=(list parse-tree-node)]
  ++  production-rules
    ^-  (list production-rule)
    :~  [%expr [%id %lparen %expr %rparen ~]]
        [%expr [%expr %plus %term ~]]
        [%expr [%expr %minus %term ~]]
        [%expr [%term ~]]
        [%term [%term %times %factor ~]]
        [%term [%term %divide %factor ~]]
        [%term [%factor ~]]
        [%factor [%literal ~]]
        [%factor [%minus %literal ~]]
        [%factor [%unit ~]]
        [%factor [%lparen %expr %rparen ~]]
        [%factor [%factor %exponent %lparen %expr %rparen ~]]
        [%factor [%factor %exponent %literal ~]]
        [%literal [%number ~]]
        [%literal [%id ~]]
        [%literal [%frac ~]]
    ==
  ++  make-predict-table
    |=  prod-rules=(list production-rule)
    ^-  predict-table
    =/  entries=(list (pair (pair non-terminal terminal) production-rule))  ~
    |-
    ?~  prod-rules
      (malt entries)
    =/  new-entries
      ?~  rhs.i.prod-rules
        entries
      ?:  ?=(terminal i.rhs.i.prod-rules)
        [[[lhs.i.prod-rules i.rhs.i.prod-rules] i.prod-rules] entries]
      entries
    $(entries new-entries, prod-rules t.prod-rules)
  ++  parse-tokens
    |=  [text=(list token) pt=predict-table]
    ^-  (list production-rule)
    =/  symbol-stack=(list ?(non-terminal terminal))  ~[%expr]
    =/  derivation=(list production-rule)  ~
    |-
    ?~  symbol-stack
      (flop derivation)
    =/  newvalues
      ?~  text
        ~&  "no input"
        !!
      ?:  ?=(terminal i.symbol-stack)
        ?:  =(p.i.text i.symbol-stack)
          [txt=t.text sym-stk=t.symbol-stack deriv=derivation]
        ~&  "input didn't match"
        !!
      ~&  [i.symbol-stack p.i.text]
      =/  predicted-rule  (need (~(get by pt) [i.symbol-stack p.i.text]))
      [txt=text sym-stk=(weld rhs.predicted-rule t.symbol-stack) deriv=[predicted-rule derivation]]
    $(text txt.newvalues, symbol-stack sym-stk.newvalues, derivation deriv.newvalues)
  ++  remove-unit-productions
    |=  prod-rules=(list production-rule)
    ^-  (list production-rule)
    =/  all-terminal-copy  prod-rules
    =/  prod-rhs=(set non-terminal)  ~
    ::find all non-terminals which can become all terminals
    =.  prod-rhs
      |-
      ?~  all-terminal-copy
        prod-rhs
      =/  new-rhs=(set non-terminal)  prod-rhs
      =?  new-rhs  (levy rhs.i.all-terminal-copy is-terminal)
        (~(put in new-rhs) lhs.i.all-terminal-copy)
      $(prod-rhs new-rhs, all-terminal-copy t.all-terminal-copy)
    ~&  [%prod-rhs prod-rhs]
    =/  all-remaining-prod-rules=(list production-rule)  prod-rules
    =/  added-rules=(list production-rule)  ~
    ::replace rules like A->B with A->(list terminal) where exists
    ::B->(list terminal), B in prod-rhs.
    ::Remove Bs from, add As to prod-rhs (do things in the human order)
    |-
    ?~  prod-rhs
      (weld all-remaining-prod-rules added-rules)
    =/  split-rules=[unit-prod-rules=(list production-rule) remaining-prod-rules=(list production-rule)]  [~ ~]
    ::find unit productions
    =.  split-rules
      |-
      ?~  all-remaining-prod-rules
        split-rules
      =/  new-split-rules  split-rules
      =/  is-unit-production=?
        ?~  rhs.i.all-remaining-prod-rules
          %.n
        =/  nt=(unit non-terminal)
          (get-non-terminal i.rhs.i.all-remaining-prod-rules)
        ?~  nt
          %.n
        ?&  (~(has in `(set non-terminal)`prod-rhs) u.nt)
            =(t.rhs.i.all-remaining-prod-rules ~)
        ==
      =?  unit-prod-rules.new-split-rules  is-unit-production
        [i.all-remaining-prod-rules unit-prod-rules.split-rules]
      =?  remaining-prod-rules.new-split-rules  is-unit-production
        [i.all-remaining-prod-rules remaining-prod-rules.split-rules]
      $(split-rules new-split-rules, all-remaining-prod-rules t.all-remaining-prod-rules)
    ::iterate over unit-prod-rules and remaining-prod-rules to add
    ::replacements
    ~&  [%split-rules split-rules]
    =/  new-arguments=[new-rhs=(set non-terminal) new-rules=(list production-rule)]  [~ ~]
    =.  new-arguments
      |-
      ?~  unit-prod-rules.split-rules
        new-arguments
      ~&  [%current-unit-prod-rule i.unit-prod-rules.split-rules]
      =/  rem-prod-rules-copy  remaining-prod-rules.split-rules
      |-
      ?~  rem-prod-rules-copy
        ^$(unit-prod-rules.split-rules t.unit-prod-rules.split-rules)
      =?  new-arguments  ?~(rhs.i.unit-prod-rules.split-rules %.n &(=(lhs.i.rem-prod-rules-copy i.rhs.i.unit-prod-rules.split-rules) (levy rhs.i.rem-prod-rules-copy is-terminal)))
        :-  ~&  lhs.i.rem-prod-rules-copy  (~(put in new-rhs.new-arguments) lhs.i.rem-prod-rules-copy)
            =/  direct-rule  i.rem-prod-rules-copy
            =.  lhs.direct-rule  lhs.i.unit-prod-rules.split-rules
            [direct-rule new-rules.new-arguments]
      $(rem-prod-rules-copy t.rem-prod-rules-copy)
    $(prod-rhs new-rhs.new-arguments, added-rules (weld added-rules new-rules.new-arguments), all-remaining-prod-rules remaining-prod-rules.split-rules)
  ++  is-terminal  |=(r=?(non-terminal terminal) ?=(terminal r))
  ++  get-non-terminal
    |=  sym=?(non-terminal terminal)
    ^-  (unit non-terminal)
    ?+  sym  ~
      %expr  (some %expr)
      %term  (some %term)
      %factor  (some %factor)
      %literal  (some %literal)
    ==
--
