# MerossJsBundle


## Cos'è merossJsBundle
questo repository contiene un script bash che permette di poeter clonare il repository MerossApi e il repository MerossJS,
all'interno di due container. Il primo un container python e il secondo all' itnenro di un container httpd, utilizzando in entrambi i casi docker compose.
Il container MersoJS verrà creato solo dopo la compilazione del codice sorgente che sarà a carico dello script.

requisiti:

- Linux (testato su cebtos stream9)
- Dcoker
- Docker compose
- Npm (installato dallo script se mancante)
- Nvm (installato dallo script se mancante)

Il risultato saranno due container MerossApi e MersoJS esporti il primo sulla porta 4449, mentre il secondo sulla porta 8389.

Nel caso in cui si acceda da localhost, non occorrerà fare nussna azione aggiuntiva, altrimenti potrete mettere sotto reverse proxy entrambe i container e raggiungerli nel modo che più preferite.

All'interno della cartella MerossBundle troverete una cartella MerossJS, la quale al suo interno troverete un file .json di configurazione: come questo:




modificatelo solo se necessario nel caso in cui il backend sia esposto su un indirizzo diverso da localhost (default)

## Come installare
