DROP TABLE Clients CASCADE CONSTRAINTS;
DROP TABLE Produits CASCADE CONSTRAINTS;
DROP TABLE Commandes CASCADE CONSTRAINTS;
DROP TABLE LignesCommande CASCADE CONSTRAINTS;

CREATE TABLE Clients (idClient NUMBER, nomClient VARCHAR(25), prenomClient VARCHAR(25), sexeClient CHAR(1), dateNaissanceClient DATE, villeClient VARCHAR(35), telephoneClient VARCHAR(14),
CONSTRAINT pk_Clients PRIMARY KEY (idClient),
CONSTRAINT nn_Client_nom CHECK (nomClient IS NOT NULL));

CREATE TABLE Commandes (idCommande NUMBER, dateCommande DATE, idClient NUMBER, montantCommande NUMBER, etatCommande VARCHAR(15),
CONSTRAINT pk_Commandes PRIMARY KEY (idCommande),
CONSTRAINT fk_Commandes_Client FOREIGN KEY (idClient) REFERENCES Clients(idClient));

CREATE TABLE Produits (idProduit NUMBER, nomProduit VARCHAR(35), categorieProduit VARCHAR(25), prixProduit NUMBER,
CONSTRAINT pk_Produits PRIMARY KEY (idProduit),
CONSTRAINT nn_Produits_nom CHECK (nomProduit IS NOT NULL));

CREATE TABLE LignesCommande (idCommande NUMBER, idProduit NUMBER,
CONSTRAINT pk_LignesCommande PRIMARY KEY (idCommande, idProduit),
CONSTRAINT fk_LignesCommande_Commande FOREIGN KEY (idCommande) REFERENCES Commandes(idCommande),
CONSTRAINT fk_LignesCommande_Produit FOREIGN KEY (idProduit) REFERENCES Produits(idProduit));


INSERT INTO Clients (SELECT * FROM Palleja.OPT_Clients);
INSERT INTO Produits (SELECT * FROM Palleja.OPT_Produits);
INSERT INTO Commandes (SELECT * FROM Palleja.OPT_Commandes);
INSERT INTO LignesCommande (SELECT * FROM Palleja.OPT_LignesCommande);

COMMIT;

SET AUTOTRACE TRACEONLY

/*---------QUESTION 2--------------*/

SELECT sexeClient, villeClient
FROM  Clients
WHERE nomClient='Palleja'

/*---------QUESTION 3--------------*/

/* deux-trois fois plus de blocs lus dans le cas où on n'utilise pas les index*/

SELECT /*+ index(Clients pk_Clients) */  *
FROM  Clients
WHERE IDClient!=1000


/* on l'a pas utiliser car on demande un nombre de ligne superieur à 5% de la table, l'index n'est plus rentable*/
/*la c'est po utilisé*/
SELECT *
FROM Commandes
WHERE idCommande>60000
/*la cest utilisé*/
SELECT *
FROM  Commandes
WHERE idCommande>99000

/*---------QUESTION 4--------------*/
/*ça lit donc un peu plus de blocs si on n'utilise pas l'index*/

SELECT /*+ no_index(Commandes idxClientsnomClient) */ *
FROM CLIENTS
WHERE nomClient='Claude'

SELECT *
FROM CLIENTS
WHERE nomClient='Claude'
CREATE INDEX idxClientsnomClient ON Clients (nomClient)


/*---------QUESTION 5--------------*/
CREATE INDEX idxCommandesmontantCommande ON Commandes (montantCommande)

/*le temps de varie pas bcp mais le nobmre de blocs si, moins de bloc pour l'utilisation des index*/

UPDATE /*+ no_index(Commandes idx_Commandes_montantCommande) */ Commandes
SET montantCommande=montantCommande+10

UPDATE Commandes
SET montantCommande=montantCommande-10

/*---------QUESTION 6--------------*/
 /* l'index a bien été utilisé */
SELECT *
FROM Commandes
WHERE montantCommande>3500*3


/*---------QUESTION 7--------------*/
/*204 	blocs lus */
SELECT *
FROM Clients 
WHERE prenomClient='Pierre' AND villeClient='Marseille'


CREATE INDEX idxClientsprenomClient ON Clients (prenomClient)
CREATE INDEX idxClientsvilleClient ON Clients (villeClient)
/*82 blocs lus*/
DROP INDEX idxClientsprenomClient
DROP INDEX idxClientsvilleClient

CREATE INDEX idxClieprenClieVilleClient ON Clients (prenomClient,villeClient)
/*100 blocs lus*/
DROP INDEX idxClieprenClieVilleClient

SELECT *
FROM Clients 
WHERE prenomClient='Xavier'
/* l'index double peut quand meme etre utilisé sur seulement une seul condition*/

SELECT *
FROM Clients 
WHERE villeClient='Montpellier'
/*dans ce cas la l'index n'est pas utilisé, je sais pas pk*/

SELECT villeClient
FROM Clients
WHERE nomClient='Xavier'
/*83 blocs lus + utilsiation de l'index */

/*---------QUESTION 8--------------*/
/*591 blocs lus et non utilisation de l'index*/
SELECT *
FROM Commandes
WHERE dateCommande IS NULL

CREATE INDEX idxCommandesdateCommande ON Commandes (dateCommande)

SELECT /*+ INDEX(Commandes idxCommandesdateCommande) */  *
FROM Commandes
WHERE dateCommande IS NULL
/* full access*/

CREATE INDEX idxCommandesdateIdCommande ON Commandes (idCommande, dateCommande)

SELECT /*+ INDEX(Commandes idxCommandesdateIdCommande) */  *
FROM Commandes
WHERE dateCommande IS NULL

/*En fait, les NULL ne sont pas stockés dans les index. Toutefois, ils peuvent être gérés dans 
les index concaténés à condition que les deux valeurs ne soient pas nulles. Créer donc un index 
concaténé avec la date de la commande et un champ qui ne peut pas  être NULL.  Ce  champ  peut  
être  soit  un  attribut  qui  ne  peut  pas  être NULL (par exemple  une  clé  primaire),  
soit  une  constante  ‘bidon’  (par  exemple  ‘1’).*/

/*---------QUESTION 9--------------*/

/*Le IN est beaucoup long que les jointure c'est pour cela que oracle convertie 
automatiquement en jointure sauf si on le lui interdit avec le hint */

SELECT nomProduit
FROM Produits P
	JOIN LignesCommande L ON P.idProduit=L.idProduit
	JOIN Commandes C ON L.idCommande=C.idCommande
	JOIN Clients Cl ON C.idClient=Cl.idClient
WHERE nomClient='Palleja'
/*537 	blocs lus 0.10 seconde*/

SELECT nomProduit 
FROM Produits
WHERE idProduit IN(
	SELECT idProduit
	FROM LignesCommande
	WHERE idCommande IN(
		SELECT idCommande
		FROM Commandes
		WHERE idClient IN(
			SELECT idClient
			FROM Clients
			WHERE nomClient='Palleja')))
/*8564 	blocs lus 0.30 seconde*/

SELECT /*+  NO_QUERY_TRANSFORMATION  */ nomProduit 
FROM Produits
WHERE idProduit IN(
	SELECT idProduit
	FROM LignesCommande
	WHERE idCommande IN(
		SELECT idCommande
		FROM Commandes
		WHERE idClient IN(
			SELECT idClient
			FROM Clients
			WHERE nomClient='Palleja')))
/*812831 blocs lus 10.30 secondes*/

/*---------QUESTION 10--------------*/

SELECT /*+ ORDERED */ nomProduit
FROM Produits
	JOIN LignesCommande ON Produits.idProduit=LignesCommande.idProduit
	JOIN Commandes ON LignesCommande.idCommande=Commandes.idCommande
	JOIN Clients ON Commandes.idClient=Clients.idClient
WHERE nomClient='Palleja'
/*1075 blocs lus 0.29 seconde*/

SELECT /*+ ORDERED */ nomProduit
FROM Clients 
	JOIN Commandes ON Commandes.idClient=Clients.idClient
	JOIN LignesCommande ON LignesCommande.idCommande=Commandes.idCommande
	JOIN Produits ON Produits.idProduit=LignesCommande.idProduit
WHERE nomClient='Palleja'
/*765 blocs lus 0.9 seconde*/

/*---------QUESTION 11--------------*/

SELECT /*+ OPTIMIZER_FEATURES_ENABLE('10.2.0.4') */  nomClient
FROM Clients
WHERE idClient NOT IN(
	SELECT idClient
	FROM Commandes)
/*520158 blocs lus 4.59 secondes */

SELECT /*+ OPTIMIZER_FEATURES_ENABLE('10.2.0.4') */ nomClient
FROM Clients
WHERE idClient IN(
	SELECT idClient
	FROM Clients
	MINUS
	SELECT idClient
	FROM Commandes)
/*636 blocs lus 0.07 seconde*/

SELECT /*+ OPTIMIZER_FEATURES_ENABLE('10.2.0.4') */ nomClient
FROM Clients c
WHERE NOT EXISTS(
	SELECT idClient
	FROM Commandes
	WHERE c.idClient=Commandes.idClient)
/*595 blocs lus 0.04*/

/*---------QUESTION 12--------------*/


SELECT Commandes.idCommande ,dateCommande
FROM Commandes 
	JOIN LignesCommande ON LignesCommande.idCommande=Commandes.idCommande
GROUP BY Commandes.idCommande, dateCommande
HAVING COUNT(DISTINCT idProduit)=(
	SELECT COUNT(idProduit)
	FROM Produits)
/*894 blocs lus 0.42 secondes*/

SELECT idCommande, dateCommande
FROM Commandes c
WHERE NOT EXISTS(
	SELECT idProduit FROM Produits
	MINUS
	SELECT idProduit FROM LignesCommande WHERE c.idCommande=LignesCommande.idCommande)
/*510215 blocs lus 8.42 secondes
donc non c'est clairement pas une bonne idée*/

/*---------QUESTION 13--------------*/
/*---------QUESTION 14--------------*/
/*---------QUESTION 15--------------*/
/*---------QUESTION 16--------------*/
