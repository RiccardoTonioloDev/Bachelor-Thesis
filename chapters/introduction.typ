#import "@preview/glossarium:0.4.1": gls

= Introduzione


== Stimare le profondità
L'avere la possibilità di misurare la profondità di un'immagine e, quindi, potenzialmente la profondità di ciascun frame all'interno di uno streaming video, apre le porte alla risoluzione di una vasta gamma di problemi che richiedono una stima precisa delle distanze tra gli oggetti all'interno di un determinato campo visivo.

Alcuni problemi appartenenti a questa classe includono:
 - Prevenzione delle collisioni: lo sviluppo di algoritmi che, controllando un oggetto fisico in movimento, cercano di evitare impatti con altre entità lungo il suo percorso;
 - Percezione tridimensionale: una serie di algoritmi che analizzano dati di profondità per ricostruire una scena tridimensionale dell'ambiente circostante;
 - Realtà aumentata: un settore che prevede, attraverso l'uso di visori e altri dispositivi, il posizionamento di elementi grafici virtuali nel campo visivo dell'utente in modo che si integrino naturalmente con la realtà presente.

Esistono soluzioni hardware per avere delle misurazioni di profondità con alta precisione. I sistemi hardware più famosi ed utilizzati sono:
 - Sensori di profondità, come ad esempio il @LiDAR;
 - Sistemi di fotografia stereoscopica: come ad esempio la @FotoStereo.
Il problema con questi sistemi hardware risiede, tuttavia, in due aspetti principali:
 - Nel caso dei sensori LiDAR, il costo elevato può rendere il prodotto finale meno competitivo sul mercato o ridurre i margini di profitto per l'azienda che lo fornisce. Ad esempio, se si volesse integrare un LiDAR in un robot da giardino, il costo aggiuntivo potrebbe influire negativamente sulla competitività del prodotto.
 - D'altro canto, l'integrazione di un sistema basato su fotocamere stereoscopiche presenta altre sfide pratiche. Non è sempre semplice trovare spazio per le due fotocamere necessarie e gestire la loro calibrazione può essere complicato. Questi problemi possono limitare l'applicabilità della tecnologia in ambienti dove lo spazio è ristretto o dove la calibrazione precisa è difficile da ottenere.

== _Monocular Depth Estimation_
Un'altra soluzione promettente è quella di sviluppare una rete neurale in grado di prevedere correttamente le profondità di un'immagine a partire da una singola immagine di input, un approccio noto come _Monocular Depth Estimation_ (@MDE). Se riuscisse ad essere realizzata con successo, tale soluzione permetterebbe il vantaggio di utilizzare una sola fotocamera, con il potenziale di un sensore LiDAR.

Tuttavia, questo tipo di approccio, oltre alle tradizionali sfide del _machine learning_, come la ricerca di dataset adeguati e la costruzione di un modello adatto, presenta ulteriori difficoltà, in particolare nei sistemi @embedded, che hanno vincoli significativi in termini di memoria, energia e di potenza computazionale.

Modello particolarmente interessante di _machine learning_ è PyDNet @PyDNetV1@PyDNetV2, in quanto fortemente leggero (meno di 2 milioni di parametri) e decentemente performante per la sua dimensione. Per questo motivo è stato scelto per essere il modello di riferimento da usare come punto di partenza del tirocinio.

== Obbiettivi
Il tirocinio si è quindi strutturato su due macro obbiettivi:
 + Studiare come il problema di @MDE è stato affrontato da PyDNet V1 @PyDNetV1 e V2 @PyDNetV2:
  - Studiarne i paper e i relativi codici;
  - Inserire nella procedura di allenamento un sistema di _logging_ per analizzare i costi provenienti dalle varie _loss function_;
  - Riprodurre l'allenamento di @PyDNetV1 per verificare i risultati enunciati nel _paper_;
  - Migrare tutto il codice di @PyDNetV1 e il codice del modello di @PyDNetV2 da @Tensorflow a @PyTorch;
  - Riprodurre l'allenamento di @PyDNetV1 nella sua versione migrata per verificare che si ottengano gli stessi risultati e che quindi la versione migrata sia equivalente all'originale.
 + Esplorare soluzioni per ottenere modelli migliori in termini di efficacia e efficienza:
  - Verificare come variano le prestazioni di @PyDNetV1 al variare degli iperparametri;
  - Esplorare eventuali nuove tecniche e strategie al fine di creare un modello migliore nel compito di @MDE.

== Organizzazione del documento

Relativamente al documento sono state adottate le seguenti convenzioni tipografiche:
- gli acronimi, le abbreviazioni e i termini ambigui o di uso non comune menzionati vengono definiti nel glossario, situato alla fine del presente documento;
- I termini riportati nel glossario utilizzano la seguente formattazione: #text(fill: blue.darken(60%),weight: "semibold","parola")\;
- Dopo la prima citazione del soggetto di un articolo o di un testo di riferimento ritrovabile in bibliografia, questo verrà poi menzionato solo dal suo numero di riferimento (i.e. @PyDNetV1) e non più dal suo nome;
- i termini in lingua straniera o facenti parti del gergo tecnico sono evidenziati con il carattere _corsivo_.

Relativamente ai capitoli:
// #link(<cap:processi-metodologie>)[Il secondo capitolo]: descrive.
// #link(<cap:descrizione-stage>)[Il terzo capitolo]: descrive.
// #link(<cap:progettazione-codifica>)[Il quarto capitolo]: descrive.
// #link(<cap:verifica-validazione>)[Il quint capitolo]: descrive.
// #link(<cap:conclusioni>)[Il sesto capitolo]: descrive.