#import "@preview/codly:1.0.0": *
#pagebreak()
= PyDNet
PyDNet(*Py*\ramidal *D*\epth *Net*\work) è una famiglia di modelli composta da due versioni @PyDNetV1@PyDNetV2, che cercano di risolvere il problema della @MDE mediante un approccio non supervisionato.  con circa 2 milioni di parametri in @PyDNetV1 e circa 700.000 in @PyDNetV2.

Una peculiarità di questa famiglia di modelli è il numero di parametri estremamente basso, con circa 2 milioni di parametri in @PyDNetV1 e circa 700.000 in @PyDNetV2.
L'obbiettivo di questi modelli infatti, è quello di essere abbastanza leggeri da poter essere direttamente eseguiti su un processore, senza il supporto di una scheda grafica, per poter essere integrati in sistemi @embedded, come ad esempio nei cellulari @MDEInWild.

Questa sua caratteristica li rende molto interessanti come punto di partenza per sperimentare con tecniche innovative o apportare modifiche ai loro blocchi, di modo da migliorarne le prestazioni.

Tuttavia, essendo modelli relativamente datati, sono stati scritti in una versione di @Tensorflow ormai deprecata, il che li rende non più facilmente utilizzabili. I sottocapitoli seguenti descriveranno quindi l'intero processo di migrazione da @Tensorflow all'ultima versione di @PyTorch.

== Architettura del modello
@PyDNetV1 è una rete convoluzionale profonda strutturata su sei livelli, dove ogni livello riceve l' input dal livello superiore (fatta eccezione per il primo livello che riceve l'immagine di input), elabora l'input ricevuto mediante un @encoder, che restituisce un output il quale farà da input al livello inferiore (fatta eccezione per l'ultimo livello).
L'output dell'@encoder viene poi concatenato all'output del livello inferiore sulla dimensione dei canali, e passato ad un @decoder, il cui output verrà:
 - Passato attraverso la funzione di attivazione sigmoide, il cui output corrisponderà alla mappa di @disparità del livello preso in analisi;
 - Passato attraverso una convoluzione trasposta con @kernel di dimensione $2 times 2$ e @stride 2, per raddoppiare le dimensioni di altezza e larghezza del tensore in ingresso, il cui output verrà passato al livello superiore (eccezione fatta per il primo livello, che ha come unico output il risultato la mappa di @disparità del livello).

L'architettura è quindi la seguente:
#figure(
  image("../images/architectures/PyDNetV1.drawio.png",width: 250pt),
  caption: [Architettura del modello @PyDNetV1]
)

L'@encoder è composto da una convoluzione con @kernel di dimensione $3 times 3$ e @stride 2, che va quindi a ridurre l'altezza e la larghezza del tensore di ingresso della metà, seguita da una convoluzione con @kernel di dimensione $3 times 3$.
L'@encoder del livello $i, forall i in {1,2,3,4,5,6}$ avrà quindi come tensore in uscita un tensore con dimensioni di altezza e larghezza pari a $1 / 2^i$ delle dimensioni dell'input iniziale.
In più, andando dal primo al sesto livello, i canali di uscita prodotti dalla seconda convoluzione dell'encoder sono 16, 32, 64, 96, 128, 196.

L'architettura dell'encoder è quindi la seguente:
#figure(
  image("../images/architectures/PyDNetV1-encoder.drawio.png",width: 250pt),
  caption: [#link(<encoder>)[Encoder] del modello @PyDNetV1.]
)

Il @decoder invece è composto da una successione di quattro convoluzioni con @kernel di dimensione $3 times 3$ e @stride 2, i quali rispettivamente producono delle @fmap con un numero di canali pari a 96, 64, 32 e 8, mantenendo invece le dimensioni di altezza e larghezza dell'_input_.
L'architettura del @decoder è quindi la seguente:
#figure(
  image("../images/architectures/PyDNetV1-decoder.drawio.png",width: 250pt),
  caption: [#link(<decoder>)[Decoder] del modello @PyDNetV1.]
)

Successivamente ad ogni convoluzione, tranne per l'ultima del decoder, viene applicata la funzione di attivazione _leaky ReLU_ con coefficiente di crescita per la parte negativa di 0,2.

== Funzionamento
Lo scopo di @PyDNetV1@PyDNetV2 è quello di riuscire nel compito di @MDE. Per farlo @PyDNetV1@PyDNetV2 imparano, date due immagini stereo dello stesso scenario, ad applicare uno sfasamento a ogni pixel dell'immagine di sinistra, in modo da renderla quanto più simile possibile alla corrispondente immagine di destra, e uno sfasamento a ogni pixel dell'immagine di destra per renderla quanto più simile possibile alla corrispondente immagine di sinistra.

#linebreak()

Quanto enunciato però viene fatto solamente durante l'addestramento del modello, poichè durante l'inferenza ogni immagine di _input_ viene introdotta nel modello come immagine di sinistra. Si prende infatti come _output_ del modello, solo il primo canale delle @fmap uscenti dalla sigmoide del livello, che infatti corrisponde alla mappa di @disparità per le immagini di sinistra.
Questa strategia funziona perchè progressivamente, durante l'allenamento, viene forzato un allineamento tra le predizioni per le immagini di sinistra e quelle di destra, rendendo ambivalente l'_output_ del modello sul canale di sinistra rispetto a quello di destra.

=== Funzioni di perdita

#linebreak()

_*Image error loss*_ ($cal(L)_"ap"$):
#figure($ cal(L)_"ap"^l = 1/N sum_(i,j) alpha (1-"SSIM"(I^l_(i,j),tilde(I)^l_(i,j)))/2 + (1-alpha)norm((I^l_(i,j),tilde(I)^l_(i,j)))_1 $,caption: [_Image error loss_ calcolata per l'immagine di sinistra.])

Questa è la funzione di perdita che penalizza quanto più l'immagine originale di sinistra $I^l$ è diversa dall'immagine di destra con lo sfasamento applicato $tilde(I)^l$ (appunto per diventare l'immagine di sinistra).
La prima parte della sommatoria, utilizzando la funzione SSIM, serve per  misurare la similarità strutturale tra le due immagini, mentre con la seconda parte, mediante la norma 1, serve per misurare la distanza tra i corrispondenti pixel delle due immagini.
Il parametro $alpha$ viene usato per regolare il peso tra la prima e la seconda parte, il quale viene impostato a 0,85, andando quindi a dare molta più importanza alla prima.

#linebreak()

_*Disparity smoothness loss*_ ($cal(L)_"ds"$):
#figure($ cal(L)_"ds"^l = 1/N sum_(i,j) abs(delta_x d^l_(i,j))e^(-norm(delta_x I^l_(i,j))) + abs(delta_y d^l_(i,j))e^(-norm(delta_y I^l_(i,j))) $,caption: [_Disparity smoothness loss_ calcolata per l'immagine di sinistra.])

In questo caso invece, questa funzione di perdita disincentiva discontinuità di profondità calcolate mediante norma 1, a meno che non ci sia una discontinuità sul gradiente dell'immagine.
La prima parte della sommatoria analizza le discontinuità sull'asse orizontale, mentre la seconda parte sull'asse verticale.

#linebreak()

_*Left-right consistency loss*_ ($cal(L)_"lr"$):
#figure($ cal(L)^l_"lr" = 1/N sum_(i,j)abs(d^l_(i,j)-d^r_(i,j+d^l_(i,j))) $,caption: [_Left-right consistency loss_ calcolata per l'immagine di sinistra.])

Infine, l'ultima funzione di perdita, formula nota nel campo degli algoritmi stereo, serve per forzare coerenza tra le predizioni di @disparità di destra $d^r$ e di sinistra $d^l$.


#linebreak()

*Funzione di perdita completa* ($cal(L)_"lr"$):

Le precedenti funzioni di perdita vengono calcolate anche per l'immagine di sinistra, per poi essere combinate nel seguente modo, creando la funzione di perdita completa $cal(L)_"s"$:
$ cal(L)_"s" = alpha_"ap" (cal(L)^l_"ap"+cal(L)^r_"ap") + alpha_"ds" (cal(L)^l_"ds"+cal(L)^r_"ds") + alpha_"lr" (cal(L)^l_"lr"+cal(L)^r_"lr")  $

I pesi per i vari termini della funzione completa sono impostati nel seguente modo:
 - $alpha_"ap" = 1$;
 - $alpha_"lr" = 1$;
 - $alpha_"ds" = 1/r$ dove $r$ è il fattore di scala a ciascun livello di risoluzione.

=== Allenamento
Per l'allenamento viene utilizzato l'ottimizzatore @adam con i seguenti parametri: $beta_1=0.9$, $beta_2=0.999$ e $epsilon=10^(-8)$.

Il _learning rate_ parte da $10^-4$ per il primo 60% delle epoche, e viene dimezzato ogni 20% successivo.

Infine vengono applicate, con una probabilità del 50%, le seguenti _data augmentation_:
 - Capovolgimento orizontale delle immagini;
 - Trasformazione delle immagini: 
  - Correzione gamma;
  - Correzione luminosità;
  - Sfasamento dei colori.

Il dataset viene suddiviso in batch da 8 immagini, e verranno eseguite un totale di 50 epoche di allenamento.

== Configurazione dell'ambiente
La versione di Tensorflow usata per l'ambiente di allenamento e per i modelli @PyDNetV1@PyDNetV2 è la `1.8`, ormai deprecata da anni e non più scaricabile dai package manager come @pip o @Anaconda.
Una versione retrocompatibile con la `1.8` e ancora scaricabile tramite @pip è la `1.13.2`, che però dipende da una versione del pacchetto `protobuf` non più disponibile. Fortunatamente, la versione `3.20` di `protobuf` è ancora scaricabile da @pip e compatibile con Tensorflow `1.13.2`.
Il codice si basava anche su una versione deprecata del pacchetto `scipy`, facilmente sostituibile con la versione `1.2`, ancora disponibile tramite @pip.
L'ultima configurazione necessaria per eseguire il codice è la corretta versione di @Python, ancora scaricabile e che riesca ad essere compatibile con tutti i pacchetti sopra menzionati e con le relative dipendenze. Grazie ad @Anaconda è possibile scaricare la versione `3.7` che è utilizzabile per questo scopo.

I comandi da terminale per ottenere la seguente configurazione, previa corretta installazione di @pip e @Anaconda sono:
#codly(languages: (
  bash: (name: "Bash", color: gray)
),number-format: none, zebra-fill: none)
```bash
# Creare l'ambiente Anaconda (usare il nome che si preferisce)
conda create -n <nomeAmbiente> python=3.7
# Attivare l'ambiente Antaconda creato
conda activate <nomeAmbiente>
# Installare i paccheti richiesti
pip install protobuf==3.20 tensorflow_gpu=1.13.2 scipy=1.2 matplotlib wandb
```
Tra i pacchetti installati mediante @pip è presente anche @Wandb, un sistema che permette di registrare, gestire e catalogare il _plot_ delle _loss function_ per i vari esperimenti che verranno condotti.

#linebreak()
Il codice è tecnicamente eseguibile, solo se si dispone di una sceda video all'interno della macchina. Tuttavia il cluster del dipartimento di matematica, ha versioni troppo aggiornate dei driver @CUDA e della libreria @cuDNN, per essere utilizzabili da @Tensorflow `1.13.2`.
Ho quindi ritrovato le versioni adatte: per @CUDA, la versione `10.0`, scaricabile seguendo le istruzioni presenti nell'#link("https://developer.nvidia.com/cuda-toolkit-archive","archivio CUDA"), e per @cuDNN, la versione `7.4.2`, scaricabile seguendo le istruzioni presenti nell'#link("https://developer.nvidia.com/rdp/cudnn-archive","archivio cuDNN").

Infine bisogna scaricare il dataset KITTI, dataset utilizzato per l'addestramento e valutazione del modello, utilizzando questo comando:
```bash
wget -i utils/kitti_archives_to_download.txt -P ~/my/output/folder/
```
Successivamente bisogna effettuare l'_unzip_ di tutte le cartelle compresse e convertire tutte le immagini da `.png` a `.jpg`, mediante i seguenti comandi:
```bash
cd <pathCartellaDataset>
find <pathCartellaDataset> -name '*.zip' | parallel 'unzip -d {.} {}'
find <pathCartellaDataset> -name '*.png' | parallel 'convert {.}.png {.}.jpg && rm {}'
```
Dove `<pathCartellaDataset>` è il path che conduce alle cartelle `.zip` precedentemente scaricate.

== Validazione
Seguendo le istruzioni ritrovabili nella _repository_ di @PyDNetV1 e @monodepth, si possono recuperare le seguenti istruzioni per effettuare l'esecuzione dell'allenamento, il _testing_ e la successiva valutazione di @PyDNetV1.

Quindi, una volta impostata una _codebase_ come scritto nella documentazione di @PyDNetV1 possono essere utilizzati i seguenti comandi.


*Per l'allenamento*:
#codly(languages: (
  bash: (name: "Bash", color: gray)
),number-format: none, zebra-fill: none)
```bash
conda activate <nomeAmbiente>
python3 <pathFileEseguibile>/monodepth_main.py \
  --mode train \
  --model_name pydnet_v1 \
  --data_path <datasetPath> \
  --filenames_file <fileNamesDatasetPath>/eigen_train_files.txt \
  --log_directory <outputFilesPath>
```
Dove:
 - `<nomeAmbiente>`: è il nome dell'ambiente @Anaconda da dover attivare;
 - `<pathFileEseguibile>`: è il path che conduce al file `monodepth_main.py`, file che dovrà essere eseguito per eseguire l'allenamento;
 - `<datasetPath>`: è il path che conduce alla cartella contenente il dataset;
 - `<fileNamesDatasetPath>`: è il path che conduce al file `eigen_train_files.txt`;
 - `<outputFilesPath>`: è il path che conduce alla cartella dove verranno salvati tutti i file di output prodotti dalla procedura di allenamento.

Questa procedura produrrà dei file di checkpoint, ritrovabili nella cartella `<outputFilesPath>`.

*Per il _testing_*:
```bash
conda activate <nomeAmbiente>
python3 <pathFileEseguibile>/experiments.py \
  --datapath <datasetPath> \
  --filenames <fileNamesDatasetPath>/eigen_test_files.txt \
  --output_directory <outputFilesPath> \
  --checkpoint_dir <checkpointPath>
```
Dove:
 - `<nomeAmbiente>`: è il nome dell'ambiente @Anaconda da dover attivare;
 - `<pathFileEseguibile>`: è il path che conduce al file `experiments.py`, file che dovrà essere eseguito per calcolare e generare il file `disparities.npy`;
 - `<datasetPath>`: è il path che conduce alla cartella contenente il dataset;
 - `<fileNamesDatasetPath>`: è il path che conduce al file `eigen_test_files.txt`;
 - `<outputFilesPath>`: è il path che conduce alla cartella dove verrà salvato il file `disparities.npy`;
 - `<checkpointPath>`: è il path che conduce alla cartella dove è posizionato il checkpoint da usare per impostare i pesi del modello, precedentemente creato dalla fase di _training_.

Questa procedura produrrà un file `disparities.npy`, contenente tutte le @disparità prodotte dal modello, avente avuto come input le immagini appartenenti al test set.

*Per la valutazione*:
```bash
conda activate <nomeAmbiente>
python3 <pathFileEseguibile>/evaluate_kitti.py \
  --split eigen \
  --gt_path <datasetPath> \
  --filenames_path <fileNamesDatasetPath> \
  --predicted_disp_path <disparitiesPath>/disparities.npy \
```
Dove:
 - `<nomeAmbiente>`: è il nome dell'ambiente @Anaconda da dover attivare;
 - `<pathFileEseguibile>`: è il path che conduce al file `evaluate_kitti.py`, file che dovrà essere eseguito per valutare il file `disparities.npy`, precedentemente creato dalla fase di _testing_;
 - `<datasetPath>`: è il path che conduce alla cartella contenente il dataset;
 - `<fileNamesDatasetPath>`: è il path che conduce alla cartella al cui interno è posizionato `eigen_test_files.txt`;
 - `<disparitiesPath>`: è il path che conduce alla cartella dove è posizionato il file `disparities.npy`.

Questa procedura mostrerà a terminale i valori calcolati per ciascuna metrica di valutazione del modello.

Una volta seguita questa procedura ho ottenuto i seguenti risultati:
#figure(table(
  columns: (auto, auto, auto,auto,auto,auto,auto,auto),
  [],table.cell(colspan: 4)[*Minore è meglio*],table.cell(colspan: 3)[*Maggiore è meglio*],
  [*Fonte*],[*Abs Rel*],[*Sq Rel*],[*RMSE*],[*RMSE log*],[*d1*],[*d2*],[*d3*],
  [@PyDNetV1],[#underline("0.163")],[#underline("1.399")],[#underline("6.253")],[#underline("0.262")],[#underline("0.759")],[#underline("0.911")],[#underline("0.961")],
  [@PyDNetV1 ri-allenato],[0.164],[1.427],[6.369],[0.266],[0.757],[0.908],[0.960]
),caption: [Confronto tra i valori della valutazione riportata in @PyDNetV1 e i risultati della valutazione sul modello di @PyDNetV1 ri-allenato.])

Come si può notare i risultati sono estremamente vicini e di conseguenza @PyDNetV1 è stato dimostrato valido.

== Migrazione da Tensorflow a PyTorch
Verificati i risultati ottenuti nel paper, si può quindi partire con la migrazione dell'intera _codebase_ da @Tensorflow a @PyTorch, standard del mondo della ricerca nel campo del _machine learning_, che ci permetterà successivamente di integrare ad esso tecniche innovative, altrimenti impossibili da sperimentare.

=== Il dataset
La migrazione è cominciata con l'entità che governa l'approvvigionamento di immagini alla procedura di addestramento, per allenare il modello.
In @PyTorch questa entità è chiamata `Dataset` e può essere implementata mediante l'omonima interfaccia.

L'interfaccia espone i seguenti due metodi astratti:
 - `__len__(self)`: il quale deve restituire la lunghezza del dataset;
 - `__getitem__(self, i: int)`: il quale dato un indice, deve restituire l'elemento o gli elementi del dataset corrispondenti ad esso.

Siccome i nomi dei vari file da recuperare per il dataset sono presenti all'interno di determinati file di testo (nello specifico `eigen_train_files.txt` per il training e `eigen_test_files.txt` per il testing, secondo lo split presentato in @eigen), organizzati in un formato simile al `.csv`, nell'implementazione di questa entità ho scelto di appoggiarmi alla libreria _Pandas_, la quale solitamente viene utilizzata apposta per leggere grandi file `.csv` in modo efficiente.
Inoltre, grazie alle _API_ di _Pandas_ è molto facile reperire la dimensione del dataset (ogni riga del file di testo corrisponde ai path della coppia di immagini stereo della stessa scena), ed è molto facile dato un indice reperire i path delle corrispondenti immagini stereo.

#linebreak()


Appoggiandomi poi alla libreria _Pillow_ (standard di lettura efficiente delle immagini nel mondo @Python) e @PyTorch, mi sono occupato della lettura delle immagini selezionate mediante _Pandas_, della succesiva loro conversione in tensori e dell'applicazione di un eventuale _data augmentation_ da applicare a questi, prima che vengano restituiti dal metodo `__getitem__`.
Il `Dataset` è stato creato in modo da far restituire una tupla di tensori $(T_"sx",T_"dx")$ se questo è in modalità _training_ altirmenti, se in modalità _testing_, resitituirà solo il tensore di sinistra $T_"sx"$.

#linebreak()

Ho implementato infine un metodo di utilità che a partire dal `Dataset` genera un `DataLoader`, il quale sarà il diretto usufruitore del `Dataset` per fornire alla procedura di addestramento i corretti batch di immagini.

=== I modelli
I modelli sono stati ricreati con una corrispondenza 1:1 rispetto a quanto ritrovabile nella _codebase_ originale (cambia solo la sintassi con la quale sono stati implementati, dovuta solo alla differenza di API tra @Tensorflow e @PyTorch), in quanto entrambe le parti devono rappresentare gli stessi modelli matematici.

#linebreak()

Tuttavia, ho approfittato dei vari metodi, interfacce e classi che @PyTorch offre per:
 - Creare moduli, mediante l'implementazione dell'interfaccia `torch.nn.Module` per poter costruire l'@encoder e il @decoder come due moduli a se stanti, poi integrati come sotto-moduli dei modelli, per rendere il codice più leggibile e compartimentalizzato;
 - Creare sequenze di blocchi o _layer_, mediante l'impiego di oggetti `torch.nn.Sequential`, per poter rendere il codice più semplice e sequenziale, migliorandone la leggibilità.

=== La procedura di _training_ <training>
Tutto il codice per il _training_ è stato realizzato dentro un file apposito `training.py`, il quale viene eventualmente richiamato dal file `main.py`.

Anche nel caso della procedura di _training_ c'è una corrispondenza 1:1 rispetto a quanto ritrovabile nella _codebase_ originale, poichè per ottenere gli stessi risilutati è necessario che il modello segua lo stesso addestramento, tuttavia sono state applicate le seguenti scelte stilistiche e organizzative:
 - Ogni funzione di perdita ha la propria funzione @Python. Successivamente la funzione di perdita completa richiama tutte le altre la corrispondente formula matematica, così da rendere più comprensibile e compartimentalizzato il codice;
 - Il codice originale fa un forte uso degli argomenti da terminale per definire le varie impostazioni, il codice migrato invece fa uso di file di configurazione scritti in @Python, così da poter specificare anche i tipi delle varie impostazioni inseribili e da poter sfruttare il @linter di @Python per avere suggerimenti riguardo alle impostazioni durante la scrittura del codice. Questo approccio è stato utilizzato anche dalla #link(<utilizzo>)[procedura di utilizzo] che dalla #link(<valutazione>)[procedura di valutazione]\;
  - In questo modo, l'unico argomento da terminale che è possibile andare ad impostare è l'argomento `--mode`, il quale può essere impostato a `train`, `use`, `webcam`, `test` e `eval`, dove il primo specifica che si vuole addestrare il modello, mentre i successivi due si impostano nel caso della #link(<valutazione>)[procedura di valutazione], mentre gli ultimi due si impostano nel caso della #link(<utilizzo>)[procedura di utilizzo].
 - Rigurado al salvataggio dei _checkpoint_, ho scelto di salvare sia l'ultimo _checkpoint_ che quello della versione del modello con la valutazione migliore sul _test set_. Questo perchè dopo ogni epoca viene fatta una valutazione del modello sul _test set_.

Successivamente, come precedentemente fatto per la _codebase_ originale, è stato aggiunto @Wandb per effettuare la registrazione delle funzioni di perdita per ogni esperimento.

=== La procedura di utilizzo <utilizzo>
Tutto il codice per l'utilizzo è stato realizzato dentro un file apposito `using.py`, il quale viene eventualmente richiamato dal file `main.py`.

Come per la respository originale ho fatto in modo che si possano utilizzare i modelli nei seguenti modi:
 - Se, come citato nella #link(<training>)[procedura di training] si imposta `--mode=use` si può fornire un secondo argomento `--img_path` dove si specifica il path dell'immagine di cui si vuole ottenere la mappa delle @disparità. In questo modo verrà generata una mappa delle disparità con nome omonimo al file inserito come input, che verrà posizionata nella medesima cartella del file di input;
 - Se si desidera utilizzare il modello attraverso la _webcam_ integrata del computer, si deve impostare `--mode=webcam`. Bisogna tuttavia assicurarsi di avere il comando `ffmpeg` disponibile mediante terminale;

Inoltre, nel caso in cui si voglia integrare il modello in un'altro programma, è stata creata la funzione `use()` la quale, una volta forniti come parametri: il modello da utilizzare, l'immagine sotto forma di immagine _Pillow_ o tensore di @PyTorch, le dimensioni delle immagini accettate dal modello, le dimensioni originali dell'immagine e il dispositivo sulla quale si vuole eseguire il modello (`cuda` o `cpu`), restituisce in output un tensore di @PyTorch, rappresentante la mappa delle @disparità.

=== La procedura di valutazione <valutazione>
Tutto il codice per la valutazione è stato realizzato dentro un file apposito `evaluating.py`, il quale viene eventualmente richiamato dal file `main.py`.
Tutto il codice per il _testing_ è stato realizzato dentro un file apposito `testing.py`, il quale viene eventualmente richiamato dal file `main.py`.

#linebreak()

La procedura di valutazione si divide in due parti:
 - _testing_: la fase di _testing_ si occupa di fornire le predizioni per tutte le immagini del _test set_, e di salvarle in un file chiamato `disparities.npy`;
 - valutazione: la fase di valutazione si occupa di analizzare il file `disparities.npy`, al fine di produrre delle valutazioni sulle metriche presentate in @eigen.

La procedura di testing è stata riscritta completamente sempre con corrispondenza 1:1 con la _codebase_ originale per poter sfruttare poi le stesse procedure di valutazione. Infatti le procedure di valutazione, essendo scritte in @Python utilizzando solamente _Numpy_, non sono dipendenti da un framework di _machine learning_ specifico e non sono quindi state migrate, ma tenute come sono.

== Esplorazione degli iperparametri e _data augmentation_
