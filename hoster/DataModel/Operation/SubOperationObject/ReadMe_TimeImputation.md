#  HOTimeImputation&HOMonthImputation

Le operazioni sono recuperate dal firebase filtrandole per anno di imputazione. Questo rende necessario salvare un array contenente appunto gli anni di imputazione.
Questo array si trova in HOTimeImputation

Qui abbiamo una monthImputation, oggeto HOMonthImputation, che ha un ruolo core. Contiene due proprietà, il mese di partenza e l'advancing.'
- Mese di partenza -> per le operazioni mensili coincide col mese di imputazione, per le operazioni spalmate su più mesi rappresenta il mese di partenza da cui calcolare i mesi di imputazione
- L'dvancing è un valore che contiene il mese di partenza, rappresenta l'intero nominale dei mesi in cui imputare l'operazione
- l'Amount dell'operazione, qualunque esssa sia, anche di ammortamento va messo per intero, e poi dividendolo per l'advancing otteniamo la quota mensile''

L'imputazione avverrà quindi per la quota mensile da imputare ai mesi dell'anno in considerazione. Per fare questo abbiamo una computed che ritorna un dizionario, dove le chiavi sono gli anni di imputazione, e i valori sono un array con le mensilità, in valore ordinale. Ovvero 1 sarù gennaio, 2 febbrario e così via. Questo ci permetterà, per le operazioni a cavallo, e per gli ammortamenti di imputare la quota mensile solo alle mensilità incluse per ciascuna chiave.
Nell'ipotesi di un ammortamento di 4 anni che parte da giugno 2024, per il 2024 avremo un valore complessivo che sarà dato dalla somma delle quote mensili dei soli sei mesi di imputazione.

Tutta la logica deglia ammortamenti e imputazione deve essere costruita su base mensile, per poi ottenere il computo annuo attraverso la somma delle quote.

