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



/*Question 5*/


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



/*Question 6*/
  

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



ALTER TABLE Equipes ADD CONSTRAINT
fk_Equipes_ChefAffecte FOREIGN KEY (codeEquipe, codeSalarieChef)
					   REFERENCES EtreAffecte(codeEquipe,codeSalarie);



/*Question 7*/


CREATE or REPLACE PROCEDURE AjouterJourneeTravailSpec(
	p_codeSalarie EtreAffecte.codeSalarie%TYPE,
	p_codeProjet Projets.codeProjet%TYPE, 
	p_dateTravail Travailler.dateTravail%TYPE) IS 

v_NBcodeE NUMBER;

BEGIN

SELECT count(*) INTO v_NBcodeE
FROM EtreAffecte
JOIN PROJETS ON PROJETS.codeEquipe=EtreAffecte.codeEquipe
WHERE codeSalarie=p_codeSalarie AND codeProjet=p_codeProjet;

IF v_NBcodeE=0 THEN
RAISE_APPLICATION_ERROR(-20001, 'Le salarié n est pas associé à cette equipe');

ELSE 
INSERT INTO Travailler(codeSalarie,codeProjet,dateTravail) VALUES (p_codeSalarie,p_codeProjet,p_dateTravail);
UPDATE Salaries
SET nbTotalJourneesTravail = nbTotalJourneesTravail +1
WHERE codeSalarie = p_codeSalarie;
END IF;


END;
/
SHOW ERRORS



/*Question 8 Trigger*/


CREATE OR REPLACE TRIGGER TriggerAjouterJourneeTravail
AFTER
INSERT
ON Travailler
FOR EACH ROW

BEGIN

UPDATE Salaries
SET nbTotalJourneesTravail=nbTotalJourneesTravail+1
WHERE codeSalarie=:NEW.codeSalarie;

END;
/
SHOW ERRORS


/*Question 9*/

CREATE OR REPLACE TRIGGER TriggerAffecterSalarieEquipe
BEFORE 
INSERT 
ON EtreAffecte
FOR EACH ROW

DECLARE
v_nb NUMBER;

BEGIN

SELECT COUNT(codeEquipe) INTO v_nb
FROM EtreAffecte
WHERE codeSalarie=:NEW.codeSalarie;

IF v_nb>=3 THEN 
RAISE_APPLICATION_ERROR(-20001, 'Le salarié est deja affecté a au moins 3 équipes');
END IF;

END;
/
SHOW ERRORS


/*Question 10*/

CREATE OR REPLACE TRIGGER TriggerAjouterJourneeTravail
AFTER
INSERT | DELETE
ON Travailler
FOR EACH ROW

BEGIN

IF (INSERTING) THEN
UPDATE Salaries
SET nbTotalJourneesTravail=nbTotalJourneesTravail+1
WHERE codeSalarie=:NEW.codeSalarie;
END IF;

IF (DELETING) THEN
UPDATE Salaries
SET nbTotalJourneesTravail=nbTotalJourneesTravail-1
WHERE codeSalarie=:OLD.codeSalarie;
END IF;

END;
/
SHOW ERRORS


/*Question 12*/

CREATE OR REPLACE VIEW Affectations AS
SELECT Salaries.codeSalarie, Salaries.nomSalarie, Salaries.prenomSalarie, Equipes.codeEquipe, Equipes.nomEquipe
FROM Salaries
JOIN EtreAffecte ON Salaries.codeSalarie=EtreAffecte.codeSalarie
Join Equipes ON Equipes.codeEquipe=Equipes.codeEquipe;



/*Question 13*/


/*solution(solution uniquement du premiers point du 13) si l'insertion dans la vue ne créé ps d'insertion dans EtreAffecte

CREATE OR REPLACE TRIGGER TriggerInsertAffectations
INSTEAD OF INSERT ON Affectations
FOR EACH ROW

DECLARE
v_nbSalarie NUMBER;
v_nbSalarieVerif NUMBER;
v_nbEquipe NUMBER;
v_nbEquipeVerif NUMBER;
v_nbAffectation NUMBER;

BEGIN

RAISE_APPLICATION_ERROR(-20001, ''); // fonction si RAISE ne stop pas l'xécution du trigger

SELECT COUNT(*) INTO v_nbSalarie
FROM Salaries
WHERE codeSalarie=:NEW.codeSalarie;

SELECT COUNT(*) INTO v_nbEquipe
FROM Equipes
WHERE codeEquipe=:NEW.codeEquipe;

SELECT COUNT(*) INTO v_nbAffectation
FROM EtreAffecte
WHERE codeEquipe=:NEW.codeEquipe AND codeEquipe=:NEW.codeEquipe;

IF v_nbAffectation=0 THEN
	IF v_nbEquipe>0 AND v_nbSalarie>0 THEN
	INSERT INTO EtreAffecte(codeSalarie,codeEquipe)
	VALUES(:NEW.codeSalarie,:NEW.codeEquipe);
	ELSE
		IF v_nbEquipe=0 THEN
		INSERT INTO Equipes(codeEquipe,nomEquipe,codeSalarieChef)
		VALUES(:NEW.codeEquipe:NEW.nomEquipe,NULL;
		END IF;

		IF v_nbSalarie=0 THEN
		INSERT INTO Salaries(codeSalarie,nomSalarie,prenomSalarie,nbTotalJourneesTravail)
		VALUES(:NEW.codeSalarie,:NEW.nomSalarie,:NEW.prenomSalarie,0);
		END IF;

		INSERT INTO EtreAffecte(codeSalarie,codeEquipe)
		VALUES(:NEW.codeSalarie,:NEW.codeEquipe);
	END IF;
END IF

END;
/
SHOW ERRORS

Sinon cette solution :*/


CREATE OR REPLACE TRIGGER TriggerInsertAffectations
INSTEAD OF INSERT ON Affectations
FOR EACH ROW

DECLARE
v_nbSalarie NUMBER;
v_nbSalarieVerif NUMBER;
v_nbEquipe NUMBER;
v_nbEquipeVerif NUMBER;
v_nbAffectation NUMBER;

BEGIN


/*SOLUTION COMPLETE MAIS A VERIFIER*/
SELECT COUNT(*) INTO v_nbSalarie
FROM Salaries
WHERE codeSalarie=:NEW.codeSalarie AND nomSalarie=:NEW.nomSalarie AND prenomSalarie=:NEW.prenomSalarie ;

SELECT COUNT(*) INTO v_nbSalarieVerif
FROM Salaries
WHERE codeSalarie=:NEW.codeSalarie;

SELECT COUNT(*) INTO v_nbEquipe
FROM Equipes
WHERE codeEquipe=:NEW.codeEquipe AND nomEquipe=:NEW.nomEquipe;

SELECT COUNT(*) INTO v_nbEquipe
FROM Equipes
WHERE codeEquipe=:NEW.codeEquipe;

IF v_nbSalarie=v_nbSalarieVerif AND v_nbEquipe=v_nbEquipeVerif THEN
	IF v_nbSalarie=0 THEN
	INSERT INTO Salaries(codeSalarie,nomSalarie,prenomSalarie,nbTotalJourneesTravail)
	VALUES(:NEW.codeSalarie,:NEW.nomSalarie,:NEW.prenomSalarie,0);
	END IF;

	IF v_nbEquipe=0 THEN
	INSERT INTO Equipes(codeEquipe,nomEquipe,codeSalarieChef)
	VALUES(:NEW.codeEquipe,:NEW.nomEquipe,NULL;
	END IF;
ELSE 
RAISE_APPLICATION_ERROR(-20001, 'les attributs ne sont pas bon'); 
END IF;

END;
/
SHOW ERRORS



/*---------LES TESTS--------------*/
CALL AjouterJourneeTravail('S2','P3','10/012014');
SELECT  nbTotalJourneesTravail
FROM Salaries
WHERE codeSalarie = 'S2';

CALL AffecterSalarieEquipe('S1','E3');
SELECT * 
FROM EtreAffecte
WHERE codeSalarie = 'S1' AND codeEquipe = 'E3';

CALL AffecterSalarieEquipe('S8','E1');
SELECT * 
FROM EtreAffecte
WHERE codeSalarie = 'S8' AND codeEquipe = 'E1';

CALL SetSalarieChef('S3','E4');
SELECT codeSalarieChef
FROM Equipes
WHERE codeEquipe = 'E4';

CALL SetSalarieChef('S4','E3');
SELECT codeSalarieChef
FROM Equipes
WHERE codeEquipe = 'E3';

CALL AffecterSalarieProjet('S2','P3','11/01/2014');
SELECT nbTotalJourneesTravail
FROM Salaries
WHERE codeSalarie = 'S2';

CALL AffecterSalarieProjet('S2','P5','12/01/2014');
SELECT nbTotalJourneesTravail
FROM Salaries
WHERE codeSalarie = 'S2';