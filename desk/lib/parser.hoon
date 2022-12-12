::Parser
/-  *parser
!:
=<
|@
::  ll(1) bottom up parsing impl.
::
++  parse
  |*  [g=(cfg) tkns=(list (pair))]
  ::  return a pt-node i.e. a parse-tree
  ^-  (pt-node _(t-example g) _q:(get-list-example tkns))
  ::  predict table, maps the first non-terminal
  ::  of a partial derivation and the first token
  ::  of the corresponding string to a production rule
  =/  pt=(predict-table _(t-example g))  (make-pt g)
  ::  partial derivation in stack form
  =/  sym-stack=(list _(t-example g))  (ly [start.g ~])
  ::  derivation in the form of list of production rules
  =|  deriv=(list @ud)
  =+  p=(get-list-example tkns)
  ::~!  p
  ::  separate symbols from buffers
  ::  also convert symbols to ext-sym, a head-tagged union
  ::  to allow for NULL and EOF/$(end of string) symbols
  =|  [tokens=(list (ext-sym _(t-example g))) buffers=(list _q:(get-list-example tkns))]
  =.  -
    |-
    ?~  tkns
      [tokens (flop buffers)]
    $(tokens [[%r p.i.tkns] tokens], buffers [q.i.tkns buffers], tkns t.tkns)
  ::  append EOF to tokens
  =.  tokens
    (flop `(list (ext-sym _(t-example g)))`[[%e ~] tokens])
  ::  get derivation
  =.  deriv
    |-
    ?~  sym-stack
      ::  sym-stack is empty
      ::  done so long as tokens are
      ::  empty too
      ?:  =(tokens (ly [[%e ~] ~]))
        (flop deriv)
      ::~&  tokens
      !!
    ::  too many tokens, invalid string
    ?~  tokens
      ::~&  sym-stack
      !!
    ::  non-terminal case; use predict-table to replace
    ::  the symbol
    ?:  (~(has in non-terminals.g) i.sym-stack)
      =/  rule-idx-u=(unit @ud)  (~(get by pt) [i.sym-stack i.tokens])
      =/  rule-idx=@ud
        ?~  rule-idx-u
          ::~&  [i.sym-stack i.tokens]
          !!
        u.rule-idx-u
      =/  rhs=(list _(t-example g))  (flop q:(snag rule-idx prod-rules.g))
      =/  new-sym-stack=(list _(t-example g))  t.sym-stack
      =.  new-sym-stack
        |-
        ?~  rhs
          new-sym-stack
        $(new-sym-stack [i.rhs new-sym-stack], rhs t.rhs)
      $(sym-stack new-sym-stack, deriv [rule-idx deriv])
    ::  terminal case, just pop the symbol
    ?:  (~(has in terminals.g) i.sym-stack)
      ?>  =(i.sym-stack ?>(?=([%r *] i.tokens) +.i.tokens))
      $(sym-stack t.sym-stack, tokens t.tokens)
    !!
  :: build parse-tree from deriv
  =|  layers=(jar @ud (pt-node _(t-example g) _q:(get-list-example tkns)))
  =.  layers
    =/  cur-layer=(list (pair _(t-example g) @ud))  (ly [[start.g 0] ~])
    |-
    ?~  cur-layer
      layers
    =/  sym=(pair _(t-example g) @ud)  i.cur-layer
    ?:  (~(has in non-terminals.g) p.sym)
      ?~  deriv
        !!
      :: add kids
      =/  rule-idx=@ud  i.deriv
      =/  rule=(production-rule _(t-example g))  (snag rule-idx prod-rules.g)
      =/  reverse-kids=(list _(t-example g))  (flop q.rule)
      %=  $
        deriv      t.deriv
        cur-layer  |-(?~(reverse-kids t.cur-layer $(t.cur-layer [[i.reverse-kids +(q.sym)] t.cur-layer], reverse-kids t.reverse-kids)))
        layers     (~(add ja layers) q.sym [%node rule-idx ~])
      ==
    ?:  (~(has in terminals.g) p.sym)
      ?~  buffers
        !!
      $(layers (~(add ja layers) q.sym [%leaf p.sym i.buffers]), cur-layer t.cur-layer, buffers t.buffers)
    !!
  =|  layers-list=(list (list (pt-node _(t-example g) _q:(get-list-example tkns))))
  =.  layers-list
    =/  n=@ud  ~(wyt in ~(key by layers))
    =/  c=@ud  0
    |-
    ?:  (gte c n)
      layers-list
    =/  new-list=(list (pt-node _(t-example g) _q:(get-list-example tkns)))  (~(get ja layers) c)
    $(layers-list [new-list layers-list], c +(c))
  ?~  layers-list
    !!
  =/  cur-layer=(list (pt-node _(t-example g) _q:(get-list-example tkns)))  i.layers-list
  =+  rem-layers=t.layers-list
  |-
  ?~  rem-layers
    ?~  cur-layer
      !!
    ?>  =((lent cur-layer) 1)
    i.cur-layer
  =|  new-layer=(list (pt-node _(t-example g) _q:(get-list-example tkns)))
  |-
  ?~  i.rem-layers
    ^$(cur-layer (flop new-layer), rem-layers t.rem-layers)
  ?:  ?=([%node *] i.i.rem-layers)
    =/  n=@ud  (lent q:(snag rule.i.i.rem-layers prod-rules.g))
    |-
    ?:  =(n 0)
      ^$(i.rem-layers t.i.rem-layers, new-layer [i.i.rem-layers new-layer])
    ?~  cur-layer
      !!
    $(children.i.i.rem-layers [i.cur-layer children.i.i.rem-layers], cur-layer t.cur-layer, n (sub n 1))
  ?:  ?=([%leaf *] i.i.rem-layers)
    $(i.rem-layers t.i.rem-layers, new-layer [i.i.rem-layers new-layer])
  !!
--
::
|@
++  get-example
  |*  s=(set)
  =+  sl=~(tap in s)
  ?>(?=(^ sl) i.sl)
::
++  get-list-example
  |*  l=(list)
  ?>(?=(^ l) i.l)
::
++  t-example
  |*  g=(cfg)
  (get-example terminals.g)
::
++  nt-example
  |*  g=(cfg)
  (get-example non-terminals.g)
::
++  make-pt
  =<
  |*  g=(cfg)
  ^-  (predict-table _(t-example g))
  =/  first-sets=(jug _(nt-example g) _(t-example g))  (make-first-sets g)
  =/  nullable=(set _(t-example g))  (make-nullable g)
  =/  follow-sets=(jug _(nt-example g) (ext-sym _(t-example g)))  (make-follow-sets g first-sets nullable)
  =|  pt=(predict-table _(t-example g))
  =/  c=@ud  0
  =|  first-set=(set (ext-sym _(t-example g)))
  |-
  ?~  prod-rules.g
    pt
  =.  first-set
    (first q.i.prod-rules.g first-sets nullable)
  =?  first-set  (~(has in first-set) [%n ~])
    (~(gut by follow-sets) p.i.prod-rules.g ~)
  =/  first-list=(list (ext-sym _(t-example g)))
    ~(tap in first-set)
  |-
  ?~  first-list
    ^$(prod-rules.g t.prod-rules.g, c +(c))
  =.  pt
    ?:  (~(has by pt) [p.i.prod-rules.g i.first-list])
      ~&  "Predict Table Not Well Defined"
      ~&  [p.i.prod-rules.g i.first-list]
      ~&  [(~(got by pt) [p.i.prod-rules.g i.first-list]) c]
      !!
    (~(put by pt) [p.i.prod-rules.g i.first-list] c)
  $(first-list t.first-list)
  |@
  ++  make-first-sets
    |*  g=(cfg)
    ^-  (jug _(nt-example g) _(t-example g))
    =|  first-sets=(jug _(nt-example g) _(t-example g))
    ::initialize with terminals
    =/  terminals-list=(list _(t-example g))  ~(tap in terminals.g)
    =.  first-sets
      |-
      ?~  terminals-list
        first-sets
      $(first-sets (~(put ju first-sets) i.terminals-list i.terminals-list), terminals-list t.terminals-list)
    ::add A->tw => t in first(A)
    =+  prod-rules=prod-rules.g
    =.  first-sets
      |-
      ?~  prod-rules
        first-sets
      =/  new-first=(unit _(t-example g))
        ?~  q.i.prod-rules
          ~
        ?.  (~(has in terminals.g) i.q.i.prod-rules)
          ~
        (some i.q.i.prod-rules)
      =.  first-sets
        ?~  new-first
          first-sets
        (~(put ju first-sets) p.i.prod-rules u.new-first)
      $(prod-rules t.prod-rules)
    ::update with A->Bw => first(B) subset of first(A)
    =/  changed=?  %.y
    |-
    ?.  changed
      first-sets
    =.  changed  %.n
    =.  prod-rules  prod-rules.g
    |-
    ?~  prod-rules
      ^$
    =/  lhs-nt=(unit _(nt-example g))
      ?~  q.i.prod-rules
        ~
      ?.  (~(has in non-terminals.g) i.q.i.prod-rules)
        ~
      (some i.q.i.prod-rules)
    =/  wyt-0=@ud  ~(wyt in (~(gut by first-sets) p.i.prod-rules ~))
    =.  first-sets
      ?~  lhs-nt
        first-sets
      =/  first-set-0=(set _(t-example g))  (~(gut by first-sets) p.i.prod-rules ~)
      =/  first-set-1=(set _(t-example g))  (~(uni in first-set-0) (~(gut by first-sets) u.lhs-nt ~))
      (~(put by first-sets) p.i.prod-rules first-set-1)
    $(prod-rules t.prod-rules, changed |(changed !=(wyt-0 ~(wyt in (~(gut by first-sets) p.i.prod-rules ~)))))
  ++  make-follow-sets
    |*  [g=(cfg) first-sets=(jug) nullable=(set)]
    =|  follow-sets=(jug _(nt-example g) (ext-sym _(t-example g)))
    ^+  follow-sets
    =+  prod-rules=prod-rules.g
    =.  follow-sets  (~(put ju follow-sets) start.g [%e ~])
    ::initialize using first-sets
    =.  follow-sets
      |-
      ?~  prod-rules
        follow-sets
      |-
      ?~  q.i.prod-rules
        ^$(prod-rules t.prod-rules)
      =.  follow-sets
        ?~  t.q.i.prod-rules
          follow-sets
        ?:  (~(has in terminals.g) i.t.q.i.prod-rules)
          (~(put ju follow-sets) i.q.i.prod-rules [%r i.t.q.i.prod-rules])
        =/  follow-set-0=(set (ext-sym _(t-example g)))  (~(gut by follow-sets) i.q.i.prod-rules ~)
        =/  first-set-0=(set _(t-example g))  (~(gut by first-sets) i.t.q.i.prod-rules ~)
        =/  padded-first-set=(set (ext-sym _(t-example g)))  (~(run in first-set-0) pad-sym)
        =/  follow-set-1=(set (ext-sym _(t-example g)))  (~(uni in follow-set-0) padded-first-set)
        (~(put by follow-sets) i.q.i.prod-rules follow-set-1)
      $(q.i.prod-rules t.q.i.prod-rules)
    =/  changed=?  %.y
    |-
    ?.  changed
      follow-sets
    =.  changed  %.n
    =.  prod-rules  prod-rules.g
    |-
    ?~  prod-rules
      ^$
    ::find nullable suffix
    =/  rhs=(list _(t-example g))  (flop q.i.prod-rules)
    =|  n-suf=(list _(t-example g))
    =.  n-suf
      |-
      ?~  rhs
        n-suf
      ?.  (~(has in nullable) i.rhs)
        [i.rhs n-suf]
      $(n-suf [i.rhs n-suf], rhs t.rhs)
    =/  lhs-follow=(set (ext-sym _(t-example g)))  (~(gut by follow-sets) p.i.prod-rules ~)
    |-
    ?~  n-suf
      ^$(prod-rules t.prod-rules)
    =/  follow-set-0=(set (ext-sym _(t-example g)))  (~(gut by follow-sets) i.n-suf ~)
    =/  follow-set-1=(set (ext-sym _(t-example g)))  (~(uni in follow-set-0) lhs-follow)
    =.  follow-sets
      (~(put by follow-sets) i.n-suf follow-set-1)
    $(n-suf t.n-suf, changed |(changed !=(~(wyt in follow-set-0) ~(wyt in follow-set-1))))
  ++  first
    |*  [rhs=(list) first-sets=(jug) nullable=(set)]
    =|  first-set=(set (ext-sym _(get-list-example rhs)))
    ^+  first-set
    |-
    ?~  rhs
      ::all are nullable, so add null
      (~(put in first-set) [%n ~])
    =.  first-set
      =/  padded-first-set=(set (ext-sym _(get-list-example rhs)))  (~(run in (~(gut by first-sets) i.rhs ~)) pad-sym)
      (~(uni in first-set) padded-first-set)
    ?.  (~(has in nullable) i.rhs)
      first-set
    $(rhs t.rhs)
  ++  pad-sym
    |*  s=*
    ^-  (ext-sym _s)
    [%r s]
  ::
  ++  make-nullable
    |*  g=(cfg)
    =|  nullable=(set _(t-example g))
    ^+  nullable
    =/  changed=?  %.y
    |-
    ?.  changed
      nullable
    =+  prod-rules=prod-rules.g
    =/  wyt-0=@ud  ~(wyt in nullable)
    |-
    ?~  prod-rules
      ^$(changed !=(wyt-0 ~(wyt in nullable)))
    =?  nullable  (levy q.i.prod-rules |=(s=_(t-example g) (~(has in nullable) s)))
      (~(put in nullable) p.i.prod-rules)
    $(prod-rules t.prod-rules)
  --
--
