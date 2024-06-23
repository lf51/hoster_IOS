#  HOOperationUnit

L'operazione è costruita dall'utente partendo da un precompilato. I pre compilati saranno salvati su una collezione trasversale a tutti gli utenti. Trattasi delle operazioni più comuni, il cui catalogo può sempre essere espanso intervenendo direttamente su firebase o con applicativo apposito.

L'oggetto salvato non è un'operazione intera, ma la proprietà writing, ossia l'oggetto HOWritingAccount''

1. In fase di nuova Operazione l'utente può selezione il flow (entrata / uscita),l'area (scorte, corrente, pluriennale), e la categoria (merci, servizi ecc). Queste informazioni ci servono a filtrare dalla libreria tutte le operazioni (nella forma di HOWritingAccount) che corrispondono ai criteri. Una volta fatta la scelta l'oggetto HoWritingAccount sarà incorporato alla @State HoOperationUnit'

2. I dati custom da inserire sono: 
• Data Regolamente
• Periodo di imputazione
• writing/.info.subCategory 
• writing/.info.specification
• writing/.dare (or) .avere se l'operazione non è compilata. In ogni caso almeno uno dei due campi deve esserci, quindi l'utente dovrà scegliere l'account di imputazione. Se ti tratta ad esempio di prodotti per la pulizia, o la lavanderia ecc..'''
• Amount 
• Note 

Il movimento fra conti deve essere in background automatizzato
In caso di modifica di operazione esistente, solo e sempre i campi custom possono essere interessati

Riepilogando:
Dalla libreria l'operazione importerà:

• writing (HOWritingAccount) nella forma:
• writing/.movimento
• writing/.type
• writing/.dare // può mancare
• writing/.avere // può mancare (non possono mancare entrambi)
• writing/.info.category

Per operazioni pluriennali il periodo di ammortamento deve essere inserito dall'utente. Possiamo creare una breve guida in popMessage con i periodi consigliati per le principali categorie di possibili acquisti.'

Il campo /writing/.info/.category può in molti casi essere un duplicato del dare o dell'avere, ma non necessariamente. Ad esempio per operazioni di acquisto di merci per il magazzino lo è, ma quando le merci escono dal magazzino per essere imputate, ad esempio alla pulizia, non lo è più. Serve insieme alla sub e alla specification per identificare l'oggetto dell'operazione.
