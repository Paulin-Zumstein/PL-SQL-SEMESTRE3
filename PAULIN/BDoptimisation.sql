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



/*qustion 2.a*/

SELECT sexeClient, villeClient
FROM  Clients
WHERE nomClient='Palleja'

/*qustion 3*/

SELECT /*+ index(Clients pk_Clients) */  *
FROM  Clients
WHERE IDClient!=1000

SELECT *
FROM  Commandes
WHERE idCommande>99000


--Question 4

SELECT *
FROM CLIENTS
WHERE nomClient='Claude'

CREATE INDEX idx_Clients_nomClient ON Clients (nomClient)


--Question 5

UPDATE /*+ no_index(Commandes idx_Commandes_montantCommande) */ Commandes --SYNTAXE NE MARCHE PAS
SET montantCommande=montantCommande+10

CREATE INDEX idx_Commandes_montantCommande ON Commandes (montantCommande)

UPDATE Commandes
SET montantCommande=montantCommande-10

--Questin 6

SELECT *
FROM Commandes
WHERE montantCommande>3500*3

?


--Question 7

SELECT *
FROM Clients 
WHERE prenomClient='Pierre' AND villeClient='Marseille'

CREATE INDEX idx_Clients_prenomClient ON Clients (prenomClient)
CREATE INDEX idx_Clients_villeClient ON Clients (villeClient)

DROP INDEX idx_Clients_prenomClient
DROP INDEX idx_Clients_villeClient

CREATE INDEX idx_Clients_prenomClientVilleClient ON Clients (prenomClient,villeClient)

SELECT *
FROM Clients 
WHERE prenomClient='Xavier'

SELECT *
FROM Clients 
WHERE villeClient='Montpellier'


--Question 8

SELECT /*+ INDEX(Commandes idx_Commandes_dateIdCommande) */  *
FROM Commandes
WHERE dateCommande IS NULL

CREATE INDEX idx_Commandes_dateCommande ON Commandes (dateCommande)

CREATE INDEX idx_Commandes_dateIdCommande ON Commandes (idCommande, dateCommande)


--Question 9

SELECT nomProduit
FROM Produits
	JOIN LignesCommande ON Produits.idProduit=LignesCommande.idProduit
	JOIN Commandes ON LignesCommande.idCommande=Commandes.idCommande
	JOIN Clients ON Commandes.idClient=Clients.idClient
WHERE nomClient='Palleja'

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


--Question 10

SELECT /*+ ORDERED */ nomProduit
FROM Produits
	JOIN LignesCommande ON Produits.idProduit=LignesCommande.idProduit
	JOIN Commandes ON LignesCommande.idCommande=Commandes.idCommande
	JOIN Clients ON Commandes.idClient=Clients.idClient
WHERE nomClient='Palleja'

SELECT /*+ ORDERED */ nomProduit
FROM Clients 
	JOIN Commandes ON Commandes.idClient=Clients.idClient
	JOIN LignesCommande ON LignesCommande.idCommande=Commandes.idCommande
	JOIN Produits ON Produits.idProduit=LignesCommande.idProduit
WHERE nomClient='Palleja'


--Question 11

SELECT /*+ OPTIMIZER_FEATURES_ENABLE('10.2.0.4') */  nomClient
FROM Clients
WHERE idClient NOT IN(
	SELECT idClient
	FROM Commandes)

SELECT /*+ OPTIMIZER_FEATURES_ENABLE('10.2.0.4') */ nomClient
FROM Clients
WHERE idClient IN(
	SELECT idClient
	FROM Clients
	MINUS
	SELECT idClient
	FROM Commandes)

SELECT /*+ OPTIMIZER_FEATURES_ENABLE('10.2.0.4') */ nomClient
FROM Clients c
WHERE NOT EXISTS(
	SELECT idClient
	FROM Commandes
	WHERE c.idClient=Commandes.idClient)


--Question 12


SELECT Commandes.idCommande ,dateCommande
FROM Commandes 
	JOIN LignesCommande ON LignesCommande.idCommande=Commandes.idCommande
GROUP BY Commandes.idCommande, dateCommande
HAVING COUNT(DISTINCT idProduit)=(
	SELECT COUNT(idProduit)
	FROM Produits)

SELECT idCommande, dateCommande
FROM Commandes c
WHERE NOT EXISTS(
	SELECT idProduit FROM Produits
	MINUS
	SELECT idProduit FROM LignesCommande WHERE c.idCommande=LignesCommande.idCommande)