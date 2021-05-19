--Creare baza de date

CREATE TABLE menu (
  id     NUMBER(10) CONSTRAINT menu_id_pk PRIMARY KEY,
  title VARCHAR2(60) CONSTRAINT menu_title_nn NOT NULL,
  summary VARCHAR2(60)
  );

CREATE TABLE menu_item (
  id     NUMBER(10) CONSTRAINT menu_item_id_pk PRIMARY KEY,
  menuId NUMBER(10) CONSTRAINT menu_item_menuId_nn NOT NULL,
  itemId NUMBER(10) CONSTRAINT menu_item_itemId_nn NOT NULL,
  active NUMBER(1) DEFAULT 1 CONSTRAINT menu_item_active_nn NOT NULL,
  
  CONSTRAINT fk_menu_item_menu
    FOREIGN KEY (menuId)
    REFERENCES menu (id)
    );
   
CREATE TABLE item (
  id     NUMBER(10) CONSTRAINT item_id_pk PRIMARY KEY,
  title VARCHAR2(60) CONSTRAINT item_title_nn NOT NULL,
  summary VARCHAR2(60),
  cooking NUMBER(1) DEFAULT 0 CONSTRAINT item_cooking_nn NOT NULL,
  sku VARCHAR2(100) CONSTRAINT item_sku_nn NOT NULL,
  price FLOAT DEFAULT 0 CONSTRAINT item_price_nn NOT NULL,
  vendorId NUMBER(10)
  );
  
  ALTER TABLE menu_item
  ADD CONSTRAINT fk_menu_item_item
  FOREIGN KEY (itemId)
  REFERENCES item (id);
 
CREATE TABLE recipe (
  id     NUMBER(10) CONSTRAINT recipe_id_pk PRIMARY KEY,
  itemId NUMBER(10) CONSTRAINT recipe_itemId_nn NOT NULL,
  ingredientId  NUMBER(10) CONSTRAINT recipe_ingredientId_nn NOT NULL,
  quantity FLOAT DEFAULT 0 CONSTRAINT recipe_quantity_nn NOT NULL,
  unit VARCHAR2(10) CONSTRAINT recipe_unit_nn NOT NULL,
  
    CONSTRAINT fk_recipe_item
    FOREIGN KEY (itemId)
    REFERENCES item (id)
    );
   
CREATE TABLE ingredient (
  id     NUMBER(10) CONSTRAINT ingredient_id_pk PRIMARY KEY,
  name VARCHAR2(60) CONSTRAINT ingredient_name_nn NOT NULL,
  vendorId NUMBER(10),
  quantity FLOAT DEFAULT 0 CONSTRAINT ingredient_quantity_nn NOT NULL,
  unit VARCHAR2(10) CONSTRAINT ingredient_unit_nn NOT NULL
  );

ALTER TABLE recipe
ADD CONSTRAINT fk_recipe_ingredient
  FOREIGN KEY (ingredientId)
  REFERENCES ingredient (id);
  
  CREATE TABLE city (
  id     NUMBER(10) CONSTRAINT city_id_pk PRIMARY KEY,
  name VARCHAR2(60) CONSTRAINT city_name_nn NOT NULL
  );
  
    CREATE TABLE vendor (
  id     NUMBER(10) CONSTRAINT vendor_id_pk PRIMARY KEY,
  name VARCHAR2(60) CONSTRAINT vendor_name_nn NOT NULL,
  address VARCHAR2(100),
  email VARCHAR2(50),
  phone VARCHAR(20),
  cityId  NUMBER(10)
  );
 
 ALTER TABLE ingredient
  ADD CONSTRAINT fk_ingredient_vendor
  FOREIGN KEY (vendorId)
  REFERENCES vendor (id);   
  
  ALTER TABLE item
  ADD CONSTRAINT fk_item_vendor
  FOREIGN KEY(vendorId)
  REFERENCES vendor(id);

ALTER TABLE vendor
ADD CONSTRAINT fk_city_vendor
FOREIGN KEY(cityId)
REFERENCES city(id);

CREATE TABLE customer (
  id     NUMBER(10) CONSTRAINT customer_id_pk PRIMARY KEY,
  firstName VARCHAR(50),
  lastName VARCHAR(50),
  email VARCHAR2(50),
  phone VARCHAR(20),
  address VARCHAR2(100),
  cityId  NUMBER(10)
);
ALTER TABLE customer
ADD CONSTRAINT fk_city_customer
FOREIGN KEY(cityId)
REFERENCES city(id);

CREATE TABLE order_item (
  id     NUMBER(10) CONSTRAINT order_item_id_pk PRIMARY KEY,
  orderId NUMBER(10) CONSTRAINT order_item_orderId_nn NOT NULL,
  itemId NUMBER(10) CONSTRAINT order_item_itemId_nn NOT NULL,
  quantity FLOAT DEFAULT 1 CONSTRAINT order_item_quantity_nn NOT NULL,
    
  CONSTRAINT fk_order_item_item
  FOREIGN KEY (itemId)
  REFERENCES item (id)
    );

CREATE INDEX idx_order_item_item
 ON order_item(itemId);

CREATE TABLE bill (
  id     NUMBER(10) CONSTRAINT bill_id_pk PRIMARY KEY,
  status       VARCHAR2(10)  CONSTRAINT bill_status_ck 
  CHECK (status IN ('New', 'Paid', 'Shipped', 'Delivered', 'Returned', 'Complete')),
  subTotal FLOAT DEFAULT 0 CONSTRAINT bill_subTotal_nn NOT NULL,
  shipping FLOAT DEFAULT 0 CONSTRAINT bill_shipping_nn NOT NULL,
  total FLOAT DEFAULT 0 CONSTRAINT bill_total_nn NOT NULL,
  createdAt DATE DEFAULT SYSDATE CONSTRAINT bill_createdAt_nn NOT NULL
  );
  
ALTER TABLE order_item
ADD CONSTRAINT fk_order_item_bill
    FOREIGN KEY (orderId)
    REFERENCES bill (id);

CREATE TABLE delivery_track(
  id     NUMBER(10) CONSTRAINT delivery_track_id_pk PRIMARY KEY,
  estimatedTime DATE DEFAULT SYSDATE CONSTRAINT delivery_track_createdAt_nn NOT NULL,
  customerId NUMBER(10) CONSTRAINT delivery_track_customerId_nn NOT NULL,
  billId NUMBER(10) CONSTRAINT delivery_track_billId_nn NOT NULL,
  
  CONSTRAINT fk_delivery_track_customer
  FOREIGN KEY (customerId)
  REFERENCES customer (id),
    
  CONSTRAINT fk_delivery_track_bill
  FOREIGN KEY (billId)
  REFERENCES bill (id)
  );
  
--Inserare date in baza de date
INSERT INTO city
(id, name)
SELECT 1, 'Bucuresti' FROM dual UNION ALL
SELECT 2, 'Galati' FROM dual UNION ALL
SELECT 3, 'Ploiesti' FROM dual UNION ALL
SELECT 4, 'Targoviste' FROM dual UNION ALL
SELECT 5, 'Baia Mare' FROM dual UNION ALL
SELECT 6, 'Braila' FROM dual UNION ALL
SELECT 7, 'Pitesti' FROM dual UNION ALL
SELECT 8, 'Brasov' FROM dual;


INSERT INTO vendor
(id, name, address, email, cityId, phone)
SELECT 1, 'Supermarket Romania', 'Bl. Iuliu Maniu 234', 'supermarket@office.ro', 1, '0725006233' FROM dual UNION ALL
SELECT 2, 'Pescaria "La Marian"', 'Str. Furnalistilor 23', 'marian@pescarie.ro', 2, '0755/344/829' FROM dual UNION ALL
SELECT 3, 'La Sibieni', 'Strada de Mijloc 132', 'sibieni@yahoo.com', 8, '0757 614 132' FROM dual UNION ALL
SELECT 4, 'Legume Pentru Toti', 'Str. Buzaului 45', 'legume@yahoo.com', 1, '0724837573' FROM dual;


  INSERT INTO menu
  (id, title, summary)
SELECT 1, 'Antreuri reci', 'Pentru cand esti pe fuga' FROM dual UNION ALL
SELECT 2, 'Antreuri calde', 'Pentru cand nu esti pe fuga' FROM dual UNION ALL
SELECT 3, 'Salate', 'Pentru cand vrei sa mananci sanatos' FROM dual UNION ALL
SELECT 4, 'Ciorbe si supe', 'Ca la mama acasa' FROM dual UNION ALL
SELECT 5, 'Carne', 'Pentru gurmandul din tine' FROM dual UNION ALL
SELECT 6, 'Garnituri', 'Aromate si gustoase' FROM dual UNION ALL
SELECT 7, 'Bauturi', 'De toate pentru toti' FROM dual;


INSERT INTO item
(id, title, summary, cooking, sku, price, vendorId)
SELECT 1, 'Platou traditional', 'Preparate traditionale', 1, 5, 60, NULL FROM dual UNION ALL
SELECT 2, 'Cascaval pane', 'Cascaval prajit in crusta de pesmet', 1, 6, 25, NULL FROM dual UNION ALL
SELECT 3, 'Salata de icre', 'Icre de crab cu ceapa verde', 1, 5, 22, NULL FROM dual UNION ALL
SELECT 4, 'Salata de vinete', 'Vinete proaspete cu ceapa verde', 1, 1, 22, NULL FROM dual UNION ALL
SELECT 5, 'Macaroane aurii', 'Macaroane la cuptor cu branza', 1, 2, 33, NULL FROM dual UNION ALL
SELECT 6, 'MBS', 'Mamaliga cu branza si smantana', 1, 2, 26, NULL FROM dual UNION ALL
SELECT 7, 'Salata Caesar', 'Salata, crutoane, piept de pui, parmezan, rosii', 1, 5, 32, NULL FROM dual UNION ALL
SELECT 8, 'Salata de ton', 'ton, salata , rosii, porumb, ceapa', 1, 5, 33, NULL FROM dual UNION ALL
SELECT 9, 'Supa crema de hribi', 'Crema cremelor din hribi cu ceapa si stinsa cu smantana', 1, 10, 40, NULL FROM dual UNION ALL
SELECT 10, 'Ciorba de pui a la grec', 'Fiarta la foc scazut, numai buna dreasa cu smantana', 1, 11, 20, NULL FROM dual UNION ALL
SELECT 11, 'Sarmale NU-MA-UITA', 'Sarmale din carne de vita servite cu mamaliguta si smantana', 1, 5, 34, NULL FROM dual UNION ALL
SELECT 12, 'Vitel De Vreme Buna', 'Carne de vita trasa la tigaie', 1, 3, 45, NULL FROM dual UNION ALL
SELECT 13, 'Piept de pui dungat', 'Piept de pui la gratar', 1, 10, 20, NULL FROM dual UNION ALL
SELECT 14, 'Pilaf Hipsteres', 'Pilaf de orez ca odinioara', 1, 10, 15, NULL FROM dual UNION ALL
SELECT 15, 'Legume asortate', 'Legume la tigaie', 1, 10, 20, NULL FROM dual UNION ALL
SELECT 16, 'Cafea', 'Cafea de cea mai buna calitate', 0, 20, 10, 1 FROM dual UNION ALL
SELECT 17, 'Bere', 'Bere transpirata numai buna de servit dupa o zi grea', 0, 15, 7,1 FROM dual UNION ALL
SELECT 18, 'Ceai', 'Pentru cand e frig afara', 0, 13, 7,1 FROM dual UNION ALL
SELECT 19, 'Apa', 'Ca-i mai bune decat toate', 0, 12, 5,1 FROM dual;


INSERT INTO menu_item
(id, menuId, itemId, active)
SELECT 1, 1, 1 , 1 FROM dual UNION ALL
SELECT 2, 1, 2 , 1 FROM dual UNION ALL
SELECT 3, 1, 3 , 1 FROM dual UNION ALL
SELECT 4, 1, 4 , 1 FROM dual UNION ALL
SELECT 5, 2, 5 , 1 FROM dual UNION ALL
SELECT 6, 2, 6 , 1 FROM dual UNION ALL
SELECT 7, 3, 7 , 1 FROM dual UNION ALL
SELECT 8, 3, 8 , 0 FROM dual UNION ALL
SELECT 9, 4, 9 , 1 FROM dual UNION ALL
SELECT 10, 4, 10 , 1 FROM dual UNION ALL
SELECT 11, 5, 11 , 0 FROM dual UNION ALL
SELECT 12, 5, 12 , 1 FROM dual UNION ALL
SELECT 13, 5, 13 , 1 FROM dual UNION ALL
SELECT 14, 6, 14 , 1 FROM dual UNION ALL
SELECT 15, 6, 15 , 1 FROM dual UNION ALL
SELECT 16, 7, 16 , 1 FROM dual UNION ALL
SELECT 17, 7, 17 , 1 FROM dual UNION ALL
SELECT 18, 7, 18 , 1 FROM dual UNION ALL
SELECT 19, 7, 19 , 1 FROM dual;


INSERT INTO ingredient
(id, name, vendorId, quantity, unit)
SELECT 1, 'pastrama de porc', 3, 500, 'g' FROM dual UNION ALL
SELECT 2, 'slanina', 3, 500, 'g' FROM dual UNION ALL
SELECT 3, 'salam uscat', 3, 500, 'g' FROM dual UNION ALL
SELECT 4, 'branza', 3, 1000, 'g' FROM dual UNION ALL
SELECT 5, 'cascaval', 3, 1500, 'g' FROM dual UNION ALL
SELECT 6, 'oua', 1, 20, 'buc' FROM dual UNION ALL
SELECT 7, 'pesmet', 1, 500, 'g' FROM dual UNION ALL
SELECT 8, 'icre', 2, 200, 'g' FROM dual UNION ALL
SELECT 9, 'vinete', 4, 1400, 'g' FROM dual UNION ALL
SELECT 10, 'ceapa', 4, 2000, 'g' FROM dual UNION ALL
SELECT 11, 'paste', 1, 2000, 'g' FROM dual UNION ALL
SELECT 12, 'malai', 1, 4000, 'g' FROM dual UNION ALL
SELECT 13, 'smantana', 3, 2000, 'g' FROM dual UNION ALL
SELECT 14, 'salata', 4, 1500, 'g' FROM dual UNION ALL
SELECT 15, 'piept de pui', 1, 3000, 'g' FROM dual UNION ALL
SELECT 16, 'paine', 1, 3000, 'g' FROM dual UNION ALL
SELECT 17, 'parmezan', 1, 1000, 'g' FROM dual UNION ALL
SELECT 18, 'rosii', 4, 3000, 'g' FROM dual UNION ALL
SELECT 19, 'ton', 2, 1000, 'g' FROM dual UNION ALL
SELECT 20, 'porumb', 4, 5000, 'g' FROM dual UNION ALL
SELECT 21, 'hribi', 3, 500, 'g' FROM dual UNION ALL
SELECT 22, 'vita', 1, 3000, 'g' FROM dual UNION ALL
SELECT 23, 'orez', 1, 3000, 'g' FROM dual;

INSERT INTO recipe
(id, itemId, ingredientid, quantity, unit)
SELECT 1, 1, 1, 100, 'g' FROM dual UNION ALL
SELECT 2, 1, 2, 100, 'g' FROM dual UNION ALL
SELECT 3, 1, 3, 100, 'g' FROM dual UNION ALL
SELECT 4, 1, 4, 100, 'g' FROM dual UNION ALL
SELECT 5, 2, 5, 200, 'g' FROM dual UNION ALL
SELECT 6, 2, 6, 2, 'buc' FROM dual UNION ALL
SELECT 7, 2, 7, 50, 'g' FROM dual UNION ALL
SELECT 8, 3, 8, 50, 'g' FROM dual UNION ALL
SELECT 9, 3, 10, 5, 'g' FROM dual UNION ALL
SELECT 10, 4, 9, 50, 'g' FROM dual UNION ALL
SELECT 11, 4, 10, 5, 'g' FROM dual UNION ALL
SELECT 12, 5, 11, 200, 'g' FROM dual UNION ALL
SELECT 13, 5, 4, 50, 'g' FROM dual UNION ALL
SELECT 14, 6, 4, 100, 'g' FROM dual UNION ALL
SELECT 15, 6, 12, 50, 'g' FROM dual UNION ALL
SELECT 16, 6, 13, 50, 'g' FROM dual UNION ALL
SELECT 17, 7, 14, 50, 'g' FROM dual UNION ALL
SELECT 18, 7, 16, 20, 'g' FROM dual UNION ALL
SELECT 19, 7, 15, 50, 'g' FROM dual UNION ALL
SELECT 20, 7, 17, 10, 'g' FROM dual UNION ALL
SELECT 21, 7, 18, 20, 'g' FROM dual UNION ALL
SELECT 22, 8, 19, 50, 'g' FROM dual UNION ALL
SELECT 23, 8, 14, 50, 'g' FROM dual UNION ALL
SELECT 24, 8, 18, 20, 'g' FROM dual UNION ALL
SELECT 25, 8, 20, 20, 'g' FROM dual UNION ALL
SELECT 26, 8, 10, 10, 'g' FROM dual UNION ALL
SELECT 27, 9, 21, 50, 'g' FROM dual UNION ALL
SELECT 28, 9, 10, 10, 'g' FROM dual UNION ALL
SELECT 29, 9, 13, 50, 'g' FROM dual UNION ALL
SELECT 30, 10, 15, 100, 'g' FROM dual UNION ALL
SELECT 31, 10, 13, 50, 'g' FROM dual UNION ALL
SELECT 32, 11, 22, 50, 'g' FROM dual UNION ALL
SELECT 33, 11, 23, 50, 'g' FROM dual UNION ALL
SELECT 34, 11, 10, 10, 'g' FROM dual UNION ALL
SELECT 35, 11, 13, 10, 'g' FROM dual UNION ALL
SELECT 36, 11, 12, 50, 'g' FROM dual UNION ALL
SELECT 37, 12, 22, 200, 'g' FROM dual UNION ALL
SELECT 38, 13, 15, 250, 'g' FROM dual UNION ALL
SELECT 39, 14, 23, 250, 'g' FROM dual UNION ALL
SELECT 40, 15, 9, 50, 'g' FROM dual UNION ALL
SELECT 41, 15, 10, 50, 'g' FROM dual UNION ALL
SELECT 42, 15, 18, 50, 'g' FROM dual;

INSERT INTO customer
(id, firstName, lastName, email, address, cityId, phone)
SELECT 5, 'Oana', 'Matei', 'oana@yahoo.com', 'Str. Valea Lunga nr 2', 1 , '0725380732' FROM dual UNION ALL
SELECT 6, 'Andrei', 'Ciuca', 'andreic@yahoo.com', 'str. Furnalistilor nr 4', 3 , '0707974331' FROM dual UNION ALL
SELECT 7, 'Marius', 'Popescu', 'marius@gamil.com', 'str. Oltului nr 5', 4 , '071-2375-637' FROM dual UNION ALL
SELECT 8, 'Andrees', 'Istrate', 'andrees@yahoo.com', 'str.Popesti nr 4', 6 , '0757080522' FROM dual UNION ALL
SELECT 9, 'Alexandra', 'Saracu', 'alex@gmail.com', 'str. Iudeilor nr 2', 7 , '070 457 6899' FROM dual;

INSERT INTO bill
(id, status, subtotal, shipping, total, createdAt)
SELECT 1, 'Paid', 92, 0, 92, TO_DATE('2020/05/03 21:40:44', 'yyyy/mm/dd hh24:mi:ss') FROM dual UNION ALL
SELECT 2, 'Paid', 80, 0, 80, TO_DATE('2020/06/03 12:45:00', 'yyyy/mm/dd hh24:mi:ss') FROM dual UNION ALL
SELECT 3, 'Complete', 45, 0, 45, TO_DATE('2020/06/03 14:02:44', 'yyyy/mm/dd hh24:mi:ss') FROM dual UNION ALL
SELECT 4, 'Complete', 12, 0, 12, TO_DATE('2020/07/03 20:30:20', 'yyyy/mm/dd hh24:mi:ss') FROM dual UNION ALL
SELECT 5, 'Complete', 234, 0, 234, TO_DATE('2020/07/03 20:02:45', 'yyyy/mm/dd hh24:mi:ss') FROM dual UNION ALL
SELECT 6, 'Complete', 43, 14, 57, TO_DATE('2020/10/11 12:02:34', 'yyyy/mm/dd hh24:mi:ss') FROM dual UNION ALL
SELECT 7, 'New', 310, 12, 322, TO_DATE('2020/10/11 14:04:44', 'yyyy/mm/dd hh24:mi:ss') FROM dual UNION ALL
SELECT 8, 'Shipped', 89, 14, 103, TO_DATE('2020/10/11 17:05:22', 'yyyy/mm/dd hh24:mi:ss') FROM dual UNION ALL
SELECT 9, 'Shipped', 20, 14, 34, TO_DATE('2020/10/11 18:06:44', 'yyyy/mm/dd hh24:mi:ss') FROM dual;

INSERT INTO order_item
(id, orderID, itemId, quantity)
SELECT 1, 1, 1, 1  FROM dual UNION ALL
SELECT 2, 1, 2, 1  FROM dual UNION ALL
SELECT 3, 1, 17, 1  FROM dual UNION ALL
SELECT 4, 2, 14, 2  FROM dual UNION ALL
SELECT 5, 2, 15, 2  FROM dual UNION ALL
SELECT 6, 2, 12, 2  FROM dual UNION ALL
SELECT 7, 3, 3, 3  FROM dual UNION ALL
SELECT 8, 4, 4, 4  FROM dual UNION ALL
SELECT 9, 4, 5, 4  FROM dual UNION ALL
SELECT 10, 4, 6, 4  FROM dual UNION ALL
SELECT 11, 5, 7, 5  FROM dual UNION ALL
SELECT 12, 6, 8, 6  FROM dual UNION ALL
SELECT 13, 6, 9, 6  FROM dual UNION ALL
SELECT 14, 5, 10, 5  FROM dual UNION ALL
SELECT 15, 7, 10, 7  FROM dual UNION ALL
SELECT 16, 8, 11, 8  FROM dual UNION ALL
SELECT 17, 9, 1, 9  FROM dual UNION ALL
SELECT 18, 7, 14, 7  FROM dual UNION ALL
SELECT 19, 7, 12, 7  FROM dual;

INSERT INTO delivery_track
(id, estimatedTime, customerId, billId)
SELECT 1, TO_DATE('2020/10/11 13:02:44', 'yyyy/mm/dd hh24:mi:ss'), 5, 6  FROM dual UNION ALL
SELECT 2, TO_DATE('2020/10/11 15:02:44', 'yyyy/mm/dd hh24:mi:ss'), 6, 7  FROM dual UNION ALL
SELECT 3, TO_DATE('2020/10/11 18:02:44', 'yyyy/mm/dd hh24:mi:ss'), 7, 8  FROM dual UNION ALL
SELECT 4, TO_DATE('2020/10/11 19:02:44', 'yyyy/mm/dd hh24:mi:ss'), 5, 9  FROM dual;


