DROP TABLE Travailler CASCADE CONSTRAINTS;
DROP TABLE EtreAffecte CASCADE CONSTRAINTS;
DROP TABLE Projets CASCADE CONSTRAINTS;
DROP TABLE Equipes CASCADE CONSTRAINTS;
DROP TABLE Salaries CASCADE CONSTRAINTS;

/* CREATION DES TABLES */

CREATE TABLE Salaries
(codeSalarie VARCHAR(5), nomSalarie VARCHAR(25), prenomSalarie VARCHAR(25), nbTotalJourneesTravail NUMBER,
CONSTRAINT pk_Salaries PRIMARY KEY (codeSalarie));

CREATE TABLE Equipes
(codeEquipe VARCHAR(5), nomEquipe VARCHAR(25), codeSalarieChef VARCHAR(5),
CONSTRAINT pk_Equipes PRIMARY KEY (codeEquipe),
CONSTRAINT fk_Equipes_codeSalarieChef FOREIGN KEY (codeSalarieChef) REFERENCES Salaries(codeSalarie));

CREATE TABLE Projets
(codeProjet VARCHAR(5), nomProjet VARCHAR(25), villeProjet VARCHAR(25), codeEquipe VARCHAR(25),
CONSTRAINT nn_Projets CHECK (codeEquipe IS NOT NULL),
CONSTRAINT pk_Projets PRIMARY KEY (codeProjet),
CONSTRAINT fk_Projets_codeEquipe FOREIGN KEY (codeEquipe) REFERENCES Equipes(codeEquipe));

CREATE TABLE EtreAffecte
(codeSalarie VARCHAR(5), codeEquipe VARCHAR(5),
CONSTRAINT pk_EtreAffecte PRIMARY KEY (codeSalarie, codeEquipe),
CONSTRAINT fk_EtreAffecte_codeSalarie FOREIGN KEY (codeSalarie) REFERENCES Salaries(codeSalarie),
CONSTRAINT fk_EtreAffecte_codeEquipe FOREIGN KEY (codeEquipe) REFERENCES Equipes(codeEquipe));

CREATE TABLE Travailler
(codeSalarie VARCHAR(5), dateTravail DATE, codeProjet VARCHAR(5),
CONSTRAINT pk_Travailler PRIMARY KEY (codeSalarie, dateTravail),
CONSTRAINT fk_Travailler_codeSalarie FOREIGN KEY (codeSalarie) REFERENCES Salaries(codeSalarie),
CONSTRAINT fk_Travailler_codeProjet FOREIGN KEY (codeProjet) REFERENCES Projets(codePRojet));

/* INSERTION DE DONNEES */ 

INSERT INTO Salaries (codeSalarie, nomSalarie,prenomSalarie, nbTotalJourneesTravail) (SELECT * FROM Palleja.UNI_Salaries);
INSERT INTO Equipes (codeEquipe, nomEquipe, codeSalarieChef) (SELECT * FROM Palleja.UNI_Equipes);
INSERT INTO PROJETS (codeProjet, nomProjet, villeProjet, codeEquipe) (SELECT * FROM Palleja.UNI_Projets);
INSERT INTO EtreAffecte (codeSalarie, codeEquipe) (SELECT * FROM Palleja.UNI_EtreAffecte);
INSERT INTO Travailler (codeSalarie, dateTravail, codeProjet) (SELECT * FROM Palleja.UNI_Travailler);

COMMIT;


/*Question 4*/

CREATE or  REPLACE PROCEDURE AjouterJourneeTravail(
p_codeSalarie Travailler.codeSalarie%TYPE,
p_codeProjet Travailler.codeProjet%TYPE,
p_dateTravail Travailler.dateTravail%TYPE) IS

Begin

INSERT INTO Travailler
VALUES (p_codeSalarie, p_dateTravail, p_codeProjet);

UPDATE Salaries
SET nbTotalJourneesTravail=nbTotalJourneesTravail+1
WHERE codeSalarie=p_codeSalaire;

END;
/
SHOW ERRORS



/*Question 5    à tester*/


CREATE or REPLACE PROCEDURE AffecterSalarieEquipe(
	p_codeSalarie EtreAffecte.codeSalarie%TYPE,
	p_codeEquipe EtreAffecte.codeEquipe%TYPE) IS 

v_nb NUMBER;

BEGIN

SELECT COUNT(codeEquipe) INTO v_nb
FROM EtreAffecte
WHERE codeSalarie=p_codeSalarie;

IF v_nb<3 THEN 
INSERT INTO EtreAffecte
VALUES (p_codeSalarie, p_codeEquipe);
ELSE 
RAISE_APPLICATION_ERROR(-20001, 'Le salarié est deja affecté a au moins 3 équipes');
END IF;

END;
/
SHOW ERRORS



/*Question 6    à tester*/
  

CREATE or REPLACE PROCEDURE SetSalarieChef(
	p_codeSalarie EtreAffecte.codeSalarie%TYPE,
	p_codeEquipe EtreAffecte.codeEquipe%TYPE) IS 

v_nb NUMBER;

BEGIN

SELECT COUNT(*) INTO v_nb
FROM EtreAffecte
WHERE p_codeSalarie=codeSalarie AND p_codeEquipe=codeEquipe;

IF v_nb>0 THEN
UPDATE Equipes
SET codeSalarieChef=p_codeSalarie
WHERE codeEquipe=p_codeEquipe;
ELSE 
RAISE_APPLICATION_ERROR(-20001, 'Le salarié ne peut pas etre chef si il ne fait pas parti du groupe');
END IF;

END;
/
SHOW ERRORS



/*Question 7    à finir*/


CREATE or REPLACE PROCEDURE AffecterSalarieProjet(
	p_codeSalarie EtreAffecte.codeSalarie%TYPE,
	p_codeProjet Projets.codeProjet%TYPE, 
	p_dateTravail Travailler.dateTravail%TYPE) IS 

v_NBcodeE NUMBER;

BEGIN

SELECT count(codeEquipe) INTO v_NBcodeE
FROM EtreAffecte
WHERE codeSalarie=p_codeSalarie;

IF v_NBcodeE>0 THEN
AjouterJourneeTravail(p_codeSalarie ,p_codeProjet, p_dateTravail);
ELSE 
RAISE_APPLICATION_ERROR(-20001, 'Le salarié n est pas associé a cette equipe');
END IF;


END;
/
SHOW ERRORS
