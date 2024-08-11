#pagebreak(to: "odd")
#import "../config/functions.typ": *
= PyXiNet <ch:pyxinet>

PyXiNet (*Py*\ramidal *Xi* *Net*\work) è una famiglia di modelli che tenta esplorando le diverse soluzioni trattate fino ad ora, di combinarle per massimizzare l'efficacia e l'efficienza nel portare a termine il compito di @MDE.



Il nome suggerisce che sia una rete fortemente basata sia su #link(<ch:pydnet>)[PyDNet] che su #link(<ch:xinet>)[XiNet], infatti il primo modello, in particolare la seconda versione viste le sue ottime _performance_ di base, darà una direzione sullo stile dell'architettura generale, mentre il secondo cercherà di migliorare l'@encoder della rete.



Il seguente capitolo andrà quindi a mostrare l'approccio sperimentale e esplorativo condotto, nel testare ipotesi e progressivamente migliorare e raffinare le architetture proposte.

== PyXiNet *$alpha$*
PyXiNet $alpha$ rappresenta il primo approccio all'uso di XiNet come @encoder.
In particolare sono stati realizzati due modelli, chiamati $alpha" I"$ e $alpha" II"$.
#block([
Le architetture create sono le seguenti:
#figure(image("../images/architectures/PyXiNet-a1.drawio.png",width:350pt),caption: [Architettura di PyXiNet $alpha" I"$])
],breakable: false,width: 100%)
#figure(image("../images/architectures/PyXiNet-a2.drawio.png",width:350pt),caption: [Architettura di PyXiNet $alpha" II"$])

Si può notare che dopo l'uso di ogni XiNet, è presente una convoluzione trasposta, questo perchè come già discusso nel capitolo #link(<ch:xinet>)[XiNet], l'uso di tale rete fa una riduzione della dimensionalità spaziale (altezza e larghezza) all'inizio, e poi ne fa una per ogni coppia all'interno della rete.

La convoluzione trasposta serve per far si che la dimensionalità spaziale sia la medesima che avrebbe prodotto l'@encoder originale di PDV1.
Anche in questo caso, come per PDV1, la convoluzione trasposta è seguita da una funzione di attivazione _ReLU_, con coefficiente di crescita di 0,2 per la parte negativa.

#block([
Essendo state allenate assieme, con ciascuna si voleva fornire una risposta a diverse domande:
- XiNet se usato come @encoder porta a buoni risultati?
],breakable: false,width: 100%)
- A parità di livelli nella piramide, si riesce ad avere una _performance_ migliore o uguale a quella di PDV2?
- Se si rimuove un livello alla piramide, come vengono impattate le _performance_?
- L'uso di XiNet come impatta il numero di parametri e il tempo di inferenza?
 - Si vuole far notare che per rispondere a questa domanda, rispetto alle tabelle di valutazione precedenti, sono stati introdotte due nuove metriche di valutazione: numero di parametri ($\#$p), e tempo di inferenza in secondi (Inf. (s)) (il quale viene calcolato facendo una media del tempo di inferenza su 10 immagini, passate in successione al modello e non in batch, con una elaborazione su _CPU_ Intel i7-7700).

#block([
L'allenamento dei due modelli ha portato ai seguenti risultati:
#ext_eval_table(
  (
    (name: [PDV1], vals: (1971624.0,0.15,0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [PDV2], vals: (716680.0,0.10,0.157,1.487,6.167,0.254,0.783,0.917,0.964)),
    (name: [PyXiNet $alpha" I"$],vals:(429661.0,0.14,0.17,1.632,6.412,0.269,0.757,0.903,0.958)),
    (name: [PyXiNet $alpha" II"$],vals:(709885.0,0.12,0.168,1.684,6.243,0.259,0.777,0.913,0.960))
  ),
  2,
  [PDV1 e PDV2 vs. PyXiNet $alpha$],
)
],breakable: false,width: 100%)

Da come si può osservare, sebbbene il numero di parametri sia stato intorno a quelli di PDV2, se non minore, tutte le altre metriche sono fortemente peggiorate, andando a suggerire che forse non è quello il migliore uso di XiNet come @encoder.

== PyXiNet *$beta$*
Dato l'insuccesso dato della tipologia $alpha$, la tipologia $beta$ cerca di utilizzare al meglio XiNet, al fine di migliorare almeno una metrica di valutazione.

Per quanto scritto in XiNet, le reti proposte all'interno del paper sono composte da almeno cinque XiConv. Questo suggerisce come la profondità sia un elemento essenziale per il successo nel suo utilizzo.

La famiglia $beta$ è composta da quattro varianti, due da tre livelli e due da quattro livelli, tutte con una leggera variazione rispetto all'architettura a piramide tradizionale, questo per riuscire a rispondere alle seguenti domande:
- La profondità aiuta XiNet nel migliorare le _performance_ del modello?
- XiNet è un @encoder efficace?
- Parallelizzare gli @encoder può rendere più veloce il tempo di inferenza rispetto ad averli in serie?

#block([
Le architetture proposte sono quindi le seguenti:
#figure(image("../images/architectures/PyXiNet-b1.drawio.png",width:350pt),caption: [Architettura di PyXiNet $beta" I"$])
],breakable: false,width: 100%)
#figure(image("../images/architectures/PyXiNet-b2.drawio.png",width:350pt),caption: [Architettura di PyXiNet $beta" II"$])
#figure(image("../images/architectures/PyXiNet-b3.drawio.png",width:350pt),caption: [Architettura di PyXiNet $beta" III"$])
#figure(image("../images/architectures/PyXiNet-b4.drawio.png",width:350pt),caption: [Architettura di PyXiNet $beta" IV"$])

#block([
Come si può notare, tutte le architetture della famiglia $beta$ hanno gli @encoder in parallelo. Questo è stato fatto per due motivi:
 + Vedere se la parallelizzazione del grafo della rete neurale migliorava il tempo di inferenza, potendo eseguire i vari livelli in parallelo (invece di fare aspettare ad ogni livello i livelli superiori);
 + Permettere agli @encoder composti da XiNet, di diventare più profondi. Questo perchè come spiegato nel capitolo #link(<ch:xinet>)[XiNet], per ogni coppia successiva di blocchi XiConv viene dimezzata la dimensionalità spaziale (altezza e larghezza). Non dipendendo ogni livello da quello precedente, possiamo sfruttare questa caratteristica per far si che ogni nuovo @encoder si occupi del ridimensionamento della risoluzione del proprio livello.
],breakable: false,width: 100%)

Il modello $beta" I"$ si ispira ad $alpha" I"$, andando però semplicemente a parallelizzare gli @encoder per quindi permettere delle XiNet più lunghe successivamente.

Il modello $beta" II"$ rispetto a $beta" I"$ cerca di verificare se un eventuale problema potrebbe essere l'uso della convoluzione trasposta, come metodo per aggiustare la risoluzione del tensore. Per verificare ciò le XiNet sono di un blocco più corte rispetto a $beta" I"$, e per far si che si ottenga lo stesso numero di canali di prima, si usa una convoluzione con @kernel di dimensione $1times 1$.

I modelli $beta" III"$ e $beta" IV"$ vanno semplicemente ad aggiungere un livello in più nella piramide, rispetto ai corrispondenti $beta" I"$ e $beta" II"$, così da verificare che eventualmente a parità di numero di livelli si riescano ad ottenere _performance_ simili, se non migliori, a quelle di PDV2.

Le due reti però utilizzano approcci differenti per aggiungere un nuovo livello:
 - $beta" III"$ aggiunge un @encoder tradizionale di PDV1 che è posto in serie con l'@encoder del livello superiore, questo per riuscire ad avere un risparmio sul numero di parametri (poichè avere una XiNet profonda sei blocchi XiConv, aumenta significatamente la grandezza della rete);
 - $beta" IV"$ invece aggiunge un'ulteriore XiNet di un blocco più lunga rispetto al suo livello precedente, seguita da una convoluzione con @kernel di dimensioni $1 times 1$ per il ridimensionamento dei canali.


#block([
Con le architetture precedentemente discusse ho ottenuto i seguenti risultati:
#ext_eval_table(
  (
    (name: [PDV1], vals: (1971624.0,0.15,0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [PDV2], vals: (716680.0,0.10,0.157,1.487,6.167,0.254,0.783,0.917,0.964)),
    (name: [PyXiNet $beta" I"$],vals:(941638.0,0.16,0.156,1.546,6.259,0.251,0.791,0.921,0.965)),
    (name: [PyXiNet $beta" II"$],vals:(481654.0,0.14,0.168,1.558,6.327,0.259,0.762,0.910,0.963)),
    (name: [PyXiNet $beta" III"$],vals:(1246422.0,0.16,0.148,1.442,6.093,0.241,0.803,0.926,0.967)),
    (name: [PyXiNet $beta" IV"$],vals:(1446014.0,0.18,0.146,1.433,6.161,0.241,0.802,0.926,0.967)),
  ),
  2,
  [PDV1 e PDV2 vs. PyXiNet $beta$],
)
],breakable: false,width: 100%)

In questo caso i risultati migliorano su tutte le metriche per i modelli $beta" III"$ e $beta" IV"$, tranne per il tempo di inferenza e per il numero di parametri.
Tuttavia notiamo che sebbene il numero di parametri di $beta" III"$ non è minore di quelli di PDV2, sono di un $tilde 37%$ inferiori a quelli di PDV1 e il tempo di inferenza di questi due modelli è molto simile.
Questo è quindi un buon punto di partenza per poter applicare meccanismi di attenzione, in grado di migliorare ulteriormente le prestazioni del modello.

#block([
== PyXiNet *$MM$*
Essendo coscienti che la _self attention_ è parecchio costosa in termini di tempo e quindi un'opzione non praticabile in contesti dove il tempo di inferenza deve essere corto e la potenza computazionale limitata, la famiglia $MM$ va in realtà semplicemente a provare e verificare quale valore aggiunto questo meccanismo di atttenzione può portare nel miglioramento delle metriche di valutazione, senza avere alcune pretese sul poter essere applicata come soluzione per il caso d'uso @MDE _embedded_.
],breakable: false,width: 100%)

Nel tenativo di implementazione di una _self attention_ meno impattante computazionalmente, rispetto al normale modulo di attenzione presentato in @sa e affrontato nella @sa:ch, ho realizzato un blocco chiamato _Light Self Attetion Module_ (LSAM) che rispetto al _Self Attention Module_ (SAM) discusso precedentemente, applica dell'interpolazione ad _area_ per ridimensionare la risoluzione del tensore in ingresso.


Ne sono state realizzate due versioni per riuscire a capire dove utilizzare l'interpolazione ad _area_, al fine di ottenere i migliori risultati.

#block([
Le architetture delle due versioni di _LSAM_ sono le seguenti:
#figure(image("../images/architectures/Attention-lsam1.drawio.png",width:300pt),caption: [Architettura di _LSAM V1_])
],breakable: false,width: 100%)
#figure(image("../images/architectures/Attention-lsam2.drawio.png",width:300pt),caption: [Architettura di _LSAM V2_])

Nel primo caso l'applicazione dell'attenzione avviene nell'ambiente a risoluzione ridotta, nel secondo caso invece si vuole sfruttare la maggiore informazione presente nell'input, andando quindi ad applicarla nell'ambiente a risoluzione piena.
È stata poi aggiunta la normalizzazione dei tensori, come consigliato in @layernorm.


Come modello di partenza per la famiglia $MM$ è stato scelto il modello $beta" IV"$, per vedere appunto come peggiora il suo tempo di inferenza e quanto migliorano le sue metriche di valutazione.

#block([
Le architetture della famiglia $MM$ sono le seguenti:
#figure(image("../images/architectures/PyXiNet-m1.drawio.png",width:350pt),caption: [Architettura di PyXiNet $MM" I"$])
],breakable: false,width: 100%)
#figure(image("../images/architectures/PyXiNet-m2.drawio.png",width:350pt),caption: [Architettura di PyXiNet $MM" II"$])
#figure(image("../images/architectures/PyXiNet-m3.drawio.png",width:350pt),caption: [Architettura di PyXiNet $MM" III"$])
#figure(image("../images/architectures/PyXiNet-m4.drawio.png",width:350pt),caption: [Architettura di PyXiNet $MM" IV"$])

Da quanto osservabile, si può notare come il blocco di attenzione sia stato posizionato nell'@encoder del primo livello, questo in quanto si tratta del livello che opera alla risoluzione massima e quindi il livello che opera su quanta più informazione vicina all'input originale del modello.
Entrambe le versioni di _LSAM_ sono state posizionate sia prima che dopo la concatenazione, per riuscire a trovare la posizione migliore tra le due.

#block([
I risultati ottenuti per la famiglia $MM$ sono quanto viene riportato in seguito:
#ext_eval_table(
  (
    (name: [PDV1], vals: (1971624.0,0.15,0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [PDV2], vals: (716680.0,0.10,0.157,1.487,6.167,0.254,0.783,0.917,0.964)),
    (name: [PyXiNet $beta" IV"$],vals:(1446014.0,0.18,0.146,1.433,6.161,0.241,0.802,0.926,0.967)),
    (name: [PyXiNet $MM" I"$],vals:(1970643.0,0.36,0.147,1.351,5.98,0.244,0.8,0.926,0.967)),
    (name: [PyXiNet $MM" II"$],vals:(2233197.0,0.38,0.14,1.289,5.771,0.234,0.814,0.933,0.969)),
    (name: [PyXiNet $MM" III"$],vals:(1708499.0,0.35,0.141,1.279,5.851,0.239,0.808,0.927,0.968)),
    (name: [PyXiNet $MM" IV"$],vals:(1839981.0,0.36,0.145,1.25,5.885,0.242,0.798,0.926,0.967)),
  ),
  3,
  [PDV1, PDV2 e PyXiNet $beta" IV"$  vs. PyXiNet $MM$],
)
],breakable: false,width: 100%)
Da quanto si può notare nei risultati, le _performance_ di tutta la famiglia $MM$, superano significativamente quelle di $beta" IV"$.
Si può altresì osservare che il tempo di inferenza è tuttavia almeno raddoppiato rispetto a $beta" IV"$ per tutti i modelli.

Sempre dai risultati ottenuti si può anche capire che solo nella coppia di modelli $MM" I"$ - $MM" II"$, mettere il blocco _LSAM_ dopo la concatenazione ha portato a risultati migliori, infatti nella coppia $MM" III"$ - $MM" IV"$ è successo l'esatto opposto.

#block([
== PyXiNet *$beta$*CBAM
Come discusso nel capitolo _#link(<ch:attention>)[Attention]_ nella @cbam:ch, uno dei vantaggi principali del blocco CBAM è il suo efficiente uso di risorse garantendo comunque un buon miglioramento delle _performance_.
],breakable: false,width: 100%)

Sappiamo tuttavia che, per quanto citato in @CBAM, è particolarmente adatto nell'implementazione all'interno di reti di tipo _ResNet_.
Questa informazione ha quindi guidato il design di un nuovo @decoder, chiamato per l'appunto _CBAM Decoder_ (CBAMD). È stato scelto il @decoder come posto dove applicare più volte il blocco, poichè rispecchia l'architettura di una rete neurale convoluzionale a collo di bottiglia.

#block([
L'architettura del nuovo @decoder è come segue:
#figure(image("../images/architectures/Attention-cbamd.drawio.png",width:350pt),caption: [Architettura del @decoder CBAMD])
],breakable: false,width: 100%)
È osservabile l'approccio residuale dell'_input_, tra due convoluzioni successive.

La famiglia di modelli $beta$CBAM è basata, da come si può evincere dal nome, sui modelli $beta$, in particolare $beta" III"$ e $beta" IV"$, i quali sono stati i modelli con i migliori risultati ottenuti (senza considerare i risultati ottenuti mediante l'applicazione della _self attention_).

#block([
Le architetture dei due modelli derivanti dalle appena discusse scelte sono i seguenti:
#figure(image("../images/architectures/PyXiNet-bcbam1.drawio.png",width:350pt),caption: [Architettura di PyXiNet $beta$CBAM I])
],breakable: false,width: 100%)
#figure(image("../images/architectures/PyXiNet-bcbam2.drawio.png",width:350pt),caption: [Architettura di PyXiNet $beta$CBAM II])

Con la creazione di questi modelli si vuole verificare l'effettivo beneficio che questo modulo di attenzione può apportare in rapporto a quanto viene degradato il tempo di inferenza e a quanto aumenta il numero totale del parametri.


Si può notare che il blocco CBAMD è stato utilizzato come @decoder, solo del primo livello. Questa scelta è stata fatta per non aumentare di troppo i parametri e il tempo di inferenza, facendolo concentrare solamente sulla risoluzione maggiore (la risoluzione che poi verrà effettivamente utilizzata in un contesto reale).

#block([
I risultati di questi due modelli sono riportati nella seguente tabella:
#ext_eval_table(
  (
    (name: [PDV1], vals: (1971624.0,0.15,0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [PDV2], vals: (716680.0,0.10,0.157,1.487,6.167,0.254,0.783,0.917,0.964)),
    (name: [PyXiNet $beta" CBAM I"$],vals:(1250797.0,0.19,0.143,1.296,5.91,0.239,0.805,0.928,0.968)),
    (name: [PyXiNet $beta" CBAM II"$],vals:(1450389.0,0.23,0.147,1.379,5.974,0.239,0.806,0.927,0.968)),
  ),
  2,
  [PDV1 e PDV2 vs. PyXiNet $beta$CBAM],
  res: 102pt
)
],breakable: false,width: 100%)

I risultati di questa famiglia di modelli come si può notare sono molto promettenti, riuscendo ad incrementare notevolmente le _performance_ del modello di partenza, senza impattare troppo fortemente sul tempo di inferenza.


Il modello migliore tra i due, $beta" CBAM I"$ riesce addirittura a stare sotto i 0.20s come tempo di inferenza medio (permettendo un _framerate_ di circa 5 _fps_) e con un numero di parametri inferiore di un $tilde 37%$ rispetto a PDV1.


Un'osservazione interessante che può essere fatta è che rispetto alle controparti della famiglia $beta$, l'aggiunta dei vari blocchi CBAM ha contribuito al massimo ad un incremento del $tilde 0,4%$ sul numero dei parametri.

=== _CBAM PyDNet_

Visti gli enormi progessi che il blocco CBAM ci permette di ottenere, sorge spontanea la messa in questione dell'utilità dell'@encoder composto dal blocco XiNet.

Per verificare questa ipotesi è stata presa l'archiettura originale di PDV2, al fine di verificare se posizionando un blocco CBAM prima di ogni convoluzione della rete, con passaggio dei residuali dall'_output_ della convoluzione precedente, si sarebbero potute ottenere _performance_ interessanti.

#block([
Il @decoder quindi rimande il blocco CBAMD, che però verrà usato ora su tutti i livelli, mentre l'@encoder (_CBAME_) sarà come segue:
#figure(image("../images/architectures/Attention-cbame.drawio.png",width:250pt),caption: [Architettura dell'@encoder _CBAME_])
],breakable: false,width: 100%)

#block([
L'architettura del modello risultante da quanto appena descritto è quindi quanto segue:
#figure(image("../images/architectures/PyDNet-m.drawio.png",width:350pt),caption: [Architettura di _CBAM PyDNet_])
],breakable: false,width: 100%)

#block([
I risultati di questo modello sono riportati in seguito:
#ext_eval_table(
  (
    (name: [PDV1], vals: (1971624.0,0.15,0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [PDV2], vals: (716680.0,0.10,0.157,1.487,6.167,0.254,0.783,0.917,0.964)),
    (name: [_CBAM PyDNet_],vals:(746673.0,0.28,0.167,1.722,6.509,0.251,0.776,0.916,0.965)),
  ),
  2,
  [PDV1 e PDV2 vs. _CBAM PyDNet_],
  res: 102pt
)
],breakable: false,width: 100%)
Per quanto si può notare, posizionare il blocco CBAM dopo ogni convoluzione non fa altro che degradare pesantemente le prestazioni del modello sulla maggior parte delle metriche di valutazione. Si deduce quindi che l'uso di XiNet è sicuramente responsabile per parte del miglioramento delle predizioni dei modelli dove è stato usato..
