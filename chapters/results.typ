#pagebreak(to: "odd")
#import "../config/functions.typ": *
= Risultati <ch:risultati>

Nel seguente capitolo si farà un breve riepilogo sui risultati quantitativi ottenuti usando le metriche di valutazione usate in @eigen e le due metriche in più introdotte nella valutazione dei modelli PyXiNet, soffermandosi ad analizzare casistiche interessanti. Successivamente vengono esposti come risultati qualitativi, le mappe di profondità prodotte rispettivamente da PDV1, PDV2 (riscritti in @PyTorch) e i dai migliori modelli sperimentali $MM$ II e $beta" CBAM"$ I.

== Risultati quantitativi
I seguenti sono tutti i risultati ottenuti dai due PyDNet e dai tredici esperimenti effettuati:
#ext_eval_table(
  (
    (name: [PDV1], vals: (1971624.0,0.15,0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [PDV2], vals: (716680.0,0.10,0.157,1.487,6.167,0.254,0.783,0.917,0.964)),
    (name: [PyXiNet $alpha" I"$],vals:(429661.0,0.14,0.17,1.632,6.412,0.269,0.757,0.903,0.958)),
    (name: [PyXiNet $alpha" II"$],vals:(709885.0,0.12,0.168,1.684,6.243,0.259,0.777,0.913,0.960)),
    (name: [PyXiNet $beta" I"$],vals:(941638.0,0.16,0.156,1.546,6.259,0.251,0.791,0.921,0.965)),
    (name: [PyXiNet $beta" II"$],vals:(481654.0,0.14,0.168,1.558,6.327,0.259,0.762,0.910,0.963)),
    (name: [PyXiNet $beta" III"$],vals:(1246422.0,0.16,0.148,1.442,6.093,0.241,0.803,0.926,0.967)),
    (name: [PyXiNet $beta" IV"$],vals:(1446014.0,0.18,0.146,1.433,6.161,0.241,0.802,0.926,0.967)),
    (name: [PyXiNet $MM" I"$],vals:(1970643.0,0.36,0.147,1.351,5.98,0.244,0.8,0.926,0.967)),
    (name: [PyXiNet $MM" II"$],vals:(2233197.0,0.38,0.14,1.289,5.771,0.234,0.814,0.933,0.969)),
    (name: [PyXiNet $MM" III"$],vals:(1708499.0,0.35,0.141,1.279,5.851,0.239,0.808,0.927,0.968)),
    (name: [PyXiNet $MM" IV"$],vals:(1839981.0,0.36,0.145,1.25,5.885,0.242,0.798,0.926,0.967)),
    (name: [PyXiNet $beta"CBAM I"$],vals:(1250797.0,0.19,0.143,1.296,5.91,0.239,0.805,0.928,0.968)),
    (name: [PyXiNet $beta"CBAM II"$],vals:(1450389.0,0.23,0.147,1.379,5.974,0.239,0.806,0.927,0.968)),
    (name: [CBAM PyDNet],vals:(746673.0,0.28,0.167,1.722,6.509,0.251,0.776,0.916,0.965)),
  ),
  2,
  [Risultati di tutti gli esperimenti a confronto],
  res: 102pt
)

Come già espresso nei capitoli precedenti, i risultati ottenuti con $MM$ II sono i migliori. Essendo però troppo pesante e lento come modello per essere eseguito, in un contesto @embedded sicuramente $beta$CBAM I sarebbe preferibile.

#block([
Possiamo notare però che il divario tra le _performance_ dei due modelli appena menzionati non è eccessivo, soprattutto considerando il divario nei tempi di inferenza e nel numero di parametri:
#ext_eval_table(
  (
    (name: [PyXiNet $MM" II"$],vals:(2233197.0,0.38,0.14,1.289,5.771,0.234,0.814,0.933,0.969)),
    (name: [PyXiNet $beta"CBAM I"$],vals:(1250797.0,0.19,0.143,1.296,5.91,0.239,0.805,0.928,0.968)),
  ),
  0,
  [PyXiNet $MM" II"$ e PyXiNet $beta"CBAM I"$ a confronto],
  res: 102pt
)
],breakable: false,width: 100%)

#block([
Si vuole inoltre far notare come, sebbene il modulo CBAM sia più semplice come meccanismo di attenzione rispetto alla _self attention_, non tutti gli esperimenti utilizzanti quest'ultima tecnica hanno portato a prestazioni migliori risetto alla prima:
#ext_eval_table(
  (
    (name: [PyXiNet $MM" I"$],vals:(1970643.0,0.36,0.147,1.351,5.98,0.244,0.8,0.926,0.967)),
    (name: [PyXiNet $MM" IV"$],vals:(1839981.0,0.36,0.145,1.25,5.885,0.242,0.98,0.926,0.967)),
    (name: [PyXiNet $beta"CBAM I"$],vals:(1250797.0,0.19,0.143,1.296,5.91,0.239,0.805,0.928,0.968)),
  ),
  0,
  [PyXiNet $MM" I e IV"$ vs. PyXiNet $beta"CBAM I"$],
  res: 102pt
)
],breakable: false,width: 100%)

#block([
Se si va invece a prendere in considerazione l'uso di XiNet come @encoder, si può facilmente dedurre che è il diretto responsabile per parte dell'aumento del tempo di inferenza. Questo lo si può notare nel confronto tra i modelli $alpha$ e i modelli PDV1 e PDV2:
#ext_eval_table(
  (
    (name: [PDV1], vals: (1971624.0,0.15,0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [PDV2], vals: (716680.0,0.10,0.157,1.487,6.167,0.254,0.783,0.917,0.964)),
    (name: [PyXiNet $alpha" I"$],vals:(429661.0,0.14,0.17,1.632,6.412,0.269,0.757,0.903,0.958)),
    (name: [PyXiNet $alpha" II"$],vals:(709885.0,0.12,0.168,1.684,6.243,0.259,0.777,0.913,0.960)),
  ),
  0,
  [PyXiNet $MM" I e IV"$ vs. PyXiNet $beta"CBAM I"$],
  res: 102pt
)
],breakable: false,width: 100%)
La famiglia $alpha$ infatti anche possedendo in tutti i suoi esperimenti un numero di parametri inferiore a PDV2, ha comunque un tempo di inferenza maggiore, rispetto a quest'ultimo, di almeno il 20%. Questo è dovuto al gran numero di somme tensoriali _element wise_ che le XiNet eseguono. Questo tipo di operazioni infatti, anche se non contribuiscono direttamente al far crescere il numero dei parametri, aumentano il numero di calcoli da eseguire. Di conseguenza a meno di un uso radicalmente diverso di XiNet all'interno delle architetture, rispetto a quanto provato, non sarà possibile scendere sotto il tempo di inferenza di PDV2.


#block([
== Risultati qualitativi
In seguito vengono elencati quattro risultati qualitativi dei modelli precedentemente citati.
],breakable: false,width: 100%)
#stack(dir: ltr,
  align(left)[#figure(image("../images/Inferences/RisultatiQualitativi1.drawio.png",width: 200pt),caption:[Inferenza sulla prima immagine.])],
  align(right)[#figure(image("../images/Inferences/RisultatiQualitativi2.drawio.png",width: 200pt),caption:[Inferenza sulla seconda immagine.])]
)

#stack(dir: ltr,
  align(left)[#figure(image("../images/Inferences/RisultatiQualitativi3.drawio.png",width: 200pt),caption:[Inferenza sulla terza immagine.])],
  align(right)[#figure(image("../images/Inferences/RisultatiQualitativi5.drawio.png",width: 200pt),caption:[Inferenza sulla quarta immagine.])]
)

Sebbene i risultati siano molto simili tra loro a livello qualitativo, si può notare con occhio più attento che i modelli $beta$CBAM I e $MM$ II riescono a carpire meglio le forme, al contempo riducendo artefatti e distorsioni presenti nell'immagine.
