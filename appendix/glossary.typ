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
  )
)