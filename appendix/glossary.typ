#set heading(numbering: none)
#import "@preview/glossarium:0.4.1": print-glossary
#pagebreak()
= Glossario
#print-glossary(
  (
    (key: "MDE", short: "MDE", desc: "Monocular depth estimation, è il campo che si occupa di trovare soluzioni in grado di stimare le profondità a partire da una sola immagine in input."),
    (key: "LiDAR", short: "LiDAR", desc: [Strumento di telerilevamento che permette di determinare la distanza di una superficie utilizzando un impulso laser.]),
    (key: "FotoStereo", short: "stereocamera", desc: [Particolari tipi di fotocamere dotate di due obbiettivi paralleli. Questo tipo di fotocamera viene utilizzata per ottenere due immagini della stessa scena a una distanza nota. Queste immagini vengono successivamente introdotte in un algoritmo che, cercando di trovare la corrispondenza dei vari pixel tra le due immagini e conoscendo la distanza tra i due obbiettivi, triangola la profondità di tali pixel.]),
    (key: "embedded", short: "embedded", desc: [Un dispositivo si dice _embedded_ quanto, è progettato per eseguire operazioni di elaborazione e analisi dei dati localmente, vicino alla fonte dei dati stessi, piuttosto che inviarli a un server centrale o al cloud.]),
    (key: "Tensorflow", short: "Tensorflow", desc: [Libreria _open source_ per l'apprendimento automatico sviluppata da Google Brain.]),
    (key: "PyTorch", short: "PyTorch", desc: [Libreria _open source_ per l'apprendimento automatico sviluppata da Meta AI.]),
    (key: "Python", short: "Python", desc: [Linguaggio di programmazione interpretato con tipizzazione dinamica e forte, diventato standard per la scrittura di codice orientato al _machine learning_ e alla _data science_.]),
    (key: "pip", short: "pip", desc: [_Package-management system_ scritto in _Python_ e usato per installare e gestire pacchetti software.]),
    (key: "Anaconda", short: "Anaconda", desc: [Distribuzione del linguaggio di programmazione Python per la computazione scientifica, che cerca di semplificare la gestione dei pacchetti e la messa in produzione del software.]),
    (key: "Wandb", short: "Wandb", desc: [Sistema online per il logging e la gestione dei log mediante _report_, per registrare l'andamento di variabili di interesse, specialmente utilizzato nel campo del _machine learning_.]),
    (key: "cuDNN", short: "cuDNN", desc: [*cu*\da *D*\eep *N*\eural *N*\etwork è una libreria sviluppata da NVIDIA, che espone una serie di primitive per permettere l'esecuzione di codice accellerata su schede video NVIDIA, specialmente utile per reti neurali profonde.]),
    (key: "CUDA", short: "CUDA", desc: [*C*\ompute *U*\nified *D*\evice *A*\rchitecture è un'architettura hardware per l'elaborazione parallela creata da NVIDIA.]),
    (key: "disparità", short: "disparità", desc: [Nel contesto delle fotocamere stereoscopiche, la disparità è la differenza nella posizione orizzontale di un pixel tra due immagini catturate da due fotocamere posizionate ad una certa distanza l'una dall'altra. Questa differenza è causata dalla variazione di angolo con cui ogni fotocamera vede gli oggetti nella scena.]),
    (key: "encoder", short: "encoder", desc: [Rete neurale che comprime un input in una rappresentazione di dimensioni ridotte, estraendo le caratteristiche essenziali.]),
    (key: "decoder", short: "decoder", desc: [Rete neurale che ha lo scopo di analizzare un input compresso da un @encoder, per generare la predizione.]),
    (key: "kernel", short: "kernel", desc: [Matrice di pesi utilizzata per filtrare l'immagine, eseguendo operazioni di somma e prodotto su sotto-regioni dell'immagine per estrarre caratteristiche come bordi, texture e dettagli.]),
    (key:"stride",short:"stride",desc:[Il passo con cui il @kernel si sposta sull'immagine, determinando la distanza tra le posizioni successive del @kernel.]),
    (key:"fmap",short:"feature map",desc:[Il risultato delle operazioni del kernel sull'immagine, rappresentando le caratteristiche rilevate come bordi e texture.]),
    (key:"adam",short:"Adam",desc:[L'Adaptive Moment Estimation è un ottimizzatore che utilizzando stime adattive del momento di primo e secondo ordine (media e varianza dei gradienti) aggiorna i pesi, migliorando la velocità e stabilità della convergenza durante l'addestramento dei modelli di apprendimento profondo.]),
    (key:"linter",short:"linter",desc:[Strumento che analizza il codice sorgente per individuare errori, bug, stile non conforme e altri problemi di qualità.]),
  )
)