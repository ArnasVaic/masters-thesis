= Skaitinis modelis

Sudarytą matematinį modelį spręsime naudodami ADI schemą. Naudodamiesi šiuo metodu padalinsime sprendinio paieškos sekančiu laiko žingsniu problemą į dvi dalis. Vietoje, to, kad spręstume lygtį tiesiogiai ieškodami sprendinio reikšmės sekančiu laiko momentu $bold(c)^(n+1)$, pirmiausia rasime tarpinį sprendinį $bold(c)^*$. 

#let diff_part(var, sup) = $(delta_#var^2[bold(c)^#sup])/(Delta #var^2)$

$
(bold(c)^*-bold(c)^n)/(1/2 Delta t)=bold(D) dot.o (#diff_part($x$, $*$)+#diff_part($y$, $n$))+bold(S) bold(phi)(bold(c^n))
$ <adi-1st-part>

Lygtyje @adi-1st-part[], $bold(c)^*$ žymi sprendinį tarpiniu laiko momentu tarp $n$ ir $n+1$. Verta atkreipti dėmesį, kad difuzijos komponentė yra išreikština $y$ ašimi, tačiau neišreikština $x$ ašimi -- tai yra ADI metodo specifika, dėl kurios šis metodas gali būti toks greitas ir tikslus. $delta_x^2$ ir $delta_y^2$ žymi diskrečius difuzijos operatorius, kurie operuoja ant diskretaus tinklelio:

$
  delta_x^2[c_(i j)] = c_(i-1,j)-2c_(i j)+c_(i+1,j), quad delta_y^2[c_(i j)] = c_(i,j-1)-2c_(i j)+c_(i,j+1),
$

Gavę tarpinį sprendinį $bold(c)^*$ galime ieškoti $bold(c)^(n+1)$, kuris šiuo atveju gaunamas išsprendus lygtį:

$
  (bold(c)^(n+1)-bold(c)^*)/(1/2 Delta t)=bold(D) dot.o (#diff_part($x$, $*$)+#diff_part($y$, $n+1$))+bold(S) bold(phi)(bold(c^*))
$

Abi lygtis pertvarkius taip, kad to pačio laiko žingsnio komponentės būtų atitinkamose lygybės pusėse gauname lygtis:

$
  bold(c)^* -&underbrace((Delta t)/(2 Delta x^2) bold(D), bold(mu)_x) dot.o delta_x^2[bold(c)^*]=& bold(c)^n + underbrace((Delta t)/(2 Delta y^2) bold(D), bold(mu)_y) dot.o delta_y^2[bold(c)^n] + (Delta t)/2 bold(S) bold(phi) (bold(c^n)) \

  bold(c)^(n+1) -& underbrace((Delta t) / (2 Delta y^2) bold(D), bold(mu)_y) dot.o delta_y^2[bold(c)^(n+1)]=& bold(c)^* + underbrace((Delta t)/(2 Delta x^2) bold(D), bold(mu)_x) dot.o delta_x^2[bold(c)^*] + (Delta t)/2 bold(S) bold(phi) (bold(c^*))
$

Kurios susiveda į dvi tridiagonalines lygčių sistemas:

$
  (bold(I)-mu_(x,m)bold(L)_H)c_(m,i,:)^*&=c^n_(m,i,:)+mu_(y,m)delta_y^2[c^n_(m,i,:)]+(Delta t)/2 bold(S)_(m,:) bold(phi)(bold(c)^n_(i,:)) \

  (bold(I)-mu_(y,m)bold(L)_W)c_(m,:,j)^(n+1)&=c^*_(m,:,j)+mu_(x,m)delta_x^2[c^*_(m,:,j)]+(Delta t)/2 bold(S)_(m,:) bold(phi)(bold(c)^*_(:,j)) 
$

Čia $m=1,dots,5$ -- medžiagos indeksas, $i=1,dots,H$ -- eilutės indeksas, $j=1,dots,W$ -- stulpelio indeksas, $a_(i,:)$ -- $i$-tąją eilutę, o $a_(:,j)$ -- $j$-ąjį stulpelį. $bold(L)_N$ žymi $N times N$ dydžio diskrečią Laplaso matricą, su Neumano kraštinės sąlygos prielaida:

$
  bold(L)_N = underbrace(mat(align: #right, -1,1,;1,-2,1;,dots.down,dots.down,dots.down;,,1,-2,1;,,,1,-1), N)
$
