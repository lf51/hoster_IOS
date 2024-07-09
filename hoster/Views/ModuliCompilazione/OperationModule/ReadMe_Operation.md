#  HONewOperationModule

Il modulo è settato per la creazione di una nuova operazione, predisposto per ricevere una operazione esistente, la cui modifica non è però implementata (04.07.24). La modifica presenta al momento la seguente problematica:

 Esistono operazioni interconnesse. Esempio Acquisto beni strumentali e relativo ammortamento. Non solo, acquisto di merci per il megazzino e il relativo consumo.
Tali operazioni non sono linkate fra loro ma risultano interconnesse, poichè ad esempio l'ammortamento è creato nello stesso momento ma come operazione distinta. Il consumo di beni del magazzino è possibile solo previo controllo della presenza di merci in stock. 
Un possibile sviluppo, nel caso di operazioni errate, può essere uno status di archiviato che le rende inconsiderabili al fine dei calcoli.
Un'altra possibile soluzione può essere l'introduzione di operazioni correttive.

- Fasi del modulo:

1. L'utente crea attraverso un percorso guidato la Writing (aka HOWritingAccount) dell'operazione. Tale percorso è gestito da un builderVM apposito. Concluso l'iter, viene chiesto di validare, e il valore della writing risultante sarà passato all'operazione, la quale è una Published custodita in un builderVM di grado superiore. Il writing, nel caso ad esempio di operazioni vincolate, tipo il consumo di scorte, può portare con se un amount parziale, che rappresenta un limite sulla quantità e, ma non necessariamente,un blocco del prezzo. Tale amount parziale si trova nell'oggetto del writing (aka HOWritingObject), e viene sempre tassativamente escluso in fase di encoding su firebase, ossia non viene mai salvato.

2. Una volta ricevuto il writing, la view principale, a seguito di un blocco condizionale, renderizza la seconda parte del modulo, che comprende l'amount, la time imputation, e le note; nonchè il dialog di salvataggio.

3. La view dell'amount (aka HOAmountLineView) onAppear esegue un metodo del builderVM, initOperationAmount, il quale crea un oggetto appunto di HOOperationAmount per la published sharedAmount del builderVM. In questa fase, se trova un valore parziale dell'amount nell'oggetto del writing lo passerà allo sharedAmount. In ogni caso lo sharedAmount partirà con un valore delle quantità pari a 1.

4. La view della timeImputation (HoTimeImputationLineView) onApper esegue dal builderVM l'initTimeImputation. Il time imputation è il periodo, mese anno o trimestre ecc, a cui imputare il costo. L'init esegue una serie di metodi per determinare se l'operazione necessita o meno di un'imputazione. Per esempio l'acquisto scorte non va imputato. Se l'imputazione è necessario verrà inizializzato la sharedTimeImputation, una published nel builderVM, che avrà il mese e l'anno della data di regolamento. L'utente potrà variare i valori, e scegliere dei periodi (bimestre, semestre, ecc) prestabiliti in base al tipo di operazione. Le utenze per esempio arriveranno con bimestre come periodo di default. Gli acquisti pluriennali avranno un valore di default e non vi sarà possibilità altra di scelta.

5. Nel caso appunto di operazioni pluriennali, verrà inizializzata una scrittura associata, di ammortamento, la quale richiederà all'utente un'imputazione oltre che temporare anche su quale attività specificica.

6. Al termine il builderVM creerà l'operazione principale, e qualora esista una writing associata creerà una operazione associata. In quest'ultimo caso l'operazione principale prenderà solo lo sharedAmount, mentre l'associata avrà oltre lo sharedAmount anche la timeImputation.

7. Riepilogando:
- La writing ha un builder apposito. Una volta validata viene renderizzata la seconda parte del modulo e la prima parte, ossia la writing, sarà visibile ma non modificabile.
- La data di regolamento sarà modificata direttamente sulla published dell'operazione. Come le note. 
- L'amount e la timeImputation e l'eventuale ImputationAccount useranno delle published nel builderVM e saranno copiate all'operazione principale e/o associata una volta che l'utente manderà in Salvataggio.

DA SISTEMARE

- Possibile fonte di bug il segno negativo nelle quantità recuperate nel partialAmount.A seconda dell'operazione ci serve recuperare le quantità già acquistate, ad esempio per un consumo scorte,o le quantità consumate da magazzino per una vendita corrente. Le due operazioni hanno la stessa logica ma vengono contabilizzate con segni diversi quindi una quantà consumabile ritorna con segno positivo, mentre una vendibile con segno negativo. Questo può creare bug. Da correggere

