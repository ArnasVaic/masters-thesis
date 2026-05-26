= Skaitinis modelis

Sudarytą matematinį modelį spręsime naudodami ADI schemą. Naudodamiesi šiuo metodu padalinsime sprendinio paieškos sekančiu laiko žingsniu problemą į dvi dalis. Vietoje, to, kad spręstume lygtį tiesiogiai ieškodami sprendinio reikšmės sekančiu laiko momentu $bold(c)^(n+1)$, pirmiausia rasime tarpinį sprendinį $bold(c)^*$. 

#let diff_part(var, sup) = $(delta_#var^2[bold(c)^#sup])/(Delta #var^2)$

$
(bold(c)^*-bold(c)^n)/(Delta t)=bold(D) dot.o (#diff_part($x$, $*$)+#diff_part($y$, $n$))+bold(S) bold(phi)(bold(c^n))
$ <adi-1st-part>

Lygtyje @adi-1st-part[], $bold(c)^*$ žymi sprendinį tarpiniu laiko momentu tarp $n$ ir $n+1$. Verta atkreipti dėmesį, kad difuzijos komponentė yra išreikština $y$ ašimi, tačiau neišreikština $x$ ašimi -- tai yra ADI metodo specifika, dėl kurios šis metodas gali būti toks greitas ir tikslus. $delta_x^2$ ir $delta_y^2$ žymi diskrečius difuzijos operatorius, kurie operuoja ant diskretaus tinklelio:

$
  delta_x^2[c_(i j)] = c_(i-1,j)-2c_(i j)+c_(i+1,j), quad delta_y^2[c_(i j)] = c_(i,j-1)-2c_(i j)+c_(i,j+1),
$

Gavę tarpinį sprendinį $bold(c)^*$ galime ieškoti $bold(c)^(n+1)$, kuris šiuo atveju gaunamas išsprendus lygtį:

$
  (bold(c)^(n+1)-bold(c)^*)/(Delta t)=bold(D) dot.o (#diff_part($x$, $*$)+#diff_part($y$, $n+1$))+bold(S) bold(phi)(bold(c^*))
$