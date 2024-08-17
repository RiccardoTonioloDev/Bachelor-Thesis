#pagebreak(to: "odd")
= XiNet <ch:xinet>
Il seguente capitolo parla di XiNet @xinet, una rete neurale convoluzionale profonda, parametrizzata, orientata all'efficienza energetica per compiti relativi alla _computer vision_.
Il _paper_ tratta in primo luogo lo XiConv ovvero un blocco convoluzionale parametrizzato che combina tecniche alternative per riuscire a migliorare l'efficienza energetica, rispetto ad una tradizionale convoluzione, e in secondo luogo XiNet ovvero una rete neurale che combina gli XiConv per riuscire ad ottenere il massimo dei risultati.

Di conseguenza nelle seguenti sezioni verranno trattati:
- @arc:xinet: L'architettura del blocco XiConv e della rete XiNet;
- @val:xinet: La validazione dei risultati espressi nel paper;

== Architettura <arc:xinet>
Il blocco convoluzionale XiConv è detto parametrico in quanto sono in esso impostabili due parametri:
 - $alpha$: è il coefficiente di riduzione dei canali. Se per esempio si utilizza uno XiConv con $C_"in"=16$ e $C_"out"=32$ e l'$alpha$ è impostato a 0.4, i veri canali di _input_ e di _output_ accettati saranno rispettivamente $C_"in"=floor(alpha 16) = 6$ e $C_"out"=floor(alpha 32)= 12$;
 - $gamma$: è il coefficiente di compressione. Questo perchè la convoluzione principale, effettuata dal blocco XiConv è in realtà divisa in due passi:
  + Comprimere il numero di canali dell'_input_ da $alpha C_"in"$ a $(alpha C_"in") / gamma$ mediante una convoluzione _pointwise_ (quindi con @kernel di dimensione $1times 1$);
  + Successivamente applicare la convoluzione principale, con @kernel $3times 3$, che porta il numero di canali da $(alpha C_"in") / gamma$ a $alpha C_"out"$.

#block([
Tra la convoluzione di compressione e quella principale è presente una somma tensoriale tra l'_output_ della convoluzione di compressione e l'_input_ originale passato alla rete, passato in _broadcasting_ e propriamente ridimensionato nei canali (mediante una convoluzione _pointwise_) e nelle dimensioni (mediante un _pooling_ medio adattivo) dal seguente blocco di elaborazione:
#figure(image("../images/architectures/XiNet-broadcast.drawio.png",width:200pt),caption: [Architettura blocco di elaborazione del _broadcasted input_ in @xinet])
],breakable: false,width: 100%)

#linebreak()
Infine, successivamente alla convoluzione principale, viene applicato un blocco di attenzione mista, dove viene combinata l'attenzione sui canali a quella spaziale, il cui _output_ moltiplicherà l'_output_ della convoluzione principale mediante @hadamard (per appunto applicare l'attenzione calcolata), restituendo quindi l'_output_ finale dell'intero blocco.
#block([
L'architettura è la seguente:
#figure(image("../images/architectures/XiNet-XiConv.drawio.png",width:350pt),caption: [Architettura dello XiConv proposto in @xinet])
],breakable: false,width: 100%)

La rete XiNet è invece detta parametrica in quando sono in essa impostabili i seguenti parametri:
  - $beta$: è il coefficiente che controlla il compromesso tra numero di parametri e operazioni. Questo perchè, fatta eccezione del primo blocco XiConv della rete, gli altri blocchi seguono la seguente formula per calcolare i propri canali di _output_ (e di conseguenza i canali di _input_ del blocco successivo):
  $ C_"out"^i = 4 ceil(alpha 2^(D_i-2)(1+((beta-1)i)/N)C_"out"^0) $
  Dove:
   - $C_"out"^i$: rappresenta il numero dei canali di _output_ che avrà il blocco $i$-esimo;
   - $D_i$: rappresenta il numero di volte che l'_input_ è stato dimezzato nelle dimensioni, prima del blocco $i$-esimo;
    - Questo perchè per ogni coppia successiva di blocchi XiConv, il primo blocco va ad applicare la propria convoluzione principale con uno @stride 2 (dimezzando l'altezza e la larghezza del tensore di _input_);
    - Vengono sempre aggiunti due XiConv all'inizio della rete, a prescindere dal numero di XiConv specificati, quindi ci sarà sempre almeno un dimezzamento delle dimensioni.
   - $N$: il numero di XiConv utilizzati nella rete.

#block([
L'architettura della rete è quindi la seguente:
#figure(image("../images/architectures/XiNet.drawio.png",width:250pt),caption: [Architettura di XiNet, composta da $N$ XiConv])
],breakable: false,width: 100%)

Come si può osservare dalla figura e come precedentemente menzionato, l'_input_ della rete viene poi passato in _broadcast_ ad ogni XiConv che la compone.

== Validazione <val:xinet>
Purtroppo non viene menzionato alcun _benchmark_ rigurardo alle prestazioni sul _dataset_ _CIFAR10_, si può tuttavia fare una comparazione con lo stato dell'arte per vedere quanto si discosta da esso.

Si è voluto quindi verificare il risultato andando a svolgere i seguenti passi:
 #block([- Clonare la _repository_ da @gh, mediante il comando:
 ```bash
 git clone https://github.com/micromind-toolkit/micromind.git
 ```],breakable: false,width: 100%)
 #block([- Installare il pacchetto _micromind_ (pacchetto nella quale è presente XiNet) in locale, mediante i seguenti comandi:
 ```bash
 # Per entrare nella directory clonata
 cd ./micromind/
 # Per installare il pacchetto micromind
 pip install -e .
 # Per installare requisiti e dipendenze aggiuntive
 pip install -r ./recipes/image_classification/extra_requirements.txt
 ```],breakable: false,width: 100%)
 #block([- Effettuare l'allenamento con successiva valutazione mediante il seguente comando:
 ```bash
 # Per entrare nella cartella corretta
 cd ./recipes/image_classification/
 # Per eseguire l'allenamento con successiva valutazione
 python train.py cfg/xinet.py
 ```],breakable: false,width: 100%)
 Seguendo i precedenti comandi ho quindi ottenuto un' _accuracy_ del 81.44% con $tilde$7.8 milioni di parametri.
 Il modello presentato in @topcifar è in cima alle classifiche con un'_accuracy_ del 99.61% con 11 milioni di parametri.

 Possiamo quindi constatare come, seppur con $tilde$3 milioni di parametri in meno, riesca ad avvicinarsi ai risultati dello stato dell'arte. Ovviamente XiNet non ha lo scopo di essere migliore in termini di _accuracy_, ma di minimizzare l'impatto energetico del modello, cercando di avere performance quanto più vicine ai modelli con le valutazioni migliori.

 I risultati sono quindi soddisfanceti al fine di provare ad esplorare, con questo modulo, eventuali soluzioni alternative per trovare una soluzione migliore di PDV1 e PDV2 nel campo del @MDE.
