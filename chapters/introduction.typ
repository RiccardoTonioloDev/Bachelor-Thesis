#import "@preview/glossarium:0.4.1": gls

#pagebreak(to: "odd")
= Introduzione


== Stimare le profondità
L'avere la possibilità di misurare la profondità di un'immagine e quindi potenzialmente la profondità di ciascun frame all'interno di uno _streaming_ video, apre le porte alla risoluzione di una vasta gamma di problemi che richiedono una stima precisa delle distanze tra gli oggetti all'interno di un determinato campo visivo.

Alcuni problemi appartenenti a questa classe includono:
 - Prevenzione dalle collisioni: lo sviluppo di algoritmi che, controllando un oggetto fisico in movimento, cercano di evitare impatti con altre entità lungo il suo percorso;
 - Percezione tridimensionale: una serie di algoritmi che analizzano dati di profondità per ricostruire una scena tridimensionale dell'ambiente circostante;
 - Realtà aumentata: un settore che prevede, attraverso l'uso di visori e altri dispositivi, il posizionamento di elementi grafici virtuali nel campo visivo dell'utente in modo che si integrino naturalmente con la realtà.

Esistono soluzioni _hardware_ per avere delle misurazioni di profondità con alta precisione. I sistemi _hardware_ più famosi ed utilizzati sono:
 - Sensori di profondità, come ad esempio il @LiDAR;
 - Sistemi di fotografia stereoscopica, come ad esempio la @FotoStereo.
Il problema con questi sistemi hardware risiede, tuttavia, in due aspetti principali:
 - Nel caso dei sensori @LiDAR, il costo elevato può rendere il prodotto finale meno competitivo sul mercato o ridurre i margini di profitto per l'azienda che lo fornisce. Ad esempio, se si volesse integrare un @LiDAR in un robot da giardino, il costo aggiuntivo potrebbe influire negativamente sulla competitività, relativa al prezzo, del prodotto.
 - D'altro canto, l'integrazione di un sistema basato su fotocamere stereoscopiche presenta altre sfide pratiche. Non è sempre semplice trovare spazio per le due fotocamere necessarie e gestire la loro calibrazione può essere complicato. Questi problemi possono limitare l'applicabilità della tecnologia in ambienti dove lo spazio è ristretto o dove la calibrazione precisa è difficile da ottenere o mantenere.

== _Monocular Depth Estimation_
Un'altra soluzione promettente è quella di sviluppare una rete neurale in grado di prevedere correttamente le profondità di un'immagine a partire da una singola immagine in _input_, un approccio noto come _Monocular Depth Estimation_ (@MDE). Se riuscisse ad essere realizzata con successo, tale soluzione permetterebbe il vantaggio di utilizzare una sola fotocamera, con il potenziale di un sensore @LiDAR.

Tuttavia, questo tipo di approccio, oltre alle tradizionali sfide del _machine learning_, come la ricerca di dataset adeguati e la costruzione di un modello adatto, presenta ulteriori difficoltà, in particolare nei sistemi @embedded, che hanno vincoli significativi in termini di memoria, energia e di potenza computazionale.

Modello particolarmente interessante di _machine learning_ è PyDNet, in quanto fortemente leggero (meno di 2 milioni di parametri) e discretamente performante, considerata la sua dimensione. Per questo motivo è stato scelto per essere il modello di riferimento da usare come punto di partenza del tirocinio.

== Obbiettivi
Il tirocinio si è quindi strutturato su due macro obbiettivi:
 + Studiare come il problema di @MDE è stato affrontato da PyDNet V1 e V2:
  - Studiarne i _paper_ e i relativi codici;
  - Inserire nella procedura di allenamento un sistema di _logging_ per analizzare i costi provenienti dalle varie _loss function_;
  - Riprodurre l'allenamento di PyDNet V1 per verificare i risultati enunciati nel _paper_;
  - Migrare tutto il codice di PyDNet V1 e il codice del modello di PyDNet V2 da @Tensorflow a @PyTorch;
  - Riprodurre l'allenamento di PyDNet V1 nella sua versione migrata per verificare che si ottengano gli stessi risultati e che quindi la versione migrata sia equivalente all'originale.
 + Esplorare soluzioni per ottenere modelli migliori in termini di efficacia e efficienza:
  - Verificare come variano le prestazioni di PyDNet V1 al variare degli iperparametri;
  - Esplorare eventuali nuove tecniche e strategie al fine di creare un modello migliore nel compito di @MDE.

== Organizzazione del documento

Relativamente al documento sono state adottate le seguenti convenzioni tipografiche:
- Gli acronimi, le abbreviazioni e i termini ambigui o di uso non comune menzionati vengono definiti nel glossario, situato alla fine del presente documento;
- I _link_ ipertestuali interni al documento utilizzano la seguente formattazione: #text(fill: blue.darken(70%),weight: "medium","parola")\;
- Ogni dichiarazione, risultato o prodotto proveniente da letteratura scientifica, viene accompagnato da una citazione a tale fonte mediante un indice, utilizzabile per rintracciare la fonte di tale dichiarazione mediante la bibliografia, situata alla fine del presente documento;
- I termini in lingua straniera o facenti parti del gergo tecnico sono evidenziati con il carattere _corsivo_.

La presente tesi è organizzata come segue:
  - #link(<ch:pydnet>)[Il secondo capitolo]: descrive in primo luogo l'architettura, il funzionamento e l'addestramento di PyDNet V1, in secondo luogo descrive il processo di migrazione del modello da @Tensorflow a @PyTorch e la successiva verifica di validità del prodotto del processo di migrazione.
  - #link(<ch:xinet>)[Il terzo capitolo]: descrive l'architettura, il funzionamento e la validazione di XiNet, una rete neurale convoluzionale parametrica creata per essere particolarmente efficiente in termini di consumo energetico.
  - #link(<ch:attention>)[Il quarto capitolo]: descrive l'architettura, il funzionamento e i casi d'uso di meccanismi di attenzione quali la _self attention_ e i _convolutional block attention module_ nell'ambito della _computer vision_.
  - #link(<ch:pyxinet>)[Il quinto capitolo]: descrive l'approccio esplorativo nella costruzione di PyXiNet, investigando vari tipi di architetture, progettate mediante iterazioni successive basate sui risultati delle precedenti, al fine di trovare una miglior alternativa a PyDNet.
  - #link(<ch:risultati>)[Il sesto capitolo]: analizza i risultati ottenuti dai vari modelli di PyXiNet, sia dal punto di vista quantitativo che qualitativo;
  - #link(<ch:conclusioni>)[Il settimo capitolo]: descrive i traguardi raggiunti e le conclusioni deducibili.
