::Tokenizer
/-  *tokenizer
!:
=<
|%
::  ctor
::
++  make-dfa
  |*  [stats=(set) strt=* alpha=(set) accept=(set)]
  =+  state-example=(get-example stats)
  =+  alphabet-example=(get-example alpha)
  ^-  (tokenizer-dfa _state-example _alphabet-example)
  :*  states=stats
      start=strt
      alphabet=alpha
      accepting=accept
      tm=~
      tml=~
  ==
::  arm for dfa operations
++  dfa
  =|  t-dfa=(tokenizer-dfa)
  |@
  ::  used for casting
  ++  state-example  (get-example states.t-dfa)
  ++  alphabet-example  (get-example alphabet.t-dfa)
  ::  just dfa impl
  ::
  ++  tokenize
    |*  txt=(list)
    =|  tokens=(list (token _state-example _alphabet-example))
    ^+  tokens
    ::  text built up while transitioning
    ::  from state to state
    =|  buffer=(list _alphabet-example)
    ::  current state
    =/  state=_state-example  start.t-dfa
    |-
    ?~  txt
      ::  end of text, must be in accepting state
      ?>  (~(has in accepting.t-dfa) state)
      ::  buffer is prepended so flop
      [[state (flop buffer)] tokens]
    =/  c=_alphabet-example  i.txt
    ?>  (~(has in alphabet.t-dfa) c)
    ::  get transition or null if none exists
    =/  rhs=(unit _state-example)  (~(get by tm.t-dfa) [state c])
    =|  [new-tokens=_tokens new-state=_state new-buffer=_buffer]
    =.  -
      ?~  rhs
        ::  no transition
        ::  assert in accepting state
        ?>  (~(has in accepting.t-dfa) state)
        ::  do transition from start state using c
        [[[state (flop buffer)] tokens] (~(got by tm.t-dfa) [start.t-dfa c]) [c ~]]
      ::  transition
      ::  just update state and buffer
      [tokens u.rhs [c buffer]]
    ::  next char
    $(tokens new-tokens, state new-state, buffer new-buffer, txt t.txt)
  ::
  ::  add simple transition
  ::
  ++  add-transition
    |*  [from=* to=* c=*]
    ^-  (tokenizer-dfa _state-example _alphabet-example)
    =/  new-trans=(transition _state-example _alphabet-example)  [[from c] to]
    ~|  [from to c]
    ?>  (trans-is-valid t-dfa new-trans)
    =.  tml.t-dfa  [new-trans tml.t-dfa]
    t-dfa
  ::
  ::  add transitions for multiple chars
  ::
  ++  add-transition-list
    |*  [from=* to=* cs=(list *)]
    ^-  (tokenizer-dfa _state-example _alphabet-example)
    =/  new-trans=(transition-map-list _state-example _alphabet-example)  ~
    |-
    ?~  cs
      =.  tml.t-dfa  (weld tml.t-dfa new-trans)
      t-dfa
    =/  new-tran=(transition _state-example _alphabet-example)  [[from i.cs] to]
    ~!  .
    ?>  (trans-is-valid t-dfa new-tran)
    ~!  cs
    ~!  t.cs
    =/  new-cs=(list _alphabet-example)  `(list _alphabet-example)`t.cs
    $(new-trans [new-tran new-trans], cs new-cs)
  ::
  ::  compile transitions from list to map
  ::
  ++  compile-transitions
    ^-  (tokenizer-dfa _state-example _alphabet-example)
    =.  tm.t-dfa  (malt tml.t-dfa)
    t-dfa
  --
--
::
|@
::  get example element of set
::
++  get-example
  |*  s=(set)
  =+  sl=~(tap in s)
  ?>(?=(^ sl) i.sl)
::
::  make sure a transition is valid
::
++  trans-is-valid
  |*  [t-dfa=(tokenizer-dfa) new-trans=(transition)]
  ^-  ?
  ?&  (~(has in states.t-dfa) ?>(?=(^ new-trans) p.p.new-trans))
      (~(has in states.t-dfa) ?>(?=(^ new-trans) q.new-trans))
      (~(has in alphabet.t-dfa) ?>(?=(^ new-trans) q.p.new-trans))
  ==
--
