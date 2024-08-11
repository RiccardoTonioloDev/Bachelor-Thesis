#pagebreak(to: "odd")
= _Attention_ <ch:attention>
Le reti neurali convoluzionali, sebbene funzionino particolarmente bene per essere addestrate su immagini e video, hanno un problema alla base, ovvero non sono in grado di considerare delle dipendenze a lungo raggio tra i vari _pixel_ o _patch_ del contenuto in analisi.
Alcune delle conseguenze che questo comporta sono:
 - Un campo ricettivo limitato alla dimensione del @kernel;
 - Il campo ricettivo cresce linearmente con la profondità della rete, e quindi potrebbero essere necessarie reti estremamente profonde, perchè il modello riesca ad analizzare un contesto globale;
 - I pesi dopo l'addestramento del modello rimangono fissi e non possono quindi adattarsi dinamicamente al contesto globale dell'immagine.

Tuttavia, negli anni precedenti una particolare tecnica (originariamente pensata per il @nlp) è emersa anche nel campo della _computer vision_, l'attenzione.
I meccanismi di attenzione cercano di captare dipendenze a lungo raggio al fine di migliorare, spesso significativamente, la qualità della predizione.


Il contenuto delle seguenti sezioni è riassumibile come segue:
 - @sa:ch: descrive un potente ma computazionalmente costoso meccanismo di attenzione, il quale però permette miglioramenti significativi nelle predizioni, andando a trovare correlazioni tra ogni _pixel_ o _patch_ del contenuto analizzato;
 - @cbam:ch: descrive un meccanismo di attenzione più leggero, creato apposta per essere utilizzato in reti a collo di bottiglia, cercando di estrarre informazioni significative, prima della riduzione di dimensionalità, analizzando prima la dimensione dei canali, e poi la dimensione spaziale (altezza e larghezza).

#block([
== _Self attention_ <sa:ch>
La _self attention_ è sostanzialmente un meccanismo originariamente creato per riuscire a trovare correlazioni tra le parole di una frase, di modo da assegnare dei pesi a ciascuna di esse per fornire una migliore predizione @aiayn.
],breakable: false,width: 100%)

Tuttavia nel lavoro discusso in @sa, viene descritta un'architettura che permette l'uso di principi simili, al fine di trovare correlazioni ad ampio raggio tra i vari _pixel_ dei contenuti analizzati.
Viene quindi enunciato il concetto di _operatore non locale_ ovvero il blocco presentato in @sa che calcola la risposta in una posizione come una media ponderata delle caratteristiche di tutte le posizioni dell'_input_.
#block([
L'architettura del _Non-local block_ è la seguente:
#figure(image("../images/architectures/Attention-sa.drawio.png",width: 300pt),caption: [Il _Non-local block_, presentato in @sa])
In questo caso "$times.circle$" rappresenta la moltiplicazione tra matrici.
],breakable: false,width: 100%)

#block([
Come in @aiayn, anche in questo blocco si identificano tre entità per riuscire ad ottenere l'attenzione:
 - *Query* (Q): rappresenta la posizione per la quale stiamo calcolando l'_output_ non locale;
],breakable: false,width: 100%)
 - *Key* (K): rappresenta le posizioni con cui la query viene confrontata per determinare la somiglianza;
 - *Value* (V): rappresenta le informazioni che vengono aggregate per formare l'_output_ finale.

Si vuole far notare che in questo caso le tre matrici sono matrici della dimensione di $"numCanali" times ("altezza"dot"larghezza")$, questo per far si che le moltiplicazioni matriciali combinino il valore di un _pixel_ con tutti gli altri.

La prima moltiplicazione tra matrici $Q dot K$ rappresenta il calcolo dell'affinità, ovvero calcolare i pesi di attenzione che determinano l'influenza di ogni _pixel_ (la colonna di $K$ presa in considerazione) sul _pixel_ in analisi (la riga di $Q$ presa in considerazione).
Successivamente le affinità calcolate vengono normalizzate tramite una funzione _softmax_ per ottenere i veri pesi di attenzione $A$.

Il prodotto matriciale $A dot V$ invece va a creare un'aggregazione ponderata delle informazioni, dando quindi luogo alla matrice di attenzione $Y$.

Questa viene poi moltiplicata per un peso apprendibile (equivalente ad applicare una convoluzione $1 times 1 times 1$), anche chiamato $gamma$, che serve per apprendere quanto applicare dell'attenzione calcolata.

Essendo in seguito fatta una somma tensoriale tra l'_input_ (anche detto _residual_, come menzionato in @resnet) e il risultato del calcolo dell'attenzione, il $gamma$ può anche partire da 0, andando quindi inizialmente a non applicare attenzione, questo per stabilizzare inizialmente il _training_ del modello.


#block([
== _Convolutional Block Attention Module_ <cbam:ch>
Il _Convolutional Block Attention Module_ (CBAM), presentato in @CBAM è un blocco fortemente basato sulle convoluzioni, che combina la _channel_ e la _spacial attention_, per migliorare le predizioni del modello.
],breakable: false,width: 100%)
#block([
Elementi di particolare interesse per questo modello sono:
 - La capacità di riuscire comunque, anche se non come per la _self attention_, nel catturare relazioni globali;
],breakable: false,width: 100%)
 - Aumentare l'efficienza computazionale poichè aggiunge, rispetto ad altri meccanismi di attenzione, solo un discreto numero di parametri alla rete e nessuna moltiplicazione matriciale.

Il blocco CBAM è principalmente composto da due sotto-moduli, uno per calcolare l'attenzione sui canali, che una volta combinato mediante un @hadamard con il _residual_ dell'_input_, viene passato al modulo di attenzione spaziale.
L'_output_ di attenzione spaziale viene poi combinato con il _residual_ dell'_output_ del modulo di attenzione sui canali mediante un @hadamard, generando quindi l'_output_ con l'attenzione applicata.
#block([
L'architettura del blocco CBAM è quindi la seguente:
#figure(image("../images/architectures/Attention-CBAM.drawio.png",width: 300pt),caption: [Il _Convolutional Block Attention Module_, presentato in @CBAM])
],breakable: false,width: 100%)

Il modulo di attenzione sui canali, opera sulla spazialità del tensore (altezza e larghezza) mediante _pooling_ massimo e _pooling_ medio, andando quindi a creare due vettori, i quali rappresenteranno il valore massimo e la media di ciascun canale del tensore di _input_.


Successivamente entrambi questi vettori vengono passati attraverso un _multi layer perceptron_ da tre strati, con il primo e l'ultimo dalle medesime dimensioni dell'_input_, mentre quello centrale, essendo più piccolo, applica un fattore di compressione.

Entrambi i vettori risultanti vengono poi sommati tra loro e passati attraverso una sigmoide, la quale genererà il vettore di attenzione sui canali.

#block([
L'architettura è la seguente:
#figure(image("../images/architectures/Attention-CBAM-ca.drawio.png",width: 300pt),caption: [Il modulo di attenzione sui canali, presentato in @CBAM])
],breakable: false,width: 100%)

Il modulo di attenzione spaziale invece, opera sulla profondità del tensore (i canali) mediante _pooling_ massimo e _pooling_ medio, andando quindi a generare due matrici, le quali rappresenteranno i valori massimi e i valori medi sui canali, per ciascun elemento nelle coordinate dell'altezza e della larghezza.


Queste matrici vengono concatenate sulla dimensione dei canali e successivamente passate attraverso una convoluzione con @kernel di dimensione $3times 3$. Infine l'_output_ di questa operazione viene passato attraverso una sigmoide che genererà quindi la matrice di attenzione sulla spazialità.

#block([
Questa è quindi l'architettura:
#figure(image("../images/architectures/Attention-CBAM-sa.drawio.png",width: 300pt),caption: [Il modulo di attenzione sulla spazialità, presentato in @CBAM])
],breakable: false,width: 100%)

Come spesso viene fatto, in @CBAM viene anche citata la possibilità di aggiungere uno step dove all'attenzione calcolata viene poi sommato il _residual_ dell'_input_, al fine di stabilizzare l'apprendimento.
Questo lo rende particolarmente interessante per la famiglia delle reti convoluzionali ResNet @resnet, in quanto fortemente basata su questo meccanismo.


Si può quindi implementare un approccio ResNet, ponendo il blocco CBAM subito dopo una convoluzione, per poi sommare il suo _output_ all'_output_ della convoluzione iniziale.
#block([
L'architectura proposta è quindi la seguente:
#figure(image("../images/architectures/Attention-CBAM-resnet.drawio.png",width: 200pt),caption: [Applicazione del blocco CBAM con approccio _ResNet_])
],breakable: false,width: 100%)
