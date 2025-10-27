SELECT * FROM Bearings
SELECT * FROM Customers
SELECT * FROM Employees
SELECT * FROM Invoices
SELECT * FROM MaintenanceParts
SELECT * FROM MaintenanceRecords
SELECT * FROM PalletTrucks
SELECT * FROM PalletTruckDetails
SELECT * FROM PartsInventory
SELECT * FROM Rentals
SELECT * FROM Suppliers
SELECT * FROM WheelMaterials
SELECT * FROM Wheels

-- 2 interogari pe tabele aflate in relatie m-n + GROUP BY(1) si HAVING(1) si WHERE(1)

---1 Afisare pentru fiecare mentenanta - pisele folosite, cantitatea si costul total(cantitate *  cost unita)
SELECT MP.record_id, MP.part_id, MP.quantity_used, PI.name, PI.unit_cost, MR.service_date, MR.description, (MP.quantity_used * PI.unit_cost) as total_cost
FROM MaintenanceParts MP
    Inner JOIN dbo.PartsInventory PI on MP.part_id = PI.part_id
    INNER JOIN dbo.MaintenanceRecords MR on MR.record_id = MP.record_id
WHERE MR.service_date > '2023-06-01'
ORDER BY total_cost

-- afisare toate
SELECT *
FROM MaintenanceParts MP
         Inner JOIN dbo.PartsInventory PI on MP.part_id = PI.part_id
         INNER JOIN dbo.MaintenanceRecords MR on MR.record_id = MP.record_id

--2 afisare toti transpaletii care au fost in service intr o anumita perioada si cat au costat reparatiile + GORUP BY(2) + HAVING(2) + WHERE(2)
SELECT  MR.truck_id, SUM(MP.quantity_used * PI.unit_cost) as total_parts_cost
FROM MaintenanceParts MP
         Inner JOIN dbo.PartsInventory PI on MP.part_id = PI.part_id
         INNER JOIN dbo.MaintenanceRecords MR on MR.record_id = MP.record_id
WHERE MR.service_date BETWEEN '2023-06-01' and '2023-10-01'
GROUP BY MR.truck_id
HAVING SUM(MP.quantity_used * PI.unit_cost) > 500.00
ORDER BY total_parts_cost

--7 interogari ce extrag informatii din mai mult de 2 tabele

---(3) 1 afiseaza valoare medie platita de fiecare client care a finalizat inchirierea - GROUP BY(3) si HAVING(3) + WHERE(3)
SELECT RN.customer_id, AVG(RN.total_cost) as avg_cost
FROM RENTALS RN
    INNER JOIN dbo.Invoices I on RN.rental_id = I.rental_id
    INNER JOIN dbo.Customers C on RN.customer_id = C.customer_id
WHERE  status = 'Paid' and total_cost is not null and end_date is not null
GROUP BY RN.customer_id
HAVING AVG(RN.total_cost) > 1000.00
ORDER BY avg_cost

---(4) 2 afiseaza valoare totala de platit de fiecare client care are o inchiriere curenta pana in momentul curent - GROUP BY(4) + WHERE(4)
SELECT RN.customer_id, C.company_name, SUM(DATEDIFF(DAY, RN.start_date, GETDATE()) * RN.daily_rate) AS total_to_pay
FROM Rentals RN
         INNER JOIN Customers C ON RN.customer_id = C.customer_id
WHERE RN.return_status = 'Active'
GROUP BY RN.customer_id, C.company_name
HAVING SUM(DATEDIFF(DAY, RN.start_date, GETDATE()) * RN.daily_rate) BETWEEN 100000.00 and 150000.00


---(5) 3 afiseaza costul de mentenanta folosit de un transpalet manual cu o capacitate mai mare de 2000 prin inchirieri + WHERE(5)
SELECT PT.truck_id, PT.model, MR.cost + MP.quantity_used*PI.unit_cost as total_cost
FROM PalletTrucks PT
    INNER JOIN dbo.MaintenanceRecords MR ON PT.truck_id = MR.truck_id
    INNER JOIN dbo.MaintenanceParts MP ON Mr.record_id = MP.record_id
    INNER JOIN dbo.PartsInventory PI on PI.part_id = MP.part_id
WHERE  PT.capacity_kg > 2000 and PT.type = 'Manual'
ORDER BY total_cost

---(6) 4 afiseaza ce diametru de rulment foloseste fiecare transpaleti
SELECT  PT.truck_id, B.diametre, PT.capacity_kg
FROM PalletTrucks PT
    INNER JOIN dbo.Wheels W on PT.truck_id = W.truck_id
    INNER JOIN dbo.Bearings B on B.bid = W.bid

---(7) 5 afiseaza toti transpaletii inchiriati de un client + DISTINCT(1)
SELECT DISTINCT PT.truck_id, C.company_name
FROM PalletTrucks PT
    INNER JOIN dbo.Rentals R on R.truck_id = PT.truck_id
    INNER JOIN dbo.Customers C on C.customer_id = R.customer_id

---(8) 6 afiseaza toate repariitile facute de fiecare tehnician pe un transpalet anume
SELECT E.employee_id, MR.service_date, MR.description, PT.serial_number
FROM Employees E
    INNER JOIN dbo.MaintenanceRecords MR on E.employee_id = MR.technician_id
    INNER JOIN dbo.PalletTrucks PT on MR.truck_id = PT.truck_id

---(9) 7 afiseaza numarul de parti (si pretul total) care trebuie comandate de al fiecare supllier pentru refacere stock
SELECT MP.part_id, PI.name, S.supplier_id, S.name, MP.quantity_used, MP.quantity_used*PI.unit_cost as total_cost
FROM MaintenanceParts MP
    INNER JOIN dbo.PartsInventory PI on MP.part_id = PI.part_id
    INNER JOIN dbo.Suppliers S on S.supplier_id = PI.supplier_id


---(10) 8 afiseaza supplieri care au furnizat parti pentru repartii la un anumit transpalet
SELECT DISTINCT S.supplier_id, PT.truck_id, S.name
FROM Suppliers S
    INNER JOIN dbo.PartsInventory PI on S.supplier_id = PI.supplier_id
    INNER JOIN dbo.MaintenanceParts MP on PI.part_id = MP.part_id
    INNER JOIN dbo.MaintenanceRecords MR on MR.record_id = MP.record_id
    INNER JOIN dbo.PalletTrucks PT on MR.truck_id = PT.truck_id

