ALTER SESSION SET NLS_DATE_FORMAT = "DD/MM";
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = "HH24:MI";
-- Ces deux requêtes permettent de faire coordonner le format de l'heure et de la date avec celui des données
DROP TABLE Avion;
DROP TABLE Pilote;
DROP TABLE Vols;
DROP TABLE Planning;
-- Celles-ci nettoient les tables du même nom que les notres 
CREATE TABLE Avion (Nserie NUMBER(3) CONSTRAINT pkavion primary key,
       	     	    aviontype VARCHAR2(10) CONSTRAINT cktype CHECK (aviontype='Airbus' OR aviontype='Bombardier' OR aviontype='Embraer' OR aviontype='Boeing'),
		    modele VARCHAR2(6),
		    capacite number(3) CONSTRAINT ckcap CHECK (capacite>0),
		    localisation CHAR(3));
CREATE TABLE Vols (Nvol NUMBER(4) CONSTRAINT pkvols primary key,
       	     	   heure TIMESTAMP,
		   depart CHAR(3),
		   arrivee CHAR(3));
CREATE TABLE Pilote (matricule NUMBER(1) CONSTRAINT pkpilote primary key,
       	     	     nom VARCHAR2(6),
		     age NUMBER(2),
		     anciennete NUMBER(2) CONSTRAINT ckanci CHECK (anciennete>=0));
CREATE TABLE Planning (Nvol NUMBER(4),
       	     	       datevol DATE ,
		       matricule NUMBER(1),
		       Nserie NUMBER(3),
		       PRIMARY KEY(nvol,datevol));	       
@donnees
--permet d'entrer les données
--QUESTION 1
select aviontype,modele from Avion where capacite=(select min(capacite) from Avion);
--QUESTION 2
select modele,capacite from Avion,Planning,Vols where(Vols.Nvol=Planning.Nvol
												and Avion.Nserie=Planning.Nserie
												and datevol='10/11'
												and arrivee='NCE');											
--QUESTION 3
select nom from Pilote where anciennete=( select max(anciennete) from Pilote );
-- QUESTION 4
(select nom,age from Pilote,Planning,Vols where Planning.matricule=Pilote.matricule
										and Vols.Nvol=Planning.Nvol
										and depart='ORY'
										and arrivee='TLS') intersect(									
select nom,age from Pilote,Planning,Vols where Planning.matricule=Pilote.matricule
										and Vols.Nvol=Planning.Nvol
										and depart='TLS'
										and arrivee='ORY');
--QUESTION 5
select distinct(nom) from Pilote,Planning,Vols where (Pilote.matricule=Planning.matricule
										and Vols.Nvol=Planning.Nvol
										and depart='LHR');
										
--QUESTION 6
select arrivee,heure,nom from Vols,Pilote,Planning where Planning.matricule=Pilote.matricule
													and Vols.Nvol=Planning.Nvol
													and nom like 'S%'
													order by heure ;
													
--QUESTION 7
--Celui qui assure le plus de vols
select nom from Pilote where matricule=(select matricule from (select matricule,count(matricule) as total from Planning group by matricule)where total=(select max(count(matricule)) from Planning group by matricule));
--Celui qui assure le moins de vols
-- NON FAITE
--QUESTION 8
select nom from Pilote
minus
(select nom from Pilote,Vols,Planning where Planning.matricule=Pilote.matricule
										and Vols.Nvol=Planning.Nvol										
										and arrivee='PRG')
union
(select nom from Pilote,Vols,Planning where Planning.matricule=Pilote.matricule
										and Vols.Nvol=Planning.Nvol										
										and depart='PRG');									
-- On considère les pilotes qui ne sont pas allés à Pragues au départ et l'arrivée

--QUESTION 9

select Nvol from Vols where heure>='07:00'
					and heure<='11:00';
--QUESTION 10
(select nom,count(planning.Nvol) from Pilote,Planning where Planning.matricule=Pilote.matricule group by Pilote.nom)union(select nom,0 from Pilote where matricule not in (select matricule from Planning));
--QUESTION 11
select aviontype,count(planning.Nvol) from Avion,Planning where Avion.Nserie=Planning.Nserie group by Avion.aviontype;
--QUESTION 12

select aviontype,count(planning.Nvol) from Avion,Planning where Avion.Nserie=Planning.Nserie group by Avion.aviontype order by count(planning.Nvol) asc;
--QUESTION 13
select Nvol from Vols where heure>='12:00';
--QUESTION 14
select Nvol,arrivee from Vols where depart='CDG' and heure>'15:00';
-- on considere 1 heure de trajet entre LHR et CDG
--QUESTION 15
select nom from Pilote where matricule in(select matricule from
(select matricule,count(matricule) as total from Planning,Avion where Avion.Nserie=Planning.Nserie 
																and aviontype='Airbus' 
																group by matricule) 
																where total=(select max(count(matricule)) from Planning, Avion 
																where Avion.Nserie=Planning.Nserie 
																and aviontype='Airbus' group by matricule));															
--QUESTION 16
select Nserie,localisation from Avion where Nserie not in ( select Nserie from Planning );
--QUESTION 17
select distinct Nserie from Planning,Vols where Planning.Nvol=Vols.Nvol and arrivee = 'PRG';
--QUESTION 18
select Vols.depart, Vols.arrivee, sum(Avion.capacite) from Avion,Planning, Vols
where Avion.Nserie=Planning.Nserie and Planning.Nvol=Vols.Nvol
group by Vols.depart, Vols.arrivee
having sum(Avion.capacite)=(select max(nombre)
from(select sum(Avion1.capacite) as nombre  from Avion Avion1 ,Planning Planning1, Vols Vols1 where Avion1.Nserie=Planning1.Nserie and Planning1.Nvol=Vols1.Nvol group by Vols1.Nvol));
--QUESTION 19
select depart,arrivee from Vols where Nvol not in(select Nvol from Planning);
--QUESTION 20
select nom from (select nom,modele from Pilote, Avion , Planning where Pilote.matricule=Planning.matricule and Avion.Nserie=Planning.Nserie) R,Avion where Avion.modele=R.modele group by nom having count(Avion.modele)=(select count(modele) from Avion);
