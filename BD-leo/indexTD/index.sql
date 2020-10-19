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


/*---------QUESTION 1--------------*/
SET TIMING ON;
SET AUTOTRACE ON;

/*---------QUESTION 2--------------*/
SELECT sexeClient, villeClient
FROM Clients
WHERE nomClient='Palleja';

/*---------QUESTION 3--------------*/
SELECT *
FROM Clients
WHERE idClient = 1000;

SELECT /*+ no_index(Clients pk_Clients) */ *
FROM Clients
WHERE idClient = 1000

SET AUTOTRACE TRACEONLY;
SELECT *
FROM Clients
WHERE idClient != 1000;

SET AUTOTRACE TRACEONLY;
SELECT /*+ no_index(Clients pk_Clients) */  *
FROM Clients
WHERE idClient != 1000;

SET AUTOTRACE TRACEONLY;
SELECT *
FROM Commandes
WHERE idCommande > 60000;

SET AUTOTRACE TRACEONLY;
SELECT *
FROM Commandes
WHERE idCommande > 99000;


set


/*---------QUESTION 4--------------*/
/*---------QUESTION 4--------------*/
/*---------QUESTION 4--------------*/
/*---------QUESTION 4--------------*/
/*---------QUESTION 4--------------*/
