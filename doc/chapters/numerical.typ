= Skaitinis modelis

Sudarytą matematinį modelį spręsime naudodami ADI schemą. Naudodamiesi šiuo metodu padalinsime sprendinio paieškos kitame laiko žingsnyje problemą į dvi dalis. Vietoje to, kad spręstume lygtį tiesiogiai ieškodami sprendinio reikšmės sekančiu laiko momentu $bold(c)^(n+1)$, pirmiausia ra  sime tarpinį sprendinį $bold(c)^*$. 

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

Abi lygtis pertvarkius taip, kad to paties laiko žingsnio komponentės būtų atitinkamose lygybės pusėse gauname lygtis:

$
  bold(c)^* -&underbrace((Delta t)/(2 Delta x^2) bold(D), bold(mu)_x) dot.o delta_x^2[bold(c)^*]=& bold(c)^n + underbrace((Delta t)/(2 Delta y^2) bold(D), bold(mu)_y) dot.o delta_y^2[bold(c)^n] + (Delta t)/2 bold(S) bold(phi) (bold(c^n)) \

  bold(c)^(n+1) -& underbrace((Delta t) / (2 Delta y^2) bold(D), bold(mu)_y) dot.o delta_y^2[bold(c)^(n+1)]=& bold(c)^* + underbrace((Delta t)/(2 Delta x^2) bold(D), bold(mu)_x) dot.o delta_x^2[bold(c)^*] + (Delta t)/2 bold(S) bold(phi) (bold(c^*))
$

Kurios susiveda į dvi tridiagonalines lygčių sistemas:

$
  (bold(I)-mu_(x,m)bold(L)_W)c_(m,i,:)^*&=c^n_(m,i,:)+mu_(y,m)delta_y^2[c^n_(m,i,:)]+(Delta t)/2 bold(S)_(m,:) bold(phi)(bold(c)^n_(i,:)) \

  (bold(I)-mu_(y,m)bold(L)_H)c_(m,:,j)^(n+1)&=c^*_(m,:,j)+mu_(x,m)delta_x^2[c^*_(m,:,j)]+(Delta t)/2 bold(S)_(m,:) bold(phi)(bold(c)^*_(:,j)) 
$ <tridiag-eqs>

Čia $m=1,dots,5$ -- medžiagos indeksas, $i=1,dots,H$ -- eilutės indeksas, $j=1,dots,W$ -- stulpelio indeksas, $a_(i,:)$ žymi $i$-tąją eilutę, o $a_(:,j)$ žymi $j$-ąjį stulpelį ir $bold(mu_x) = (mu_(x,1), dots, mu_(x,5))$, o $bold(mu_y) = (mu_(y,1), dots, mu_(y,5))$. Verta paminėti, kad $i=0$, $i=H$, $j=0$ ir $j=W$ yra kraštiniai atvejai, kada diskretaus Laplaso operatoriaus veiksmas nebūtų apibrėžtas, nes operatorius reikalautų reikšmių eilutės arba stulpelio, kurie nėra diskrečiame tinklelyje, todėl šiems kraštutiniams atvejams galioja kitokios lygtys, kurios bus apibendrintos išskleistose formulėse @expanded-tridiagonal-eq[]. $bold(L)_N$ žymi $N times N$ dydžio diskrečią Laplaso matricą, su Neumano kraštinės sąlygos prielaida:

$
  bold(L)_N = underbrace(mat(
    align: #right, 
    -1,1,0,dots,0;
    1,-2,1,,dots.v;
    0,dots.down,dots.down,dots.down,0;
    dots.v,,1,-2,1;
    0,dots,0,1,-1
    ), N)
$

$bold(L)_W "ir" bold(L)_H$ atitinkamai žymi kvadratines matricas, kurios turi tiek elementų kiek yra stulpelių arba eilučių diskrečiame tinklelyje. Iškleidus kairėje lygybės pusėje esančias matricas ir supaprastinus diskrečiojo Laplaso operatorius lygtyse @tridiag-eqs[] gauname:


#let muxm = $mu_(x,m)$
#let muym = $mu_(y,m)$
// #let crow(mat,step,row) = $cvec(c^(step)_(mat,row,1),c^(step)_(mat,row,2),dots.v,c^(step)_(mat,row,W))$
#let crow(mat,step,row) = $c^(step)_(mat,row,:)$
#let ccol(mat,step,col) = $c^(step)_(mat,:,col)$
$
  mat(
    1+muxm, -muxm,,,,;
    -muxm,1+2muxm,-muxm,,(0),;
    ,-muxm,1+2muxm,dots.down,,;
    ,,dots.down,dots.down,dots.down,;
    ,(0),,dots.down,1+2muxm,-muxm;
    ,,,,-muxm,1+muxm
  ) crow(m,*,i) =  #<equate:revoke>\
  muym crow(m,n,max(i-1,1))+(1-2muym) crow(m,n,i)+muym crow(m,n,min(i+1,H)) #<equate:revoke>\
  +(Delta t)/2 crow(1, n, i) dot.o(
    bold(S)_(m,0) k_1 crow(2, n, i) +
    bold(S)_(m,1) k_2 crow(3, n, i) +
    bold(S)_(m,2) k_3 crow(4, n, i) 
  ) \

  mat(
    1+muym, -muym,,,,;
    -muym,1+2muym,-muym,,(0),;
    ,-muym,1+2muym,dots.down,,;
    ,,dots.down,dots.down,dots.down,;
    ,(0),,dots.down,1+2muym,-muym;
    ,,,,-muym,1+muym
  ) ccol(m,n+1,j) =  #<equate:revoke>\
  muxm ccol(m,*,max(j-1, 1))+(1-2muxm) ccol(m,*,j)+muxm ccol(m,*,min(j+1,W)) #<equate:revoke>\
  +(Delta t)/2 ccol(1, *, j) dot.o (
    bold(S)_(m,0) k_1 ccol(2, *, j) +
    bold(S)_(m,1) k_2 ccol(3, *, j) +
    bold(S)_(m,2) k_3 ccol(4, *, j) 
  )
$ <expanded-tridiagonal-eq>

@expanded-tridiagonal-eq matome iš dalies išskleistas tridiagonalines sistemas, kurios turi formą $bold(A) X = bold(B)$ ir gali būti sprendžiamos naudojant matematines bibliotekas, pavyzdžiui, bibliotekos `LAPACK` metodu `dgttrs_`.
