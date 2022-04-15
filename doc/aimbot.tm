<TeXmacs|2.1>

<style|generic>

<\body>
  <doc-data|<doc-title|Aimbot>|<doc-author|<author-data|<author-name|Lorenz
  Auer>>>>

  <\problem>
    Given <math|T<around*|(|0|)>,T<around*|(|-1|)>\<in\>\<bbb-R\><rsup|2>>
    and <math|v\<in\>\<bbb-R\>> with <math|v\<gtr\>0>. If possible, calculate
    <math|t\<geqslant\>0> and <math|T<around*|(|t|)>\<in\>\<bbb-R\><rsup|2>>
    assuming <math|T> is a line and

    <\equation*>
      <frac|<around*|\||T<around*|(|t|)>|\|>|v>=t
    </equation*>

    holds.
  </problem>

  <\solution*>
    \;

    With <math|T\<assign\>T<around*|(|0|)>,T<rprime|'>\<assign\>T<around*|(|-1|)>,D\<assign\>T-T<rprime|'>>
    the system of equations is derived:

    <\eqnarray*>
      <tformat|<table|<row|<cell|T<around*|(|t|)>>|<cell|=>|<cell|T+t<around*|(|T-T<rprime|'>|)>>>|<row|<cell|T<around*|(|t|)><rsub|x>>|<cell|=>|<cell|T<rsub|x>+t*D<rsub|x><eq-number><label|F1>>>|<row|<cell|T<around*|(|t|)><rsub|y><rsub|>>|<cell|=>|<cell|T<rsub|y>+t*D<rsub|y><eq-number><label|F2>>>|<row|<cell|<frac|<around*|\||T<around*|(|t|)>|\|>|v>>|<cell|=>|<cell|t>>|<row|<cell|<around*|\||T<around*|(|t|)>|\|>>|<cell|=>|<cell|t*v>>|<row|<cell|T<around*|(|t|)><rsub|x><rsup|2>+T<around*|(|t|)><rsub|y><rsup|2>>|<cell|=>|<cell|t<rsup|2>v<rsup|2><eq-number><label|F3>>>>>
    </eqnarray*>

    Solving for <math|t> with:

    <\eqnarray*>
      <tformat|<table|<row|<cell|<around*|(|T<rsub|x>+t*D<rsub|x>|)><rsup|2>+<around*|(|T<rsub|y>+t*D<rsub|y>|)><rsup|2>>|<cell|=>|<cell|t<rsup|2>v<rsup|2>>>|<row|<cell|T<rsub|x><rsup|2>+2t*T<rsub|x>D<rsub|x>+t<rsup|2>D<rsub|x><rsup|2>+T<rsub|y><rsup|2>+2t*T<rsub|y>D<rsub|y>+t<rsup|2>D<rsub|y><rsup|2>-t<rsup|2>v<rsup|2>>|<cell|=>|<cell|0>>|<row|<cell|<around*|(|<wide*|<wide*|D<rsub|x><rsup|2>+D<rsub|y><rsup|2>|\<wide-underbrace\>><rsub|=<around*|\||T<around*|(|0|)>-T<around*|(|1|)>|\|><rsup|2>>-v<rsup|2>|\<wide-underbrace\>><rsub|a>|)>t<rsup|2>+<around*|(|<wide*|2T<rsub|x>D<rsub|x>+2T<rsub|y>D<rsub|y>|\<wide-underbrace\>><rsub|b>|)>t+<around*|(|<wide*|T<rsub|x><rsup|2>+T<rsub|y><rsup|2>|\<wide-underbrace\>><rsub|c=<around*|\||T<around*|(|0|)>|\|><rsup|2>>|)>>|<cell|=>|<cell|0>>>>
    </eqnarray*>

    Assuming <math|c=0>

    <\eqnarray*>
      <tformat|<table|<row|<cell|t>|<cell|=>|<cell|0>>>>
    </eqnarray*>

    Assuming <math|v\<gtr\><around*|\||T<around*|(|0|)>-T<around*|(|1|)>|\|>>

    <\eqnarray*>
      <tformat|<table|<row|<cell|t>|<cell|=>|<cell|<frac|-b\<pm\><sqrt|b<rsup|2>-4a*c>|2a>>>|<row|<cell|a\<less\>0:>|<cell|=>|<cell|<frac|-b-<sqrt|b<rsup|2>-4a*c>|2a>>>|<row|<cell|>|<cell|=>|<cell|<frac|-<around*|(|2T<rsub|x>D<rsub|x>+2T<rsub|y>D<rsub|y>|)>-<sqrt|<around*|(|2T<rsub|x>D<rsub|x>+2T<rsub|y>D<rsub|y>|)><rsup|2>-4<around*|(|D<rsub|x><rsup|2>+D<rsub|y><rsup|2>-v<rsup|2>|)>*<around*|(|T<rsub|x><rsup|2>+T<rsub|y><rsup|2>|)>>|2<around*|(|D<rsub|x><rsup|2>+D<rsub|y><rsup|2>-v<rsup|2>|)>>>>|<row|<cell|>|<cell|=>|<cell|<frac|-<around*|(|T<rsub|x>D<rsub|x>+T<rsub|y>D<rsub|y>|)>-<sqrt|<around*|(|T<rsub|x>D<rsub|x>+T<rsub|y>D<rsub|y>|)><rsup|2>-<wide|<around*|(|D<rsub|x><rsup|2>+D<rsub|y><rsup|2>-v<rsup|2>|)>|\<wide-overbrace\>><rsup|\<less\>0>*<wide|<around*|(|T<rsub|x><rsup|2>+T<rsub|y><rsup|2>|)>|\<wide-overbrace\>><rsup|\<gtr\>0>>|<around*|(|D<rsub|x><rsup|2>+D<rsub|y><rsup|2>-v<rsup|2>|)>>>>>>
    </eqnarray*>

    Assuming <math|v\<less\><around*|\||T<around*|(|0|)>-T<around*|(|1|)>|\|>,b\<less\>0,b<rsup|2>\<geqslant\>4a*c>\ 

    <\eqnarray*>
      <tformat|<table|<row|<cell|t>|<cell|=>|<cell|<frac|-b\<pm\><sqrt|b<rsup|2>-4a*c>|2a>>>|<row|<cell|a\<gtr\>0:>|<cell|=>|<cell|<frac|-b-<sqrt|b<rsup|2>-4a*c>|2a>>>>>
    </eqnarray*>

    Assuming <math|v=<around*|\||T<around*|(|0|)>-T<around*|(|1|)>|\|>,b\<less\>0>

    <\eqnarray*>
      <tformat|<table|<row|<cell|t>|<cell|=>|<cell|-<frac|c|b>>>>>
    </eqnarray*>
  </solution*>

  \;

  \;
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|F1|<tuple|1|1>>
    <associate|F2|<tuple|2|1>>
    <associate|F3|<tuple|3|1>>
  </collection>
</references>