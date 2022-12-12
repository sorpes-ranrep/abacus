/-  *parser
/+  *parser
!:
=<
|=  tokens=(list (pair symbol tape))
::^-  (pt-node symbol tape)
^-  @rd
?>  (levy tokens |=(s=(pair symbol tape) (~(has in all-terminals) p.s)))
=/  prod-rules=(list (production-rule symbol))
  :~  [%expr ~[%term %after-term]]
      [%after-term ~[%plus %term %after-term]]
      [%after-term ~[%minus %term %after-term]]
      [%after-term ~]
      [%term ~[%factor %after-factor]]
      [%after-factor ~[%times %factor %after-factor]]
      [%after-factor ~[%divide %factor %after-factor]]
      [%after-factor ~]
      [%factor ~[%number]]
      [%factor ~[%lparen %expr %rparen]]
  ==
=/  g=(cfg symbol)  [all-terminals all-non-terminals prod-rules %expr]
=/  root-node=(pt-node symbol tape)  (parse g tokens)
(eval-e root-node)
|%
++  eval-e
  |=  n=(pt-node symbol tape)
  ^-  @rd
  ?>  ?=([%node *] n)
  ?~  children.n
    !!
  ?>  ?=([%node *] i.children.n)
  =/  t=@rd  (eval-t i.children.n)
  ?~  t.children.n
    !!
  ?>  ?=([%node *] i.t.children.n)
  =/  cmd=at-cmd  (eval-at i.t.children.n)
  |-
  ?~  cmd
    t
  ?-  -.cmd
    %plus   $(t (add:rd t t.cmd), cmd at.cmd)
    %minus  $(t (sub:rd t t.cmd), cmd at.cmd)
  ==
++  eval-at
  |=  n=(pt-node symbol tape)
  ^-  at-cmd
  ?>  ?=([%node *] n)
  ?~  children.n
    ~
  ?>  ?=([%leaf *] i.children.n)
  ?~  t.children.n
    !!
  ?~  t.t.children.n
    !!
  =/  t=@rd  (eval-t i.t.children.n)
  =/  cmd=at-cmd  $(n i.t.t.children.n)
  ?+  s.i.children.n  !!
    %plus   [%plus t cmd]
    %minus  [%minus t cmd]
  ==
++  eval-t
  |=  n=(pt-node symbol tape)
  ^-  @rd
  ?>  ?=([%node *] n)
  ?~  children.n
    !!
  ?>  ?=([%node *] i.children.n)
  =/  f=@rd  (eval-f i.children.n)
  ?~  t.children.n
    !!
  ?>  ?=([%node *] i.t.children.n)
  =/  cmd=af-cmd  (eval-af i.t.children.n)
  |-
  ?~  cmd
    f
  ?-  -.cmd
    %times   $(f (mul:rd f f.cmd), cmd af.cmd)
    %divide  $(f (div:rd f f.cmd), cmd af.cmd)
  ==
++  eval-af
  |=  n=(pt-node symbol tape)
  ^-  af-cmd
  ?>  ?=([%node *] n)
  ?~  children.n
    ~
  ?>  ?=([%leaf *] i.children.n)
  ?~  t.children.n
    !!
  ?~  t.t.children.n
    !!
  =/  f=@rd  (eval-f i.t.children.n)
  =/  cmd=af-cmd  $(n i.t.t.children.n)
  ?+  s.i.children.n  !!
    %times  [%times f cmd]
    %divide  [%divide f cmd]
  ==
++  eval-f
  |=  n=(pt-node symbol tape)
  ^-  @rd
  ?>  ?=([%node *] n)
  ?~  children.n
    !!
  ~|  rule.n
  ?+    rule.n  !!
      %8
    ?>  ?=([%leaf *] i.children.n)
    ?>  =(s.i.children.n %number)
    (scan ['~' b.i.children.n] royl-rd:so)
      %9
    ?>  ?=([%leaf *] i.children.n)
    ?>  =(s.i.children.n %lparen)
    ?~  t.children.n
      !!
    ?>  ?=([%node *] i.t.children.n)
    (eval-e i.t.children.n)
  ==
+$  symbol
  $?  ?(%number)
      ?(%plus %minus %times %divide)
      ?(%lparen %rparen)
      ?(%expr %term %factor %after-term %after-factor)
  ==
++  all-terminals
  ^-  (set symbol)
  (silt `(list symbol)`~[%number %plus %minus %times %divide %lparen %rparen])
++  all-non-terminals
  ^-  (set symbol)
  (silt `(list symbol)`~[%expr %term %factor %after-term %after-factor])
+$  af-cmd
  $@  ~
  $%  [%times f=@rd af=af-cmd]
      [%divide f=@rd af=af-cmd]
  ==
+$  at-cmd
  $@  ~
  $%  [%plus t=@rd at=at-cmd]
      [%minus t=@rd at=at-cmd]
  ==
--
