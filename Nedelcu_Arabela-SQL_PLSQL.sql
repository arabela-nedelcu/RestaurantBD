 ---------11.Implementarea a 3 cereri SQL complexe

/*Sa se afiseze id-ul, numele si valoarea totala a produselor vandute care necesita gatire. Afisarea se va realiza descrescator dupa aceasta suma si va fi limitata la primele 10 produse*/

SELECT oi.itemId, i.title, sum(i.price) as total_vanzari
FROM order_item oi
LEFT JOIN item i ON oi.itemId=i.id
    WHERE i.cooking = 1
    GROUP BY oi.itemId, i.title
    ORDER BY total_vanzari DESC
    FETCH FIRST 10 ROWS ONLY;
    
/*Sa se afiseze cel mai vandut preparat. Daca au fost vandute acelasi numar de portii din mai multe preparate, atunci sa se afiseze cele mai vandute preparate.*/
                     
SELECT oi.itemID, i.title, COUNT(oi.itemId)nr_portii_vandute
FROM order_item oi
JOIN item i ON oi.itemID = i.id
GROUP BY oi.itemID, i.title
HAVING COUNT(oi.itemId) =(SELECT MAX(cnt)
                         FROM (SELECT itemId, count(itemId)cnt
                                FROM order_item
                                GROUP BY itemid))        
              
            
/*Sa se afiseze numele furnizorului ce livreaza restaurantului cele mai putine produse sub forma: <nume_furizor> furnizeaza <total> produse.*/
WITH cte AS(
SELECT v.id, v.name nume,  COUNT(ing.name) total  
FROM vendor v
JOIN ingredient ing on v.id=ing.vendorId
GROUP BY v.id, v.name
UNION 
SELECT v.id, v.name nume, COUNT(i.title) total
FROM vendor v
JOIN item i on v.id=i.vendorId
GROUP BY v.id, v.name)

SELECT nume  || ' ' || 'furnizeaza ' || total || ' produse' 
FROM cte 
WHERE total = (SELECT MIN(total)
                FROM cte);
                

 --------12. Definirea unui subprogram stocat care sã utilizeze un tip de cursor studiat
 
  
/*Sa se creeze o procedura care primete ca parametru o valoare totala a comenzii. Aceasta procedura contine cursor care determina toate comenzile mai mari decat un numar introdus de la tastatura si care intoarce 
numele clientului, data_comanda, statusul comenzii si valoarea totala a acesteia. Aceste informatii vor fi afisate concatenat,iar va fi separat de un rand de linii .*/
CREATE OR REPLACE PROCEDURE proc_cursor (valoare IN NUMBER)
AS
BEGIN
DECLARE 
     
     nume_client VARCHAR2(50);
     data_co DATE;
     status_comanda VARCHAR2(50);
     valoare_comanda NUMBER;
  
    CURSOR c IS
        SELECT c.firstName || ' ' || c.lastName, o.createdAt, o.status, SUM(oi.quantity * i.price)
        FROM customer c
        JOIN delivery_track dt ON c.id=dt.customerID
        JOIN bill o ON dt.billId = o.id
        JOIN order_item oi ON o.id=oi.orderId
        JOIN item i ON oi.itemId=i.id
        GROUP BY c.firstName, c.lastName, o.createdAt, o.status
        HAVING SUM(oi.quantity * i.price) > valoare;     
   
BEGIN

    OPEN c;
        DBMS_OUTPUT.PUT_LINE('Nume client || Data comenzii || Status comanda || Valoare Comanda');      
    LOOP
        
		FETCH c INTO nume_client, data_co, status_comanda, valoare_comanda; 
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');         
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE (nume_client||' || ' ||data_co||' || ' ||status_comanda||' || ' ||valoare_comanda||'lei'); 
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');       
              
    END LOOP;        
    CLOSE c;

END;
END proc_cursor;
/
 
EXEC proc_cursor(500);
 
  --------13. Definirea unui subprogram stocat de tip func?ie 
  
 /*Creati o functie ce primeste ca parametru de intrare o luna(formata din max 2 cifre) si un an (format din 4 cifre), 
 si afla produsul care s-au comandat cele mai mult in luna respectiva*/


CREATE OR REPLACE FUNCTION comanda_max (luna IN NUMBER, an IN NUMBER)
RETURN VARCHAR2 IS
  
    numar_argumente_invalid EXCEPTION;    
    tip_de_argumente_invalid EXCEPTION;     
    ptitle VARCHAR2(100);
  
BEGIN

    IF (luna IS NULL OR an IS NULL) THEN
     RAISE numar_argumente_invalid;
    END IF;
    
    IF ((luna<1 or luna>12) OR (an<1000 OR an>9999)) THEN 
    RAISE tip_de_argumente_invalid;
    END IF;
	   
    SELECT UPPER(i.title) || ' din meniul de '  || LOWER(m.title) INTO ptitle
    FROM item i
    JOIN order_item oi ON oi.itemId=i.id
    JOIN bill b ON oi.orderId = b.id
    JOIN menu_item mi ON i.id=mi.itemId
    JOIN menu m ON m.id=mi.menuID
    WHERE  EXTRACT(month FROM TO_DATE(createdAt, 'dd/mm/yyyy')) = luna
    AND EXTRACT(year FROM TO_DATE(createdAt, 'dd/mm/yyyy')) = an
    GROUP BY m.title, i.title
    ORDER BY  SUM(quantity) DESC
    FETCH FIRST 1 ROWS ONLY;
        
    RETURN ptitle;    
   
     EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20001, 'Nu exista niciun podus vandut in luna specificata');
    WHEN numar_argumente_invalid THEN
       RAISE_APPLICATION_ERROR(-20002, 'Nu ati specificat luna SI anul');
     WHEN tip_de_argumente_invalid THEN
       RAISE_APPLICATION_ERROR(-20003, 'Anul si/sau luna specificate nu sunt valide');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20004,'Alta eroare!');   

END comanda_max;
/
SELECT comanda_max (06, 2020)
FROM DUAL;

SELECT comanda_max (12, 1993)
FROM DUAL;

SELECT comanda_max (2, NULL )
FROM DUAL;
 
SELECT comanda_max (NULL, 2000 )
FROM DUAL;

 SELECT comanda_max (2000, 10000)
FROM DUAL;

SELECT comanda_max (2, 999)
FROM DUAL;
 
 --------14. Definirea unui subprogram stocat de tip procedurã 
 
 
/* Creati o procedura stocata care sa intoarca datele de pe factura in 3 seturi de date:
1. antetul facturii : id client, nume complet client, adresa de livrare, id comanda, data comanda, ora estimata de livrare, telefonul clientului in formatul “(####)###-###.”
2. produsele comandate: numele produselor, cantitatea, pretul fiecarui produs
3. detaliile de plata: subtotalul ,taxa de livrare si totalul facturii
in functie de id-ul de comanda. Printati factura*/

--functie ce formateaza numarul de telefon
 
 CREATE OR REPLACE FUNCTION format_telefon (nr_telefon VARCHAR2) 
 RETURN VARCHAR2 IS
  telefon VARCHAR2(25);
  nr_tel_invalid EXCEPTION;
 BEGIN 

    IF REGEXP_count(nr_telefon,'\d') != 10 
    THEN RAISE nr_tel_invalid;
    END IF;
  
  with cte AS 
    ( SELECT substr ( 
                TRANSLATE ( nr_telefon, '1234567890' || nr_telefon, '1234567890') , 1, 10 
                ) as clean_phone 
         FROM DUAL      
   )
        SELECT 
     '(' || substr(clean_phone, 1, 4)||')'|| substr(clean_phone, 5, 3)||'-'|| substr(clean_phone, 8, 3) INTO telefon            
        FROM cte;
 RETURN  telefon;
 
    EXCEPTION
    WHEN nr_tel_invalid THEN
       RAISE_APPLICATION_ERROR(-20000, 'Nu ati introdus un numar de telefon valid');
    WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
 
END format_telefon;
/

SELECT format_telefon('0651-626/266')
FROM DUAL;

SELECT format_telefon('065162626')
FROM DUAL;

--crearea procedurii cerute

CREATE OR REPLACE PROCEDURE detalii_factura
      (numar IN bill.id%TYPE,
       par_rc out sys_refcursor,
       par_rc2 out sys_refcursor,
       par_rc3 out sys_refcursor)
  IS 
    
    null_parameter exception;
    nr NUMBER;
 BEGIN   
  IF (numar IS NULL) THEN
     RAISE null_parameter;
    END IF;

  SELECT id INTO nr
  FROM bill
  WHERE id=numar;
  
  IF nr IS NULL THEN 
  RAISE NO_DATA_FOUND;
    END IF;
    
  OPEN par_rc FOR
  SELECT DISTINCT c.id AS id_client, 
        c.firstName || c.lastName AS nume_client, 
        c.address AS adresa_livrare,
        format_telefon(c.phone) AS telefon_client, 
        cy.name AS oras, 
        b.id AS id_comanda, 
        b.createdAt AS data_comanda, 
        To_Char(dt.estimatedTime, 'HH24')|| ':' || to_char(dt.estimatedTime, 'mi')|| ':' || to_char(dt.estimatedTime, 'SS') As ora_livrare
     
    FROM customer c
    JOIN city cy On cy.id = c.cityID
        JOIN delivery_track dt ON c.id=dt.customerID
        JOIN bill b ON dt.billId = b.id
        JOIN order_item oi ON b.id=oi.orderId
        
    WHERE b.id=numar;
        
    OPEN  par_rc2 FOR
    SELECT 
         i.title AS produs, 
        oi.quantity AS cantitate, 
         i.price   AS pret_produs
    FROM  item i
    JOIN order_item oi on oi.itemId=i.id
    JOIN   bill b ON b.id=oi.orderId
    WHERE b.id=numar;

     OPEN par_rc3 FOR
     SELECT DISTINCT b.subtotal AS subtotal,
        b.shipping AS taxa_livrare,
        b.total AS total_comanda
    FROM bill b
    WHERE id=numar;
      
 EXCEPTION
    WHEN NO_DATA_FOUND  THEN
       RAISE_APPLICATION_ERROR(-20000, 'Nu exista comenzi cu id-ul specificat');
    WHEN null_parameter THEN
       RAISE_APPLICATION_ERROR(-20001, 'Trebuie introdus id-ul comenzii');
    WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
  END detalii_factura;
/     

var rc refcursor
var rc2 refcursor
var rc3 refcursor
exec detalii_factura(6, :rc, :rc2, :rc3);
print rc;
print rc2;
print rc3;

var rc refcursor
var rc2 refcursor
var rc3 refcursor
exec detalii_factura(700, :rc, :rc2, :rc3);
print rc;
print rc2;
print rc3;

var rc refcursor
var rc2 refcursor
var rc3 refcursor
exec detalii_factura(NULL, :rc, :rc2, :rc3);
print rc;
print rc2;
print rc3;


 --------15. Definirea unui trigger de tip LMD la nivel de comandã
 /*trigger ce nu permite plasarea comenzilor in afara intervalului de functionare a restaurantului - 10:00 si 15:00*/
 
 
 CREATE OR REPLACE TRIGGER BI_new_order
    BEFORE INSERT ON order_item  
   

BEGIN
        IF (TO_CHAR(SYSDATE,'D') = 1)
            OR (TO_CHAR(SYSDATE,'HH24') NOT BETWEEN 10 AND 15)
        THEN
            RAISE_APPLICATION_ERROR(-20001,'Din pacate, nu poti plasa comenzi in afara programului!');
END IF;
END;
/
INSERT INTO order_item
(id, orderID, itemId, quantity)
VALUES
(20, 1, 1, 1  );


     
--------16. Definirea unui trigger de tip LMD la nivel de linie

/*trigger ce verifica adresa de email inserata a furnizorilor. aceasta trebuie sa fie sub forma "_______@_____.___"*/

CREATE OR REPLACE TRIGGER bi_vendor
     BEFORE INSERT ON vendor
     FOR EACH ROW
BEGIN
    
    IF :NEW.email IS NOT NULL
    AND :NEW.email NOT LIKE '%@%.%' THEN
        RAISE_APPLICATION_ERROR(-20000,'Adresa de email nu este valida');
    END IF;
END;
/

INSERT INTO vendor
(id, name, address,email, phone, cityId)
VALUES
(5, 'D-ale gurii', 'Str. Verzilor nr 4', 'dalegurii@office.ro', '0765234234', 6);

INSERT INTO vendor
(id, name, address,email, phone, cityId)
VALUES
(5, 'D-ale gurii', 'Str. Verzilor nr 4', 'dalegurii@officero', '0765234234', 6);