|%
++  cfg
  |$  [s-type]
  $:  terminals=(set s-type)
      non-terminals=(set s-type)
      prod-rules=(list (production-rule s-type))
      start=s-type
  ==
++  pt-node
  |$  [s-type b-type]
  $%  [%node rule=@ud children=(list (pt-node s-type b-type))]
      [%leaf s=s-type b=b-type]
  ==
++  predict-table
  |$  [s-type]
  (map (pair s-type (ext-sym s-type)) @ud)
++  production-rule
  |$  [s-type]
  (pair s-type (list s-type))
++  ext-sym
  |$  [s-type]
  $%  [%r s-type]  :: regular symbol
      [%e ~]       :: EOF/$ symbol
      [%n ~]       :: NULL symbol
  ==
--
