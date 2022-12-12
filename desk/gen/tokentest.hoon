/-  *tokenizer
/+  *tokenizer
!:
=<
|=  text=tape
^-  (list clean-token)
=/  states=(set state)     all-states
=/  start=state            %start
=/  alphabet=(set @t)      all-chars
=/  accepting=(set state)  accepting-states
=/  t-dfa=(tokenizer-dfa state @t)  (make-dfa [states start alphabet accepting])
::add transitions
::pre thousands separator rules
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%start to=%onedigit cs=nz-dig-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%onedigit to=%twodigits cs=dig-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%twodigits to=%wholenumber cs=dig-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%wholenumber to=%notsep cs=dig-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%notsep to=%notsep cs=dig-chars])
::thousands separator rules
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%onedigit to=%tsep1 c=t-sep])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%twodigits to=%tsep1 c=t-sep])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%wholenumber to=%tsep1 c=t-sep])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%tsep0 to=%tsep1 c=t-sep])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%tsep1 to=%tsep2 cs=dig-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%tsep2 to=%tsep3 cs=dig-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%tsep3 to=%tsep0 cs=dig-chars])
::decimal separator rules
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%onedigit to=%dsep c=d-sep])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%twodigits to=%dsep c=d-sep])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%wholenumber to=%dsep c=d-sep])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%notsep to=%dsep c=d-sep])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%tsep0 to=%dsep c=d-sep])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%dsep to=%decimalnumber cs=dig-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%decimalnumber to=%decimalnumber cs=dig-chars])
::op rules
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%start to=%op cs=op-chars])
::paren rules
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%start to=%lparen c='('])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%start to=%rparen c=')'])
::id rules
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%start to=%id0 cs=alpha-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%id0 to=%id cs=alpha-numeric-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%id to=%id cs=alpha-numeric-chars])
::command rules (for frac and unit)
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%start to=%cmdescape c='\\'])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%cmdescape to=%cmd0 cs=alpha-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%cmd0 to=%cmd cs=alpha-numeric-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%cmd to=%cmd cs=alpha-numeric-chars])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%cmd0 to=%cmdlbrace c='{'])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%cmd to=%cmdlbrace c='{'])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%cmdlbrace to=%cmdarg cs=alpha-numeric-chars])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%cmdarg to=%cmdarg cs=alpha-numeric-chars])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%cmdarg to=%cmdargsep c=','])
=.  t-dfa  (~(add-transition-list dfa t-dfa) [from=%cmdargsep to=%cmdarg cs=alpha-numeric-chars])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%cmdlbrace to=%cmdrbrace0 c='/'])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%cmdarg to=%cmdrbrace0 c='/'])
=.  t-dfa  (~(add-transition dfa t-dfa) [from=%cmdrbrace0 to=%cmdrbrace c='}'])
::compile (create map from accumulated list)
=.  t-dfa  ~(compile-transitions dfa t-dfa)
=|  tokens=(list my-token)
=.  tokens
  |-
  ?~  text
    =/  token-dfa=[last-token=(unit my-token) last-t-dfa=(tokenizer-dfa state @t)]  (~(put-char dfa t-dfa) ~)
    [(need last-token.token-dfa) tokens]
  =/  token-dfa=[new-token=(unit my-token) new-t-dfa=(tokenizer-dfa state @t)]  (~(put-char dfa t-dfa) i.text)
  $(tokens ?~(new-token.token-dfa tokens [u.new-token.token-dfa tokens]), t-dfa new-t-dfa.token-dfa, text t.text)
=|  clean-tokens=(list clean-token)
|-
?~  tokens
  clean-tokens
=/  term=terminal
  ?+  p.i.tokens  !!
    %onedigit       %number
    %twodigits      %number
    %wholenumber    %number
    %decimalnumber  %number
    %op   ?~
        q.i.tokens
      !!
    ?+  i.q.i.tokens  !!
      %'+'           %plus
      %'-'           %minus
      %'*'           %times
      %'/'           %divide
      %'^'           %exponent
    ==
    %lparen         %lparen
    %rparen         %rparen
    %id0            %id
    %id             %id
    %cmdrbrace    ?~  q.i.tokens
                    !!
                  =+  (trim 4 t.q.i.tokens)
                  ?:  =(p "frac")
                    %frac
                  ?:  =(p "unit")
                    %unit
                  !!
  ==
$(clean-tokens [[term q.i.tokens] clean-tokens], tokens t.tokens)
::
|%
  +$  state  ?(%start %onedigit %twodigits %wholenumber %notsep %tsep1 %tsep2 %tsep3 %tsep0 %dsep %decimalnumber %op %id0 %id %cmdescape %cmd0 %cmd %cmdlbrace %cmdrbrace0 %cmdrbrace %cmdarg %cmdargsep %lparen %rparen)
  +$  my-token  (token state @t)
  +$  terminal
    ?(%number %id %frac %unit %plus %minus %times %divide %exponent %lparen %rparen)
  +$  clean-token
    (pair terminal tape)
  ++  all-states
    ^-  (set state)
    (silt `(list state)`~[%start %onedigit %twodigits %wholenumber %notsep %tsep1 %tsep2 %tsep3 %tsep0 %dsep %decimalnumber %op %id0 %id %cmdescape %cmd0 %cmd %cmdlbrace %cmdrbrace0 %cmdrbrace %cmdarg %cmdargsep %lparen %rparen])
  ++  accepting-states
    ^-  (set state)
    (silt `(list state)`~[%onedigit %twodigits %wholenumber %tsep0 %notsep %decimalnumber %op %lparen %rparen %id0 %id %cmdrbrace])
  ++  alpha-chars
    ^-((list @t) (weld (gulf 'a' 'z') (gulf 'A' 'Z')))
  ++  dig-chars
    ^-((list @t) (gulf '0' '9'))
  ++  op-chars
    ^-((list @t) ~['+' '-' '*' '/' '^'])
  ++  other-chars
    ^-((list @t) ~['\\' '{' '}' '(' ')' t-sep d-sep])
  ++  all-chars
    ^-  (set @t)
    (silt ;:(weld alpha-chars dig-chars op-chars other-chars))
  ++  alpha-numeric-chars
    ^-  (list @t)
    (weld alpha-chars dig-chars)
  ++  nz-dig-chars
    ^-((list @t) (gulf '1' '9'))
  ++  t-sep
    ','
  ++  d-sep
    '.'
--
