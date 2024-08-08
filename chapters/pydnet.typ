#import "@preview/codly:1.0.0": *
#import "../config/functions.typ": *
#pagebreak(to: "odd")
= PyDNet <ch:pydnet>
PyDNet(*Py*\ramidal *D*\epth *Net*\work) è una famiglia di modelli composta da due versioni @PyDNetV1@PyDNetV2, che cercano di risolvere il problema della @MDE mediante un approccio non supervisionato.  con circa 2 milioni di parametri in @PyDNetV1 e circa 700.000 in @PyDNetV2.

Una peculiarità di questa famiglia di modelli è il numero di parametri estremamente basso, con circa 2 milioni di parametri in @PyDNetV1 e circa 700.000 in @PyDNetV2.
L'obbiettivo di questi modelli infatti, è quello di essere abbastanza leggeri da poter essere direttamente eseguiti su un processore, senza il supporto di una scheda grafica, per poter essere integrati in sistemi @embedded, come ad esempio nei cellulari @MDEInWild.

Questa sua caratteristica li rende molto interessanti come punto di partenza per sperimentare con tecniche innovative o apportare modifiche ai loro blocchi, di modo da migliorarne le prestazioni.

#linebreak()

Tuttavia, essendo modelli relativamente datati, sono stati scritti in una versione di @Tensorflow ormai deprecata, il che li rende non più facilmente utilizzabili.

Di conseguenza segueti sottocapitoli hanno la seguente funzione:
 - @arc:pydnet: va a descrivere l'architettura del modello e dei suoi sotto-componenti;
 - @fun:pydnet: va a descrivere come il modello cerca di risolvere il problema dell'@MDE, analizzando funzioni di perdita e procedura di allenamento;
 - @conf:pydnet: descrive tutta la procedura di configurazione di un ambiente di calcolo, al fine di poter eseguire il codice originale di @PyDNetV1;
 - @val:pydnet: descrive il processo di validazione del codice pubblicato, per verificare che effettivamente conduca a risultati simili a quelli del _paper_;
 - @mig:pydnet: descrive il processo di migrazione da @Tensorflow a @PyTorch con la successiva validazione del modello migrato, su tutti gli scenari proposti dal _paper_;
 - @plus: descrive in primo luogo degli esperimenti condotti sugli iperparametri di @PyDNetV1 per analizzare poi le conseguenze che avranno sulle metriche di valutazione, e in secondo luogo PyDNetV2 @PyDNetV2, per verificare come questo modello si comporta rispetto alla sua versione precedente, a parità di modalità di addestramento.

#block([== Architettura del modello <arc:pydnet>
@PyDNetV1 è una rete convoluzionale profonda strutturata su sei livelli, dove ogni livello riceve l' input dal livello superiore (fatta eccezione per il primo livello che riceve l'immagine di input), elabora l'input ricevuto mediante un @encoder, che restituisce un output il quale farà da input al livello inferiore (fatta eccezione per l'ultimo livello).
],breakable: false,width: 100%)
#block([L'output dell'@encoder viene poi concatenato all'output del livello inferiore sulla dimensione dei canali, e passato ad un @decoder, il cui output verrà:
 - Passato attraverso la funzione di attivazione sigmoide, il cui output corrisponderà alla mappa di @disparità del livello preso in analisi;
],breakable: false,width: 100%)
 - Passato attraverso una convoluzione trasposta con @kernel di dimensione $2 times 2$ e @stride 2, per raddoppiare le dimensioni di altezza e larghezza del tensore in ingresso, il cui output verrà passato al livello superiore (eccezione fatta per il primo livello, che ha come unico output il risultato la mappa di @disparità del livello).

#block([L'architettura è quindi la seguente:
#figure(
  image("../images/architectures/PyDNetV1.drawio.png",width: 250pt),
  caption: [Architettura del modello @PyDNetV1]
)
],breakable: false,width: 100%)

L'@encoder è composto da una convoluzione con @kernel di dimensione $3 times 3$ e @stride 2, che va quindi a ridurre l'altezza e la larghezza del tensore di ingresso della metà, seguita da una convoluzione con @kernel di dimensione $3 times 3$.
L'@encoder del livello $i, forall i in {1,2,3,4,5,6}$ avrà quindi come tensore in uscita un tensore con dimensioni di altezza e larghezza pari a $1 / 2^i$ delle dimensioni dell'input iniziale.
In più, andando dal primo al sesto livello, i canali di uscita prodotti dalla seconda convoluzione dell'encoder sono 16, 32, 64, 96, 128, 196.

#block([L'architettura dell'encoder è quindi la seguente:
#figure(
  image("../images/architectures/PyDNetV1-encoder.drawio.png",width: 250pt),
  caption: [#link(<encoder>)[Encoder] del modello @PyDNetV1.]
)
],breakable: false,width: 100%)

Il @decoder invece è composto da una successione di quattro convoluzioni con @kernel di dimensione $3 times 3$ e @stride 2, i quali rispettivamente producono delle @fmap con un numero di canali pari a 96, 64, 32 e 8, mantenendo invece le dimensioni di altezza e larghezza dell'_input_.
#block([L'architettura del @decoder è quindi la seguente:
#figure(
  image("../images/architectures/PyDNetV1-decoder.drawio.png",width: 250pt),
  caption: [#link(<decoder>)[Decoder] del modello @PyDNetV1.]
)
],breakable: false,width: 100%)

Successivamente ad ogni convoluzione, tranne per l'ultima del decoder, viene applicata la funzione di attivazione _leaky ReLU_ con coefficiente di crescita per la parte negativa di 0,2.

#block([== Funzionamento <fun:pydnet>
Lo scopo di @PyDNetV1@PyDNetV2 è quello di riuscire nel compito di @MDE. Per farlo @PyDNetV1@PyDNetV2 imparano, date due immagini stereo dello stesso scenario, ad applicare uno sfasamento a ogni pixel dell'immagine di sinistra, in modo da renderla quanto più simile possibile alla corrispondente immagine di destra, e uno sfasamento a ogni pixel dell'immagine di destra per renderla quanto più simile possibile alla corrispondente immagine di sinistra.
],breakable: false,width: 100%)

#linebreak()

Quanto enunciato però viene fatto solamente durante l'addestramento del modello, poichè durante l'inferenza ogni immagine di _input_ viene introdotta nel modello come immagine di sinistra. Si prende infatti come _output_ del modello, solo il primo canale delle @fmap uscenti dalla sigmoide del livello, che infatti corrisponde alla mappa di @disparità per le immagini di sinistra.
Questa strategia funziona perchè progressivamente, durante l'allenamento, viene forzato un allineamento tra le predizioni per le immagini di sinistra e quelle di destra, rendendo ambivalente l'_output_ del modello sul canale di sinistra rispetto a quello di destra.


#block([
=== Funzioni di perdita
_*Image error loss*_ ($cal(L)_"ap"$):
#figure($ cal(L)_"ap"^l = 1/N sum_(i,j) alpha (1-"SSIM"(I^l_(i,j),tilde(I)^l_(i,j)))/2 + (1-alpha)norm((I^l_(i,j),tilde(I)^l_(i,j)))_1 $,caption: [_Image error loss_ calcolata per l'immagine di sinistra.])
],breakable: false,width: 100%)

Questa è la funzione di perdita che penalizza quanto più l'immagine originale di sinistra $I^l$ è diversa dall'immagine di destra con lo sfasamento applicato $tilde(I)^l$ (appunto per diventare l'immagine di sinistra).
La prima parte della sommatoria, utilizzando la funzione SSIM, serve per  misurare la similarità strutturale tra le due immagini, mentre con la seconda parte, mediante la norma 1, serve per misurare la distanza tra i corrispondenti pixel delle due immagini.
Il parametro $alpha$ viene usato per regolare il peso tra la prima e la seconda parte, il quale viene impostato a 0,85, andando quindi a dare molta più importanza alla prima.


#block([_*Disparity smoothness loss*_ ($cal(L)_"ds"$):
#figure($ cal(L)_"ds"^l = 1/N sum_(i,j) abs(delta_x d^l_(i,j))e^(-norm(delta_x I^l_(i,j))) + abs(delta_y d^l_(i,j))e^(-norm(delta_y I^l_(i,j))) $,caption: [_Disparity smoothness loss_ calcolata per l'immagine di sinistra.])
],breakable: false,width: 100%)

In questo caso invece, questa funzione di perdita disincentiva discontinuità di profondità calcolate mediante norma 1, a meno che non ci sia una discontinuità sul gradiente dell'immagine.
La prima parte della sommatoria analizza le discontinuità sull'asse orizontale, mentre la seconda parte sull'asse verticale.


#block([_*Left-right consistency loss*_ ($cal(L)_"lr"$):
#figure($ cal(L)^l_"lr" = 1/N sum_(i,j)abs(d^l_(i,j)-d^r_(i,j+d^l_(i,j))) $,caption: [_Left-right consistency loss_ calcolata per l'immagine di sinistra.])
],breakable: false,width: 100%)

Infine, l'ultima funzione di perdita, formula nota nel campo degli algoritmi stereo, serve per forzare coerenza tra le predizioni di @disparità di destra $d^r$ e di sinistra $d^l$.


#block([*Funzione di perdita completa* ($cal(L)_"lr"$):

Le precedenti funzioni di perdita vengono calcolate anche per l'immagine di sinistra, per poi essere combinate nel seguente modo, creando la funzione di perdita completa $cal(L)_"s"$:
$ cal(L)_"s" = alpha_"ap" (cal(L)^l_"ap"+cal(L)^r_"ap") + alpha_"ds" (cal(L)^l_"ds"+cal(L)^r_"ds") + alpha_"lr" (cal(L)^l_"lr"+cal(L)^r_"lr")  $
],breakable: false,width: 100%)

#block([I pesi per i vari termini della funzione completa sono impostati nel seguente modo:
 - $alpha_"ap" = 1$;
],breakable: false,width: 100%)
 - $alpha_"lr" = 1$;
 - $alpha_"ds" = 1/r$ dove $r$ è il fattore di scala a ciascun livello di risoluzione.

#block([=== Allenamento
Per l'allenamento viene utilizzato l'ottimizzatore @adam con i seguenti parametri: $beta_1=0.9$, $beta_2=0.999$ e $epsilon=10^(-8)$.
],breakable: false,width: 100%)

Il _learning rate_ parte da $10^-4$ per il primo 60% delle epoche, e viene dimezzato ogni 20% successivo.

#block([Infine vengono applicate, con una probabilità del 50%, le seguenti _data augmentation_:
 - Capovolgimento orizontale delle immagini;
],breakable: false,width: 100%)
 - Trasformazione delle immagini:
  - Correzione gamma;
  - Correzione luminosità;
  - Sfasamento dei colori.

Il dataset viene suddiviso in batch da 8 immagini, e verranno eseguite un totale di 50 epoche di allenamento.

#block([== Configurazione dell'ambiente <conf:pydnet>
La versione di Tensorflow usata per l'ambiente di allenamento e per i modelli @PyDNetV1@PyDNetV2 è la `1.8`, ormai deprecata da anni e non più scaricabile dai package manager come @pip o @Anaconda.
],breakable: false,width: 100%)
Una versione retrocompatibile con la `1.8` e ancora scaricabile tramite @pip è la `1.13.2`, che però dipende da una versione del pacchetto `protobuf` non più disponibile. Fortunatamente, la versione `3.20` di `protobuf` è ancora scaricabile da @pip e compatibile con Tensorflow `1.13.2`.
Il codice si basava anche su una versione deprecata del pacchetto `scipy`, facilmente sostituibile con la versione `1.2`, ancora disponibile tramite @pip.
L'ultima configurazione necessaria per eseguire il codice è la corretta versione di @Python, ancora scaricabile e che riesca ad essere compatibile con tutti i pacchetti sopra menzionati e con le relative dipendenze. Grazie ad @Anaconda è possibile scaricare la versione `3.7` che è utilizzabile per questo scopo.

#block([I comandi da terminale per ottenere la seguente configurazione, previa corretta installazione di @pip e @Anaconda sono:
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
],breakable: false,width: 100%)
Tra i pacchetti installati mediante @pip è presente anche @Wandb, un sistema che permette di registrare, gestire e catalogare il _plot_ delle _loss function_ per i vari esperimenti che verranno condotti.

#linebreak()
Il codice è tecnicamente eseguibile, solo se si dispone di una sceda video all'interno della macchina. Tuttavia il cluster del dipartimento di matematica, ha versioni troppo aggiornate dei driver @CUDA e della libreria @cuDNN, per essere utilizzabili da @Tensorflow `1.13.2`.
Ho quindi ritrovato le versioni adatte: per @CUDA, la versione `10.0`, scaricabile seguendo le istruzioni presenti nell'#link("https://developer.nvidia.com/cuda-toolkit-archive","archivio CUDA"), e per @cuDNN, la versione `7.4.2`, scaricabile seguendo le istruzioni presenti nell'#link("https://developer.nvidia.com/rdp/cudnn-archive","archivio cuDNN").

#block([Infine bisogna scaricare il dataset KITTI, dataset utilizzato per l'addestramento e valutazione del modello, utilizzando questo comando:
```bash
wget -i utils/kitti_archives_to_download.txt -P ~/my/output/folder/
```
],breakable: false,width: 100%)
#block([Successivamente bisogna effettuare l'_unzip_ di tutte le cartelle compresse e convertire tutte le immagini da `.png` a `.jpg`, mediante i seguenti comandi:
```bash
cd <pathCartellaDataset>
find <pathCartellaDataset> -name '*.zip' | parallel 'unzip -d {.} {}'
find <pathCartellaDataset> -name '*.png' | parallel 'convert {.}.png {.}.jpg && rm {}'
```
Dove `<pathCartellaDataset>` è il path che conduce alle cartelle `.zip` precedentemente scaricate.
],breakable: false,width: 100%)

#block([== Validazione <val:pydnet>
Seguendo le istruzioni ritrovabili nella _repository_ di @PyDNetV1 e @monodepth, si possono recuperare le seguenti istruzioni per effettuare l'esecuzione dell'allenamento, il _testing_ e la successiva valutazione di @PyDNetV1.
],breakable: false,width: 100%)

Quindi, una volta impostata una _codebase_ come scritto nella documentazione di @PyDNetV1 possono essere utilizzati i seguenti comandi.


#block([*Per l'allenamento*:
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
],breakable: false,width: 100%)
 - `<pathFileEseguibile>`: è il path che conduce al file `monodepth_main.py`, file che dovrà essere eseguito per eseguire l'allenamento;
 - `<datasetPath>`: è il path che conduce alla cartella contenente il dataset;
 - `<fileNamesDatasetPath>`: è il path che conduce al file `eigen_train_files.txt`;
 - `<outputFilesPath>`: è il path che conduce alla cartella dove verranno salvati tutti i file di output prodotti dalla procedura di allenamento.

Questa procedura produrrà dei file di checkpoint, ritrovabili nella cartella `<outputFilesPath>`.

#block([*Per il _testing_*:
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
],breakable: false,width: 100%)
 - `<pathFileEseguibile>`: è il path che conduce al file `experiments.py`, file che dovrà essere eseguito per calcolare e generare il file `disparities.npy`;
 - `<datasetPath>`: è il path che conduce alla cartella contenente il dataset;
 - `<fileNamesDatasetPath>`: è il path che conduce al file `eigen_test_files.txt`;
 - `<outputFilesPath>`: è il path che conduce alla cartella dove verrà salvato il file `disparities.npy`;
 - `<checkpointPath>`: è il path che conduce alla cartella dove è posizionato il checkpoint da usare per impostare i pesi del modello, precedentemente creato dalla fase di _training_.

Questa procedura produrrà un file `disparities.npy`, contenente tutte le @disparità prodotte dal modello, avente avuto come input le immagini appartenenti al test set.

#block([*Per la valutazione*:
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
],breakable: false,width: 100%)
 - `<pathFileEseguibile>`: è il path che conduce al file `evaluate_kitti.py`, file che dovrà essere eseguito per valutare il file `disparities.npy`, precedentemente creato dalla fase di _testing_;
 - `<datasetPath>`: è il path che conduce alla cartella contenente il dataset;
 - `<fileNamesDatasetPath>`: è il path che conduce alla cartella al cui interno è posizionato `eigen_test_files.txt`;
 - `<disparitiesPath>`: è il path che conduce alla cartella dove è posizionato il file `disparities.npy`.

Questa procedura mostrerà a terminale i valori calcolati per ciascuna metrica di valutazione del modello.

#block([Una volta seguita questa procedura ho ottenuto i seguenti risultati:
#eval_table(
  (
    (name: [@PyDNetV1], vals: (0.163,1.399,6.253,0.262,0.759,0.911,0.961)),
    (name: [@PyDNetV1 ri-allenato], vals: (0.164,1.427,6.369,0.266,0.757,0.908,0.960))
  ),
  1,
  [@PyDNetV1 vs. @PyDNetV1 ri-allenato]
)
],breakable: false,width: 100%)

Come si può notare i risultati sono estremamente vicini e di conseguenza @PyDNetV1 è stato dimostrato valido.

#block([== Migrazione da Tensorflow a PyTorch <mig:pydnet>
Verificati i risultati ottenuti nel paper, si può quindi partire con la migrazione dell'intera _codebase_ da @Tensorflow a @PyTorch, standard del mondo della ricerca nel campo del _machine learning_, che ci permetterà successivamente di integrare ad esso tecniche innovative, altrimenti impossibili da sperimentare.
],breakable: false,width: 100%)

#block([=== Il dataset
La migrazione è cominciata con l'entità che governa l'approvvigionamento di immagini alla procedura di addestramento, per allenare il modello.
],breakable: false,width: 100%)
In @PyTorch questa entità è chiamata `Dataset` e può essere implementata mediante l'omonima interfaccia.

#block([L'interfaccia espone i seguenti due metodi astratti:
 - `__len__(self)`: il quale deve restituire la lunghezza del dataset;
],breakable: false,width: 100%)
 - `__getitem__(self, i: int)`: il quale dato un indice, deve restituire l'elemento o gli elementi del dataset corrispondenti ad esso.

Siccome i nomi dei vari file da recuperare per il dataset sono presenti all'interno di determinati file di testo (nello specifico `eigen_train_files.txt` per il training e `eigen_test_files.txt` per il testing, secondo lo split presentato in @eigen), organizzati in un formato simile al `.csv`, nell'implementazione di questa entità ho scelto di appoggiarmi alla libreria _Pandas_, la quale solitamente viene utilizzata apposta per leggere grandi file `.csv` in modo efficiente.
Inoltre, grazie alle _API_ di _Pandas_ è molto facile reperire la dimensione del dataset (ogni riga del file di testo corrisponde ai path della coppia di immagini stereo della stessa scena), ed è molto facile dato un indice reperire i path delle corrispondenti immagini stereo.

#linebreak()


Appoggiandomi poi alla libreria _Pillow_ (standard di lettura efficiente delle immagini nel mondo @Python) e @PyTorch, mi sono occupato della lettura delle immagini selezionate mediante _Pandas_, della succesiva loro conversione in tensori e dell'applicazione di un eventuale _data augmentation_ da applicare a questi, prima che vengano restituiti dal metodo `__getitem__`.
Il `Dataset` è stato creato in modo da far restituire una tupla di tensori $(T_"sx",T_"dx")$ se questo è in modalità _training_ altirmenti, se in modalità _testing_, resitituirà solo il tensore di sinistra $T_"sx"$.

#linebreak()

Ho implementato infine un metodo di utilità che a partire dal `Dataset` genera un `DataLoader`, il quale sarà il diretto usufruitore del `Dataset` per fornire alla procedura di addestramento i corretti batch di immagini.

#block([=== I modelli <models>
I modelli di @PyDNetV1@PyDNetV2 sono stati ricreati con una corrispondenza 1:1 rispetto a quanto ritrovabile nella _codebase_ originale (cambia solo la sintassi con la quale sono stati implementati, dovuta solo alla differenza di API tra @Tensorflow e @PyTorch), in quanto entrambe le parti devono rappresentare gli stessi modelli matematici.
],breakable: false,width: 100%)

#block([Tuttavia, ho approfittato dei vari metodi, interfacce e classi che @PyTorch offre per:
 - Creare moduli, mediante l'implementazione dell'interfaccia `torch.nn.Module` per poter costruire l'@encoder e il @decoder come due moduli a se stanti, poi integrati come sotto-moduli dei modelli, per rendere il codice più leggibile e compartimentalizzato;
],breakable: false,width: 100%)
 - Creare sequenze di blocchi o _layer_, mediante l'impiego di oggetti `torch.nn.Sequential`, per poter rendere il codice più semplice e sequenziale, migliorandone la leggibilità.

#block([=== La configurazione
Il codice originale fa un forte uso degli argomenti da terminale per definire le varie impostazioni di esecuzione del programma, mentre il codice migrato invece fa uso di file di configurazione scritti in @Python, così da poter specificare anche i tipi delle varie impostazioni inseribili e da poter sfruttare il @linter di @Python per avere suggerimenti riguardo alle impostazioni durante la scrittura del codice.
],breakable: false,width: 100%)
Nel mio caso ho scritto un file di configurazione `ConfigHomeLab.py` per la configurazione del programma di modo da poter eseguire sul mio computer di casa, e un file di configurazione `ConfigCluster.py` per poterlo invece eseguire sul cluster di dipartimento.

#block([Le seguenti fasi di #link(<training>)[_training_], #link(<utilizzo>)[utilizzo] e #link(<valutazione>)[valutazione] hanno tutte bisogno di due argomenti da terminale:
 - `--mode`: che serve a specificare la modalità di esecuzione del codice (se per l'allenamento, utilizzo o valutazione);
],breakable: false,width: 100%)
 - `--env`: che serve a specificare la configurazione da utilizzare (nel mio caso tra `ConfigHomeLab`, ovvero la scelta di default se non viene inserito niente e `ConfigCluster`).

#block([=== La procedura di _training_ <training>
Tutto il codice per il _training_ è stato realizzato dentro un file apposito `training.py`, il quale viene eventualmente richiamato dal file `main.py`.
],breakable: false,width: 100%)

#block([Anche nel caso della procedura di _training_ c'è una corrispondenza 1:1 rispetto a quanto ritrovabile nella _codebase_ originale, poichè per ottenere gli stessi risilutati è necessario che il modello segua lo stesso addestramento, tuttavia sono state applicate le seguenti scelte stilistiche e organizzative:
 - Ogni funzione di perdita ha la propria funzione @Python. Successivamente la funzione di perdita completa richiama tutte le altre la corrispondente formula matematica, così da rendere più comprensibile e compartimentalizzato il codice;
],breakable: false,width: 100%)
 - Rigurado al salvataggio dei _checkpoint_, ho scelto di salvare sia l'ultimo _checkpoint_ che quello della versione del modello con la valutazione migliore sul _test set_. Questo perchè dopo ogni epoca viene fatta una valutazione del modello sul _test set_.

Successivamente, come precedentemente fatto per la _codebase_ originale, è stato aggiunto @Wandb per effettuare la registrazione delle funzioni di perdita per ogni esperimento.

#block([=== La procedura di utilizzo <utilizzo>
Tutto il codice per l'utilizzo è stato realizzato dentro un file apposito `using.py`, il quale viene eventualmente richiamato dal file `main.py`.
],breakable: false,width: 100%)

#block([Come per la respository originale ho fatto in modo che si possano utilizzare i modelli nei seguenti modi:
 - Se si imposta `--mode=use` si può fornire un secondo argomento `--img_path` dove si specifica il path dell'immagine di cui si vuole ottenere la mappa delle @disparità. In questo modo verrà generata una mappa delle disparità con nome omonimo al file inserito come input, che verrà posizionata nella medesima cartella del file di input;
],breakable: false,width: 100%)
 - Se si desidera utilizzare il modello attraverso la _webcam_ integrata del computer, si deve impostare `--mode=webcam`. Bisogna tuttavia assicurarsi di avere il comando `ffmpeg` disponibile mediante terminale;

Inoltre, nel caso in cui si voglia integrare il modello in un'altro programma, è stata creata la funzione `use()` la quale, una volta forniti come parametri: il modello da utilizzare, l'immagine sotto forma di immagine _Pillow_ o tensore di @PyTorch, le dimensioni delle immagini accettate dal modello, le dimensioni originali dell'immagine e il dispositivo sulla quale si vuole eseguire il modello (`cuda` o `cpu`), restituisce in output un tensore di @PyTorch, rappresentante la mappa delle @disparità.

#block([=== La procedura di valutazione <valutazione>
Tutto il codice per la valutazione è stato realizzato dentro un file apposito `evaluating.py`, il quale viene eventualmente richiamato dal file `main.py`.
],breakable: false,width: 100%)
Tutto il codice per il _testing_ è stato realizzato dentro un file apposito `testing.py`, il quale viene eventualmente richiamato dal file `main.py`.

#block([La procedura di valutazione si divide in due parti:
 - _testing_: la fase di _testing_ si occupa di fornire le predizioni per tutte le immagini del _test set_, e di salvarle in un file chiamato `disparities.npy`;
],breakable: false,width: 100%)
 - valutazione: la fase di valutazione si occupa di analizzare il file `disparities.npy`, al fine di produrre delle valutazioni sulle metriche presentate in @eigen.

La procedura di testing è stata riscritta completamente sempre con corrispondenza 1:1 con la _codebase_ originale per poter sfruttare poi le stesse procedure di valutazione. Infatti le procedure di valutazione, essendo scritte in @Python utilizzando solamente _Numpy_, non sono dipendenti da un framework di _machine learning_ specifico e non sono quindi state migrate, ma tenute come sono.

#block([=== Risultati della migrazione
Per eseguire il codice bisogna innanzitutto avere un ambiente @Anaconda con tutte le dipendenze necessarie, e per farlo bisogna eseguire i seguenti comandi da terminale:
```bash
conda create -n <nomeAmbiente>
conda activate <nomeAmbiente>
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
pip install wandb pandas matplotlib Pillow
```
Dove `<nomeAmbiente>` è il nome che diamo all'ambiente @Anaconda che poi utilizzeremo.
],breakable: false,width: 100%)

Successivamente bisogna impostare il file di configurazione che si decide di usare, fornendo tutte le impostazioni richieste (entrambi i file sono commentati al di sotto di ogni impostazione per spiegare che valori riporvi).

#block([Fatto ciò possiamo allenare il modello tramite il seguente comando:
```bash
python3 main.py --mode=train --env=<configurazioneUsata>
```
Dove `<configurazioneUsata>` è il nome della configurazione che decidiamo di utilizzare.
],breakable: false,width: 100%)

Dopo averlo allenato avremo due file di _checkpoint_ generati nella directory specificata all'interno del file di configurazione.
Sempre nel file di configurazione dobbiamo ora specificare quale _checkpoint_ dobbiamo utilizzare.

#block([Una volta specificato il _checkpoint_ da utilizzare testiamo il modello con il seguente comando:
```bash
python3 main.py --mode=test --env=<configurazioneUsata>
```
Dove `<configurazioneUsata>` è il nome della configurazione che decidiamo di utilizzare.

Questa procedura avrà generato un file `disparities.npy` nella directory specificata all'interno del file di configurazione.
],breakable: false,width: 100%)

#block([Ora possiamo andare a valutare l'output del modello (ovvero l'output della fase precedente), utilizzando il seguente comando:
```bash
python3 main.py --mode=eval --env=<configurazioneUsata>
```
],breakable: false,width: 100%)

#block([Seguendo questi passaggi ho ottenuto i seguenti risultati:
#eval_table(
  (
    (name: [@PyDNetV1], vals: (0.163,1.399,6.253,0.262,0.759,0.911,0.961)),
    (name: [@PyDNetV1 in @PyTorch], vals: (0.16,1.52,6.229,0.253,0.782,0.916,0.964))
  ),
  1,
  [@PyDNetV1 vs. @PyDNetV1 riscritto in @PyTorch (_training_ su _KITTI_, 50 epoche)]
)
],breakable: false,width: 100%)

#block([Ho poi allenato il modello sul _dataset_ _CityScapes_ per poi fare _ @finetune _ sul _dataset_ _KITTI_, ottenendo i seguenti risultati:
#eval_table(
  (
    (name: [@PyDNetV1], vals: (0.148,1.318,5.932,0.244,0.8,0.925,0.967)),
    (name: [@PyDNetV1 in @PyTorch], vals: (0.147,1.378,5.91,0.242,0.804,0.927,0.967))
  ),
  1,
  [@PyDNetV1 vs. @PyDNetV1 riscritto in @PyTorch (_training_ su _CityScapes_+_KITTI_, 50 epoche)]
)
],breakable: false,width: 100%)

#block([Infine ho allenato il modello per 200 epoche, ottenendo i seguenti risultati:
#eval_table(
  (
    (name: [@PyDNetV1], vals: (0.153,1.363,6.03,0.252,0.789,0.918,0.963)),
    (name: [@PyDNetV1 in @PyTorch], vals: (0.153,1.473,6.23,0.251,0.789,0.918,0.964)),
  ),
  1,
  [@PyDNetV1 vs. @PyDNetV1 riscritto in @PyTorch (_training_ su _KITTI_, 200 epoche)]
)
],breakable: false,width: 100%)
Si può quindi constatare che la migrazione a @PyTorch è stata un successo, permettendoci di arrivare nell'intorno dei risultati enunciati nel paper.


#block([== Iperparametri e PyDNetV2 <plus>
=== Esplorazione degli iperparametri
È stata condotta una procedura investigativa relativa a come il cambiamento degli iperparametri influenzi le _performance_ del modello, per poter capire poi come poter eventualmente migliorare la procedura di training al fine di avere un modello che a parità di parametri abbia una valutazione migliore.
],breakable: false,width: 100%)

 #block([
Sono quindi state analizzate le seguenti situazioni date le seguenti ipotesi:
  - *Cosa succede se il dataset è in bianco e nero?*: questa ipotesi va a verificare come la semplificaizione del dataset impatta la prestazioni del modello. Uso il termine semplificare, in quanto la rappresentazione delle immagini passa dall'essere (secondo la norma $"numCanali"times"altezzaImmagine"times"larghezzaImmagine"$) $3times H times W$ a $1times H times W$, andando a rappresentare con quell'unico canale, solamente la luminosità del _pixel_\. I risultati sono i seguenti:
#eval_table(
  (
    (name: [@PyDNetV1], vals: (0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [@PyDNetV1 _Luminance_ Dataset], vals: (0.164,1.553,6.423,0.263,0.763,0.906,0.959))
  ),
  1,
  [In @PyTorch: @PyDNetV1 vs. @PyDNetV1 (_Luminance_ dataset)]
)
],breakable: false,width: 100%)
Come si può vedere, i risultati peggiorano, questo a significare che avere effettivamente i canali per i colori introducevano informazione significativa.
#block([- *Cosa succede se il dataset è in formato HSV?*: il formato _HSV_ è un formato di rappresentazione dei colori che si appoggia sempre su tre canali, ma rispetto alla rappresentazione _RGB_, i tre in questo caso sono usati per rappresentare tonalità, saturazione e luminosità. Si cerca quindi di capire se un'altra rappresentazione dei colori possa portare beneficio alle _performance_ del modello. I risultati sono i seguenti:
#eval_table(
  (
    (name: [@PyDNetV1], vals: (0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [@PyDNetV1 _HSV_ Dataset], vals:(0.237,2.451,8.259,0.377,0.605,0.798,0.899))
  ),
  1,
  [In @PyTorch: @PyDNetV1 vs. @PyDNetV1 (_HSV_ dataset)]
)
],breakable: false,width: 100%)
Si può quindi evincere dai risultati che il miglior formato per la rappresentazione dei colori per il modello è l'_RGB_.

 #block([- *Cosa succede se si applica un ribaltamento verticale alle immagini?* In questo caso verificare come, aggiungendo il ribaltamento verticale alle immagini, vengano impattate le prestazioni del modello. Questo perchè alla base è presente l'ipotesi di una possibile migliore generalizzazione del modello, se addestrato anche su scenari poco probabili, poichè ad esempio, abituarsi al far si che il cielo sia sempre nelle parti superiori delle immagini, creerà nel modello un'influenza forte. I risultati sono i seguenti:
#eval_table(
  (
    (name: [@PyDNetV1], vals:(0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [@PyDNetV1 _VFlip_], vals: (0.159,1.403,6.277,0.26,0.765,0.909,0.961))
  ),
  1,
  [In @PyTorch: @PyDNetV1 vs. @PyDNetV1 (con _vertical flip_)]
)
],breakable: false,width: 100%)
Si nota che, sebbene le prime due metriche di valutazione sono leggermente migliorate, nel resto le prestazioni degradano significativamente.

#block([- *Cosa succede se si applica un ribaltamento verticale alle immagini rimuovendo il ribaltamento orizontale?* Volendo provare a vedere che conseguenza avrebbero portato i soli ribaltamenti verticali, rimuovendo quindi quelli orizontali, ho ottenuto i seguenti risultati:
#eval_table(
  (
    (name: [@PyDNetV1], vals: (0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [@PyDNetV1 _VFlip_ no _HFlip_], vals: (0.173,1.636,6.536,0.269,0.746,0.9,0.957))
  ),
  1,
  [In @PyTorch: @PyDNetV1 vs. @PyDNetV1 (con _vertical flip_ senza _horizontal flip_)],
)
],breakable: false,width: 100%)
Si può quindi notare che mettere il modello in condizioni poco probabili, non lo aiuta a generalizzare meglio, ma introduce solo più confusione.

#block([- *Cosa succede al cambiare della dimensione delle immagini di _input_?* Si vuole in questo caso verificare come, gradualmente aumentando la dimensione delle immagini sulla quale il modello viene addestrato, si modificano le metriche di valutazione per il modello. Sono riportati in seguito i risultati per ciascuna risoluzione di _input_ provata:

#eval_table(
  (
    (name: [@PyDNetV1 $512times 256$], vals: (0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [@PyDNetV1 $640times 192$], vals: (0.163,1.525,6.203,0.251,0.778,0.916,0.963)),
    (name: [@PyDNetV1 $1024times 320$], vals: (0.151,1.373,5.919,0.245,0.794,0.923,0.966)),
    (name: [@PyDNetV1 $1280times 384$], vals: (0.139,1.249,5.742,0.234,0.816,0.932,0.969))
  ),
  1,
  [In @PyTorch: confronto tra varie risoluzioni di _input_],
)
],breakable: false,width: 100%)
Si può notare come aumentando la dimensione delle immagini di _input_, le metriche di valutazione migliorano notevolmente. È tuttavia da fare un'osservazione.

Avere immagini di _input_ più grandi determina una _performance_ in termini di tempo di inferenza e in termini di consumo di memoria molto peggiore, è quindi preferibile concentrarsi sulla costruzione di un modello migliore, che sull'uso di modelli leggeri ma che diventano costosi per la dimensione dell'input che elaborano.

#block([=== PyDNet V2
PyDNetV2 è un modello ancor più leggero rispetto alla versione precedente, infatti si passa dai 2 milioni di parametri per @PyDNetV1 a circa 700.000 parametri per @PyDNetV2. #block([Questo è stato reso possibile rimuovendo solamente gli ultimi due livelli della piramide, senza cambiare ne gli @encoder ne i @decoder, andando quindi ad avere la seguente architettura:
],breakable: false,width: 100%)
#figure(
  image("../images/architectures/PyDNetV2.drawio.png",width: 250pt),
  caption: [Architettura del modello @PyDNetV2]
)
],breakable: false,width: 100%)

#block([
Sebbene la procedura di allenamento di @PyDNetV2 differisce dalla procedura di @PyDNetV1, si è voluto verificare a parità di ambiente di addestramento, la performance del modello di @PyDNetV2 migrato anch'esso in @PyTorch (come menzionato #link(<models>)[precedentemente]), ottenendo quindi i seguenti risultati:
#eval_table(
  (
    (name: [@PyDNetV1], vals: (0.16,1.52,6.229,0.253,0.782,0.916,0.964)),
    (name: [@PyDNetV2], vals: (0.157,1.487,6.167,0.254,0.783,0.917,0.964)),
  ),
  1,
  [In @PyTorch: @PyDNetV1 vs. @PyDNetV2]
)
],breakable: false,width: 100%)
Dai risultati si può dedurre che forse avere sei livelli invece che quattro, avendo di conseguenza circa 1.3 milioni di parametri in più, fa imparare al modello più rumore che informazione utile.
