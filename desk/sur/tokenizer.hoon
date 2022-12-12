|%
++  tokenizer-dfa
  |$  [state-type alphabet-type]
  $:  states=(set state-type)
      start=state-type
      alphabet=(set alphabet-type)
      accepting=(set state-type)
      tm=(transition-map state-type alphabet-type)
      tml=(transition-map-list state-type alphabet-type)
    ==
++  transition-map
  |$  [state-type alphabet-type]
  (map (pair state-type alphabet-type) state-type)
++  transition-map-list
  |$  [state-type alphabet-type]
  (list (transition state-type alphabet-type))
++  token
  |$  [state-type alphabet-type]
  (pair state-type (list alphabet-type))
++  transition
  |$  [state-type alphabet-type]
  (pair (pair state-type alphabet-type) state-type)
--
