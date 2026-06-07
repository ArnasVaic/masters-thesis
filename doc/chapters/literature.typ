= Literatūros apžvalga

== Fizinis procesas

Eksperimentui yra paruošiamas homogeniškas ir stoichiometrinis aliuminio ($"Al"_2"O"_3$) ir itrio ($"Y"_2"O"_3$) oksidų miltelių mišinys, kuris yra kaitinamas krosnyje didesnėje nei 1200 $degree$C temperatūroje kelias dešimtis valandų.

Yra ištirta, kaip nuo dalelių dydžio priklauso galutinio produkto išeiga @kupp2014particle -- nustatyta, kad optimaliausi dalelių dydžiai yra 110nm itrio oksido dalelėms, o aliuminio oksido -- 90nm, tokiu atveju vykdant reakciją prie 1450 $degree$C galima pasiekti 93% YAG turinio pagal tūrį.

Kaitinant mišinį dalelių paviršių sandūrose pradeda formuotis tarpiniai junginiai -- itrio aliuminio perovskitas (YAP) bei monoklininis itrio aluminatas (YAM), iš kurių galiausiai formuojasi itrio aliuminio granatas (YAG). Jei reakcija vykdoma per mažoje temperatūroje, tarpiniai junginiai YAP ir YAM iki galo nesureaguoja, kas lemia prastą YAG kristalo kokybę.

Yra žinoma, kad norint paspartinti eksperimento eigą, chemikai periodiškai ištraukia mišinį iš krosnies ir prie žemesnės temperatūros atlieka mechaninį maišymą. Tokiu būdu yra atskleidžiamas dar nesureagavęs dalelių paviršių plotas, dėl kurio kaitinimo metu produktas formuojasi greičiau.

== Proceso kompiuterinis modeliavimas

Šiame tyrime remsimės ir nagrinėsime YAG sintezės matematinį modelį, kurį pristatė F. Ivanauskas et al @ivanauskasModellingSolidState2005a, straipsnyje procesas yra modeliuojamas kaip trijų netiesinių diferencialinių lygčių sistema. Kiekviena lygtis nusako kaip laikui bėgant keičiasi medžiagų molinė koncentracija erdvėje. 

Cheminės reakcijos metu produktas formuojasi skirtingų medžiagų dalelių sandūroje, todėl pradinis medžiagų išsidėstymas erdvėje daro didelę įtaką produkto sintezės greičiui ir dėl to yra reikšminga modeliuoti ne molinę medžiagų masės priklausomybę nuo laiko, o medžiagų molinės koncentracijos pasiskirstymą erdvėje.

Fiziniai šio modelio parametrai, apibūdinantys medžiagų difuzijos bei reakcijos greičius buvo nustatyti iš ribotų eksperimentinių duomenų apibūdinančių reakcijos trukmę taikant kietafazės reakcijos ir zolio gelio metodus @mackeviciusCloserLookComputer2012 @ivanauskasComputationalModellingYAG2009.

Šiuose tyrimuose yra modeliuojama nedidelė erdvės dalis, kurioje telpa viena medžiagos dalelė. Autoriai grindžia tokį pasirinkimą keliais argumentais. Modeliuoti visą fizinę erdvę būtų praktiškai sudėtinga, kadangi kiekviena medžiagos dalelė, kurios tūris yra 1 $mu m^3$ reikalauja daugelio diskrečių taškų, norint tiksliai modeliuoti difuzijos procesą. Taip pat yra teigiama, kad dalelės erdvėje yra išsidėsčiusios atsitiktinai ir tolygiai, todėl reikšmingus rezultatus galima išgauti modeliuojant keturis skirtingų dalelių kampus, kurie liečiasi briaunomis. Yra parodyta, kad modeliuojant tokį dalelių išsidėstymą, kuris primena šachmatų lentą, rezultatai stipriai nesikeičia, jei didiname modeliuojamos erdvės dydį @vaicekauskas2025yag.

#pagebreak()

Vėlesni tyrimai remiasi tokiu pačiu matematiniu modeliu, tačiau integruoja papildomus procesus, kurie originaliame straipsnyje nebuvo svarstomi, pavyzdžiui medžiagų maišymas @vsumskas2026yttrium @vaicekauskas2025yag. Tiriama šio proceso poveikis reakcijos greičiui. Rezultatai sutampa su eksperimentiniu būdu pastebimu reakcijos pagreitėjimu.

Verta paminėti, kad minėti tyrimai modeliuoja supaprastiną cheminę reakciją, kurios metu YAG formuojasi tiesiogiai iš metalų oksidų. Šiame tyrime konstruosime papildytą matematinį modelį, kuris apima ir tarpinių junginių sintezę.

Straipsniuose @ivanauskasComputationalModellingYAG2009 @mackeviciusCloserLookComputer2012 @ivanauskasModellingSolidState2005a sistema sprendžiama standartiniu Oilerio metodu (_angl. Euler method_), tačiau dviejų dimensijų modeliams egzistuoja efektyvesni metodai, pavyzdžiui neišreikštinis kintamosios krypties metodas (_angl. alternating direction implicit, ADI_), kurį pritaikius kartu su laiko žingsnio didinimo strategija galima efektyviai modeliuoti eksponentiškai didesnes erdves su tokia pačia diskrečių taškų rezoliucija @vaicekauskas2025yag.

Yra žinoma, kad šioje sintezės reakcijoje formuojasi tarpiniai junginiai -- itrio aliuminio perovskitas (YAP) bei monoklininis itrio aluminatas (YAM) @kupp2014particle, tačiau šis modelis į tai neatsižvelgia. Jei krosnies temperatūra nėra pakankamai aukšta, šie dariniai reakcijos eigoje nedingsta, kas ženkliai sumažina kristalo kokybę. 
