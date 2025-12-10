
-- View 1: Costul Mentenantei cu Detalii despre Piese
-- Afișează defalcarea costurilor pe inregistrare de mentenanta cu informatii despre piese
CREATE OR ALTER VIEW dbo. Vw_MaintenanceCostWithPartQuantity
AS
SELECT
    MP.record_id,
    MR.truck_id,
    MR.service_date,
    PI.part_id,
    PI.name AS part_name,
    MP.quantity_used,
    PI.unit_cost,
    (MP.quantity_used * PI.unit_cost) AS line_total_cost
FROM dbo.MaintenanceParts MP
         INNER JOIN dbo.PartsInventory PI ON MP.part_id = PI. part_id
         INNER JOIN dbo.MaintenanceRecords MR ON MR.record_id = MP.record_id;
GO


-- View 2: Sumar Utilizare Piese de Mentenanță
-- Agregeaza costul total al pieselor pe fiecare
CREATE OR ALTER VIEW dbo.Vw_MaintenancePartsUsageSummary
AS
SELECT
    MR.truck_id,
    MR.service_date,
    MR. record_id,
    SUM(MP.quantity_used) AS total_parts_used,
    SUM(MP.quantity_used * PI.unit_cost) AS total_parts_cost
FROM dbo.MaintenanceParts MP
         INNER JOIN dbo.MaintenanceRecords MR ON MP.record_id = MR.record_id
         INNER JOIN dbo.PartsInventory PI ON MP.part_id = PI. part_id
GROUP BY MR.truck_id, MR.service_date, MR.record_id;
GO


CREATE NONCLUSTERED INDEX IX_MaintenanceParts_RecordId
    ON dbo.MaintenanceParts (record_id ASC)
    INCLUDE (part_id, quantity_used);

CREATE NONCLUSTERED INDEX IX_MaintenanceParts_PartId
    ON dbo.MaintenanceParts (part_id ASC)
    INCLUDE (record_id, quantity_used);

CREATE NONCLUSTERED INDEX IX_MaintenanceRecords_RecordId_Covering
    ON dbo.MaintenanceRecords (record_id ASC)
    INCLUDE (truck_id, service_date);