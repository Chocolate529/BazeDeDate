--  PalletTrucks
INSERT INTO "PalletTrucks" VALUES
                               (1, 'SN1001', 'Manual', 'Model A1', 2500, 'Available'),
                               (2, 'SN1002', 'Electric', 'Model E2', 3000, 'Available'),
                               (3, 'SN1003', 'Manual', 'Model M3', 2000, 'Rented'),
                               (4, 'SN1004', 'Electric', 'Model E4', 4000, 'In Maintenance'),
                               (5, 'SN1005', 'Manual', 'Model M5', 1500, 'Available'),
                               (6, 'SN1006', 'Electric', 'Model E6', 3200, 'Retired'),
                               (7, 'SN1007', 'Manual', 'Model M7', 2800, 'Available'),
                               (8, 'SN1008', 'Electric', 'Model E8', 3500, 'Available'),
                               (9, 'SN1009', 'Manual', 'Model M9', 2500, 'Rented'),
                               (10, 'SN1010', 'Electric', 'Model E10', 3700, 'Available'),
                               (11, 'SN1011', 'Manual', 'Model M11', 2600, 'Available'),
                               (12, 'SN1012', 'Electric', 'Model E12', 3400, 'Available'),
                               (13, 'SN1013', 'Manual', 'Model M13', 2100, 'Available'),
                               (14, 'SN1014', 'Electric', 'Model E14', 3300, 'Rented'),
                               (15, 'SN1015', 'Manual', 'Model M15', 1800, 'Available');

--  PalletTruckDetails
INSERT INTO "PalletTruckDetails" VALUES
                                     (1, 1, '2022-03-12', 'Initial purchase', 'Toyota'),
                                     (2, 2, '2023-02-10', 'With upgraded control', 'Linde'),
                                     (3, 3, '2021-12-01', 'Heavy-duty model', 'Crown'),
                                     (4, 4, '2022-07-15', 'Used in warehouse A', 'Yale'),
                                     (5, 5, '2023-04-22', 'Compact design', 'Nissan'),
                                     (6, 6, '2022-01-10', 'Prototype model', 'Hyster'),
                                     (7, 7, '2022-05-09', 'Excellent performance', 'Toyota'),
                                     (8, 8, '2023-03-18', 'Battery replaced', 'Crown'),
                                     (9, 9, '2022-06-11', 'Stable on slopes', 'Linde'),
                                     (10, 10, '2023-01-19', 'Hydraulics upgraded', 'Yale'),
                                     (11, 11, '2022-04-05', 'Used for small pallets', 'Toyota'),
                                     (12, 12, '2023-02-24', 'Fast charging', 'Nissan'),
                                     (13, 13, '2022-08-02', 'Serviced in 2023', 'Crown'),
                                     (14, 14, '2023-06-10', 'High capacity battery', 'Linde'),
                                     (15, 15, '2022-09-12', 'Regular use', 'Toyota');

--  WheelMaterials
INSERT INTO "WheelMaterials" VALUES
                                 (1, 'Rubber', 1000),
                                 (2, 'Polyurethane', 1200),
                                 (3, 'Steel', 2000),
                                 (4, 'Nylon', 800),
                                 (5, 'Aluminum', 1500),
                                 (6, 'Cast Iron', 2200),
                                 (7, 'Composite', 1800),
                                 (8, 'Rubber', 900),
                                 (9, 'Polyurethane', 1300),
                                 (10, 'Steel', 2500),
                                 (11, 'Nylon', 700),
                                 (12, 'Aluminum', 1400),
                                 (13, 'Composite', 1600),
                                 (14, 'Cast Iron', 2100),
                                 (15, 'Rubber', 1100);

--  Bearings
INSERT INTO "Bearings" VALUES
                           (1, 25, NULL),
                           (2, 30, NULL),
                           (3, 28, NULL),
                           (4, 35, NULL),
                           (5, 32, NULL),
                           (6, 29, NULL),
                           (7, 27, NULL),
                           (8, 26, NULL),
                           (9, 33, NULL),
                           (10, 31, NULL),
                           (11, 24, NULL),
                           (12, 36, NULL),
                           (13, 29, NULL),
                           (14, 34, NULL),
                           (15, 25, NULL);

--  Wheels
INSERT INTO "Wheels" VALUES
                         (1, 1, 1000, 1, 1),
                         (2, 2, 1200, 2, 2),
                         (3, 3, 2000, 3, 3),
                         (4, 4, 800, 4, 4),
                         (5, 5, 1500, 5, 5),
                         (6, 6, 2200, 6, 6),
                         (7, 7, 1800, 7, 7),
                         (8, 8, 900, 8, 8),
                         (9, 9, 1300, 9, 9),
                         (10, 10, 2500, 10, 10),
                         (11, 11, 700, 11, 11),
                         (12, 12, 1400, 12, 12),
                         (13, 13, 1600, 13, 13),
                         (14, 14, 2100, 14, 14),
                         (15, 15, 1100, 15, 15);

--  Customers
INSERT INTO "Customers" VALUES
                            (1, 'LogiTrans', 'Andrei Pop', '0711111111', 'andrei@logitrans.com', 'Bucharest'),
                            (2, 'LiftCorp', 'Maria Ionescu', '0722222222', 'maria@liftcorp.com', 'Cluj'),
                            (3, 'WareHousePro', 'Ion Stan', '0733333333', 'ion@warehousepro.com', 'Timisoara'),
                            (4, 'TransMove', 'George Radu', '0744444444', 'george@transmove.com', 'Iasi'),
                            (5, 'Loaders SRL', 'Diana Ene', '0755555555', 'diana@loaders.com', 'Brasov'),
                            (6, 'Pick&Carry', 'Alex Tudor', '0766666666', 'alex@pickcarry.com', 'Constanta'),
                            (7, 'FastLift', 'Roxana Dinu', '0777777777', 'roxana@fastlift.com', 'Sibiu'),
                            (8, 'ProLift', 'Cristi Ilie', '0788888888', 'cristi@prolift.com', 'Oradea'),
                            (9, 'QuickTrans', 'Oana Marinescu', '0799999999', 'oana@quicktrans.com', 'Galati'),
                            (10, 'CargoFlex', 'Mihai Pavel', '0700000000', 'mihai@cargoflex.com', 'Pitesti'),
                            (11, 'HeavyWorks', 'Laura Bota', '0712345678', 'laura@heavyworks.com', 'Craiova'),
                            (12, 'EcoLift', 'Razvan Ursu', '0723456789', 'razvan@ecolift.com', 'Suceava'),
                            (13, 'LiftUp', 'Paula Dragomir', '0734567890', 'paula@liftup.com', 'Ploiesti'),
                            (14, 'TeraLog', 'Radu Popescu', '0745678901', 'radu@teralog.com', 'Bacau'),
                            (15, 'SmartTrans', 'Irina Olteanu', '0756789012', 'irina@smarttrans.com', 'Arad');

--  Rentals
INSERT INTO "Rentals" VALUES
                          (1, 1, 1, '2023-01-10', '2023-01-20', 120.00, 1200.00, 'Returned'),
                          (2, 2, 2, '2023-02-01', '2023-02-10', 150.00, 1350.00, 'Returned'),
                          (3, 3, 3, '2023-03-05', '2023-03-15', 100.00, 1000.00, 'Returned'),
                          (4, 4, 4, '2023-04-01', NULL, 200.00, NULL, 'Active'),
                          (5, 5, 5, '2023-05-01', '2023-05-08', 90.00, 630.00, 'Returned'),
                          (6, 6, 6, '2023-06-01', NULL, 160.00, NULL, 'Active'),
                          (7, 7, 7, '2023-07-15', '2023-07-25', 110.00, 1100.00, 'Returned'),
                          (8, 8, 8, '2023-08-10', '2023-08-20', 95.00, 950.00, 'Returned'),
                          (9, 9, 9, '2023-09-01', NULL, 175.00, NULL, 'Active'),
                          (10, 10, 10, '2023-10-05', '2023-10-15', 125.00, 1250.00, 'Returned'),
                          (11, 11, 11, '2023-11-01', '2023-11-10', 130.00, 1170.00, 'Returned'),
                          (12, 12, 12, '2023-11-20', NULL, 145.00, NULL, 'Active'),
                          (13, 13, 13, '2023-12-01', '2023-12-05', 100.00, 500.00, 'Returned'),
                          (14, 14, 14, '2024-01-02', NULL, 180.00, NULL, 'Active'),
                          (15, 15, 15, '2024-01-10', NULL, 160.00, NULL, 'Active');

--  Invoices
INSERT INTO "Invoices" VALUES
                           (1, 1, '2023-01-21', 'Paid'),
                           (2, 2, '2023-02-11', 'Paid'),
                           (3, 3, '2023-03-16', 'Paid'),
                           (4, 4, '2023-04-12', 'Pending'),
                           (5, 5, '2023-05-09', 'Paid'),
                           (6, 6, '2023-06-05', 'Pending'),
                           (7, 7, '2023-07-26', 'Paid'),
                           (8, 8, '2023-08-21', 'Paid'),
                           (9, 9, '2023-09-05', 'Pending'),
                           (10, 10, '2023-10-16', 'Paid'),
                           (11, 11, '2023-11-11', 'Paid'),
                           (12, 12, '2023-11-25', 'Pending'),
                           (13, 13, '2023-12-06', 'Paid'),
                           (14, 14, '2024-01-05', 'Pending'),
                           (15, 15, '2024-01-11', 'Pending');

-- Employees
INSERT INTO "Employees" VALUES
                            (1, 'Andrei', 'Popescu', 'Technician', '2020-01-10', '0711111111', 'andrei@company.com'),
                            (2, 'Maria', 'Ionescu', 'Driver', '2021-03-12', '0722222222', 'maria@company.com'),
                            (3, 'George', 'Stan', 'Sales', '2019-07-15', '0733333333', 'george@company.com'),
                            (4, 'Ioana', 'Radu', 'Manager', '2018-09-20', '0744444444', 'ioana@company.com'),
                            (5, 'Alexandru', 'Tudor', 'Admin', '2022-02-05', '0755555555', 'alexandru@company.com'),
                            (6, 'Roxana', 'Ene', 'Technician', '2020-11-11', '0766666666', 'roxana@company.com'),
                            (7, 'Paul', 'Ilie', 'Driver', '2021-08-18', '0777777777', 'paul@company.com'),
                            (8, 'Cristian', 'Marin', 'Sales', '2019-05-23', '0788888888', 'cristian@company.com'),
                            (9, 'Diana', 'Pop', 'Manager', '2018-01-30', '0799999999', 'diana@company.com'),
                            (10, 'Mihai', 'Dobre', 'Admin', '2022-03-17', '0700000000', 'mihai@company.com'),
                            (11, 'Laura', 'Badea', 'Technician', '2020-06-19', '0712345678', 'laura@company.com'),
                            (12, 'Razvan', 'Ursu', 'Driver', '2021-02-25', '0723456789', 'razvan@company.com'),
                            (13, 'Paula', 'Dragan', 'Sales', '2019-10-05', '0734567890', 'paula@company.com'),
                            (14, 'Radu', 'Popa', 'Manager', '2018-12-09', '0745678901', 'radu@company.com'),
                            (15, 'Irina', 'Olteanu', 'Admin', '2022-04-15', '0756789012', 'irina@company.com');

-- MaintenanceRecords
INSERT INTO "MaintenanceRecords" VALUES
                                     (1, 1, '2023-01-15', 'Oil change', 100.00, 1),
                                     (2, 2, '2023-02-20', 'Battery replacement', 350.00, 6),
                                     (3, 3, '2023-03-22', 'Brake inspection', 200.00, 11),
                                     (4, 4, '2023-04-25', 'Hydraulic fix', 500.00, 1),
                                     (5, 5, '2023-05-12', 'Wheel alignment', 150.00, 6),
                                     (6, 6, '2023-06-18', 'Motor repair', 600.00, 1),
                                     (7, 7, '2023-07-21', 'Hydraulic seal change', 180.00, 11),
                                     (8, 8, '2023-08-09', 'Software update', 250.00, 1),
                                     (9, 9, '2023-09-14', 'Sensor calibration', 300.00, 11),
                                     (10, 10, '2023-10-05', 'Battery service', 400.00, 6),
                                     (11, 11, '2023-10-30', 'Fork adjustment', 120.00, 1),
                                     (12, 12, '2023-11-12', 'Tire replacement', 220.00, 6),
                                     (13, 13, '2023-12-01', 'Brake pads change', 180.00, 1),
                                     (14, 14, '2024-01-08', 'Lubrication', 90.00, 11),
                                     (15, 15, '2024-01-20', 'Full inspection', 600.00, 6);

-- Suppliers
INSERT INTO "Suppliers" VALUES
                            (1, 'PartsCo', 'John Smith', '0711111111', 'john@partsco.com', 'Bucharest'),
                            (2, 'WheelWorks', 'Emily Davis', '0722222222', 'emily@wheelworks.com', 'Cluj'),
                            (3, 'LiftTech', 'Robert Brown', '0733333333', 'robert@lifttech.com', 'Timisoara'),
                            (4, 'BearMaster', 'Laura Green', '0744444444', 'laura@bearmaster.com', 'Iasi'),
                            (5, 'SteelMax', 'Michael White', '0755555555', 'michael@steelmax.com', 'Brasov'),
                            (6, 'PolyParts', 'Anna Black', '0766666666', 'anna@polyparts.com', 'Constanta'),
                            (7, 'TransSupplies', 'Chris Grey', '0777777777', 'chris@transsupplies.com', 'Sibiu'),
                            (8, 'FastParts', 'Olivia Stone', '0788888888', 'olivia@fastparts.com', 'Oradea'),
                            (9, 'MegaLift', 'James Taylor', '0799999999', 'james@megalift.com', 'Galati'),
                            (10, 'BearingPro', 'Linda Evans', '0700000000', 'linda@bearingpro.com', 'Pitesti'),
                            (11, 'AllParts', 'Daniel King', '0712345678', 'daniel@allparts.com', 'Craiova'),
                            (12, 'EcoSupply', 'Sophie Wilson', '0723456789', 'sophie@ecosupply.com', 'Suceava'),
                            (13, 'TechLift', 'Victor Lewis', '0734567890', 'victor@techlift.com', 'Ploiesti'),
                            (14, 'SteelParts', 'Julia Young', '0745678901', 'julia@steelparts.com', 'Bacau'),
                            (15, 'HeavySupply', 'Emma Adams', '0756789012', 'emma@heavysupply.com', 'Arad');

--PartsInventory
INSERT INTO "PartsInventory" VALUES
                                 (1, 'Bearing Type A', 1, 100, 15.50),
                                 (2, 'Bearing Type B', 2, 50, 18.00),
                                 (3, 'Rubber Wheel', 3, 80, 25.00),
                                 (4, 'Polyurethane Wheel', 4, 60, 30.00),
                                 (5, 'Steel Frame', 5, 40, 75.00),
                                 (6, 'Hydraulic Pump', 6, 20, 120.00),
                                 (7, 'Motor Unit', 7, 15, 250.00),
                                 (8, 'Battery Pack', 8, 25, 200.00),
                                 (9, 'Fork Assembly', 9, 10, 300.00),
                                 (10, 'Brake Kit', 10, 50, 90.00),
                                 (11, 'Control Panel', 11, 30, 150.00),
                                 (12, 'Sensor Unit', 12, 40, 110.00),
                                 (13, 'Hydraulic Seal', 13, 60, 40.00),
                                 (14, 'Lubricant', 14, 200, 10.00),
                                 (15, 'Wiring Harness', 15, 35, 80.00);

-- MaintenanceParts
INSERT INTO "MaintenanceParts" VALUES
                                   (1, 1, 2),
                                   (2, 2, 1),
                                   (3, 3, 2),
                                   (4, 4, 1),
                                   (5, 5, 4),
                                   (6, 6, 2),
                                   (7, 7, 3),
                                   (8, 8, 2),
                                   (9, 9, 1),
                                   (10, 10, 2),
                                   (11, 11, 3),
                                   (12, 12, 2),
                                   (13, 13, 4),
                                   (14, 14, 5),
                                   (15, 15, 3);