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
WHERE montantCommande/3>3500