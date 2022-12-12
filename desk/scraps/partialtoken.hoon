::Tokenizer
!:
|%
++  tokenizer-dfa
  |$  [state-type alphabet-type]
  $:  states=(set state-type)
      start=state-type
      alphabet=(set alphabet-type)
      accept=(set state-type)
      tm=(transition-map state-type alphabet-type)
      tml=(transition-map-list state-type alphabet-type)
      state=state-type
      buffer=(list alphabet-type)
  ==
::
++  transition-map
  |$  [state-type alphabet-type]
  (map (pair state-type alphabet-type) state-type)
::
++  transition-map-list
  |$  [state-type alphabet-type]
  (list (transition state-type alphabet-type))
::
++  token
  |$  [state-type alphabet-type]
  (pair state-type (list alphabet-type))
::
++  transition
  |$  [state-type alphabet-type]
  (pair (pair state-type alphabet-type) state-type)
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
      state=strt
      buffer=~
    ==
::
++  get-example
  |*  s=(set)
  =+  sl=~(tap in s)
  ?>(?=(^ sl) i.sl)
++  dfa
  =|  t-dfa=(tokenizer-dfa)
  |@
  ++  put-char
    |*  c=*
    ~
  --
--
