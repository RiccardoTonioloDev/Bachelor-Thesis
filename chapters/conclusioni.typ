#pagebreak(to: "odd")
= Conclusioni <ch:conclusioni>
== Raggiungimento obbiettivi
Si riassumono in seguito gli obbiettivi raggiunti durante il tirocinio:
- Il modello PyDNet V1 è stato verificato nei risultati enunciati dal proprio _paper_ @PyDNetV1;
- È stata migrata l'intera _codebase_ di PyDNet V1 e il modello di PyDNet V2 dal framework @Tensorflow al framework @PyTorch con successo:
  - Sono stati ottenuti gli stessi risultati nell'allenamento a 50 epoche sul _dataset_ KITTI;
  - Sono stati ottenuti gli stessi risultati nell'allenamento a 200 epoche sul _dataset_ KITTI;
  - Sono stati ottenuti gli stessi risultati nell'allenamento a 50 epoche sul _dataset_ CityScapes, con successivo @finetune di 50 epoche sul _dataset_ KITTI;
  - È stata di conseguenza acquisita conoscenza e abilità nell'uso della libreria @PyTorch e del linguaggio Python, specificatamente per la creazione di modelli di _machine learning_ e per la creazione di ambienti d'allenamento;
  - È stata acquisita abilità nell'uso di _cluster_ di calcolo per l'allenamento dei modelli;
- È stata acquisita conoscenza relativamente a meccanismi di attenzione quali la _self attention_ e i _convolutional block attention module_, e ne è stata fatta successivamente l'implementazione in codice;
- È stata acquisita conoscenza nell'implementazione di moduli convoluzionali efficienti, specialmente lo _XiConv_ presentato in @xinet;
- È stata condotta dell'attività di ricerca e sviluppo con l'obbiettivo di implementare valide alternative ai modelli PyDNet nel contesto @embedded:
 - È stato studiato come il cambiamento di vari iperparametri può portare a cambiamenti nelle prestazioni del modello;
 - Sono stati eseguiti un totale di tredici esperimenti, per tredici modelli diversi;
 - Tra i tredici modelli è stato trovato un modello particolarmente interessante ($beta$CBAM I), che con il 37% di parametri in meno rispetto a PyDNet V1, riesce ad essere migliore rispetto a quest'ultimo, nelle metriche di valutazione proposte in @eigen, di un minimo di $tilde 1%$ e di un massimo del $tilde 15%$.

#block([
== Considerazioni
In questa tesi, sono stati esplorati e sviluppati diversi modelli di rete neurale per la predizione della profondità da immagini monoculari, con l'obiettivo di migliorare la precisione e l'efficienza di tali predizioni. Le principali conclusioni raggiunte sono le seguenti:
+ *Migrazione di PyDNet*: La migrazione del modello PyDNet da @Tensorflow a @PyTorch ha dimostrato non solo la fattibilità di tale processo, ma ha anche permesso una più facile integrazione con modelli e blocchi più moderni;
],breakable: false,width: 100%)
+ *Esplorazione di XiNet*: L'introduzione di XiNet, un modello con un'architettura più efficiente, ha portato a miglioramenti significativi nella stima della profondità. Inoltre XiNet ha dimostrato di essere un modello più leggero e performante, quindi adatto per applicazioni su dispositivi con risorse computazionali limitate;
+ *Esplorazione dei Moduli di Attenzione (_CBAM_ e _self attention_)*: l'integrazione di moduli di attenzione come il _Convolutional Block Attention Module_ (_CBAM_) e i meccanismi di _self attention_ si è verificata essere una scelta vincente al fine di migliorare le performance del modello. Si è tuttavia notato come l'utilizzo della seconda non sia ideale per contesti di tipo _embedded_, mentre l'ultilizzo della prima deve essere fatto con criterio per ottenere buoni risultati;
+ *Ricerca e sviluppo di PyXiNet*: Le varianti sperimentali PyXiNet, che combinano le architetture di PyDNet e XiNet con moduli di attenzione, hanno dimostrato progressivi miglioramenti. In particolare PyXiNet $beta$CBAM I ha evidenziato come l'uso combinato di queste tecnologie possa portare a predizioni molto più accurate, con un piccolo compromesso sul tempo di inferenza e sul numero di parametri.
I risultati appena discussi fanno quindi capire che l'uso di tecniche di _deep learning_ per la stima delle profondità da immagini monoculari si è rivelato essere molto promettente, anche in ambienti con un potenziale di risorse molto limitato come il contesto _embedded_.
