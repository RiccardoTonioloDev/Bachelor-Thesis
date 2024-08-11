#import "../config/constants.typ": abstract
#import "../config/variables.typ": *
#pagebreak(to: "odd")
#set page(numbering: "i")
#counter(page).update(1)

#v(10em)

#align(center)[#text(24pt, weight: "thin", abstract)]

#v(2em)
#set par(first-line-indent: 0pt)
Questa tesi esplora la predizione della profondità utilizzando tecniche di _deep learning_ con immagini provenienti da una telecamera monoculare. Durante uno stage di 320 ore presso il gruppo di ricerca VIMP Group dell'Università degli Studi di Padova, sono stati sviluppati, implementati e validati diversi modelli di rete neurale, tra cui PyDNet e XiNet. È stata successivamente creata PyXiNet, una famiglia di modelli, con l'obiettivo di migliorare la precisione e l'efficienza della stima della profondità.

In particolare, la tesi si è focalizzata su:
- PyDNet: Migrazione del modello da TensorFlow a PyTorch con successiva validazione dei risultati;
- XiNet: Studio, validazione e impiego di un modello con un'architettura più efficiente;
- Moduli di Attenzione: Studio, implementazione e impiego di moduli di attenzione per migliorare le prestazioni dei modelli;
- PyXiNet: esplorazione di combinazioni dei moduli e modelli precedentemente citati.
I risultati dimostrano che l'uso di tecniche di _deep learning_ per la stima della profondità da immagini monoculari è promettente, con miglioramenti significativi apportati dall'integrazione di moduli di attenzione.
#v(1fr)
