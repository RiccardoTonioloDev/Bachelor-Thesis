#pagebreak()
#import "../config/functions.typ": *
= PyXiNet

PyXiNet (*Py*\ramidal *Xi* *Net*\work) è una famiglia di modelli che tenta, esplorando le diverse soluzioni e combianzioni di soluzioni trattate fino ad ora, di massimizzare l'efficacia e l'efficienza nel portare a termine il compito di @MDE. 

#linebreak()

Il nome suggerisce che sia una rete fortemente basata sia su #link(<ch:pydnet>)[PyDNet] che su #link(<ch:xinet>)[XiNet], infatti il primo modello, in particolare la seconda versione 2, visti le sue ottime performance di base, darà una direzione sullo stile dell'architettura generale di PyXiNet, mentre il secondo cercherà di migliorare l'@encoder della rete.

#linebreak()

Il seguente capitolo andrà quindi a mostrare l'approccio sperimentale e esplorativo condotto, nel testare ipotesi e progressivamente migliorare e raffinare le architetture proposte.

== PyXiNet *$alpha$*
PyXiNet $alpha$ rappresenta il primo approccio all'uso di @xinet nell'@encoder di @PyDNetV2.
In particolare sono stati realizzati due modelli, chiamati $alpha" I"$ e $alpha" II"$.
#block([
L'architetture che è state realizzate sono le seguenti:
#figure(image("../images/architectures/PyXiNet-a1.drawio.png",width:350pt),caption: [Architettura di PyXiNet $alpha" I"$])
],breakable: false,width: 100%)
#figure(image("../images/architectures/PyXiNet-a2.drawio.png",width:350pt),caption: [Architettura di PyXiNet $alpha" II"$])

#block([
Essendo state allenate assieme, con ciascuna si voleva fornire una risposta a diverse domande:
- @xinet se usato come @encoder porta a buoni risultati?
],breakable: false,width: 100%)
- A parità di livelli nella piramide, si riesce ad avere una performance migliore o uguale a quella di @PyDNetV2?
- Se si rimuove un livello alla piramide, come vengono impattate le performance?
- L'uso di @xinet come impatta il numero di parametri e il tempo di inferenza?
 - Si vuole far notare che per rispondere a questa domanda, rispetto alle tabelle di valutazione precedenti, sono stati introdotti due nuovi campi: $\#$parametri, e _inference time_ (il quale viene calcolato su una media del tempo di inferenza su 10 immagini, passate in successione al modello e non in batch).

#block([
L'allenamento dei due modelli ha portato ai seguenti risultati:
#eval_table(
  (
    (name: [PyXiNet $alpha" I"$],vals:())
  ),
  2,
  [@PyDnetV1 e @PyDNetV2 vs. PyXiNet $alpha$]
)
],breakable: false,width: 100%)

== PyXiNet *$beta$*
== PyXiNet *$MM$*
== PyXiNet *$beta$*CBAM