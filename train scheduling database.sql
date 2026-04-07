CREATE DATABASE TFR_System;
GO

USE TFR_System;
GO

-- ============================================
-- 1. LOCOMOTIVE_CLASS Table
-- ============================================
CREATE TABLE Locomotive_Class (
    class_id CHAR(2) PRIMARY KEY,
    max_towing_weight INT NOT NULL CHECK (max_towing_weight > 0), -- in tonnes
    length_metres DECIMAL(5,1) NOT NULL CHECK (length_metres > 0)
);
GO

-- ============================================
-- 2. LOCOMOTIVE Table
-- ============================================
CREATE TABLE Locomotive (
    loco_id CHAR(5) PRIMARY KEY,
    class_id CHAR(2) NOT NULL,
    familiar_name VARCHAR(50) NULL,
    CONSTRAINT FK_Locomotive_Class FOREIGN KEY (class_id) 
        REFERENCES Locomotive_Class(class_id) ON DELETE CASCADE
);
GO

-- ============================================
-- 3. WAGON_TYPE Table
-- ============================================
CREATE TABLE Wagon_Type (
    type_id CHAR(2) PRIMARY KEY,
    description VARCHAR(200) NOT NULL,
    tare_weight INT NOT NULL CHECK (tare_weight > 0), -- in tonnes
    max_payload INT NOT NULL CHECK (max_payload > 0), -- in tonnes
    length DECIMAL(5,1) NOT NULL CHECK (length > 0)
);
GO

-- ============================================
-- 4. FREIGHT_WAGON Table
-- ============================================
CREATE TABLE Freight_Wagon (
    wagon_id CHAR(5) PRIMARY KEY,
    type_id CHAR(2) NOT NULL,
    CONSTRAINT FK_FreightWagon_Type FOREIGN KEY (type_id) 
        REFERENCES Wagon_Type(type_id) ON DELETE CASCADE
);
GO

-- ============================================
-- 5. STATION Table
-- ============================================
CREATE TABLE Station (
    station_id CHAR(3) PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL UNIQUE
);
GO

-- ============================================
-- 6. CUSTOMER Table
-- ============================================
CREATE TABLE Company (
    company_id INT IDENTITY(1,1) PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100) NULL,
    address VARCHAR(200) NULL,
    phone_number VARCHAR(20) NULL,
    email VARCHAR(100) NULL
);
GO

-- ============================================
-- 7. GOODS Table
-- ============================================
CREATE TABLE Goods(
    goods_id INT IDENTITY(1,1) PRIMARY KEY,
    description VARCHAR(500) NOT NULL ,
    unit_weight DECIMAL(5,2) NULL CHECK(unit_weight > 0)
    );
GO

-- ============================================
-- 8. CONSIGNMENT Table
-- ============================================
CREATE TABLE Consignment (
    consignment_id INT IDENTITY(1,1) PRIMARY KEY,
    goods_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
    collection_station CHAR(3) NOT NULL,
    delivery_station CHAR(3) NOT NULL,
    company_id INT NOT NULL,
    CONSTRAINT FK_Consignment_GoodsID FOREIGN KEY (goods_id) 
        REFERENCES Goods(goods_id),
    CONSTRAINT FK_Consignment_CollectionStation FOREIGN KEY (collection_station) 
        REFERENCES Station(station_id),
    CONSTRAINT FK_Consignment_DeliveryStation FOREIGN KEY (delivery_station) 
        REFERENCES Station(station_id),
    CONSTRAINT FK_Consignment_Customer FOREIGN KEY (company_id) 
        REFERENCES Company(company_id),
    CONSTRAINT CHK_DifferentStations CHECK (collection_station != delivery_station)
);
GO

-- ============================================
-- 9. ROUTE Table
-- ============================================
CREATE TABLE Route (
    route_id INT IDENTITY(1,1) PRIMARY KEY,
    total_distance INT NOT NULL CHECK (total_distance > 0) -- in miles
);
GO

-- ============================================
-- 10. STAGE Table
-- ============================================
CREATE TABLE Route_Stage (
    stage_id INT IDENTITY(1,1) PRIMARY KEY,
    route_id INT NOT NULL,
    start_station CHAR(3) NOT NULL,
    end_station CHAR(3) NOT NULL,
    distance INT NOT NULL CHECK (distance > 0),
    stage_order INT NOT NULL
    CONSTRAINT FK_Stage_Route FOREIGN KEY (route_id) 
        REFERENCES Route(route_id) ON DELETE CASCADE,
    CONSTRAINT FK_Stage_StartStation FOREIGN KEY (start_station) 
        REFERENCES Station(station_id),
    CONSTRAINT FK_Stage_EndStation FOREIGN KEY (end_station) 
        REFERENCES Station(station_id),
    CONSTRAINT CHK_StageDifferentStations CHECK (start_station != end_station)
);
GO

-- ============================================
-- 11. DRIVER Table
-- ============================================
CREATE TABLE Driver (
    driver_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    address VARCHAR(200) NULL,
    phone_number VARCHAR(20) NULL,
    email VARCHAR(100) NULL,
    start_date DATE NOT NULL,
    licence_number VARCHAR(20) UNIQUE NOT NULL
);
GO

-- ============================================
-- 12. DRIVER_QUALIFICATION Table
-- ============================================
CREATE TABLE Driver_Qualification (
    driver_id INT NOT NULL,
    class_id CHAR(2) NOT NULL,
    issue_date DATE NOT NULL,
    PRIMARY KEY (driver_id, class_id),
    CONSTRAINT FK_DriverQual_Driver FOREIGN KEY (driver_id) 
        REFERENCES Driver(driver_id) ON DELETE CASCADE,
    CONSTRAINT FK_DriverQual_LocoClass FOREIGN KEY (class_id) 
        REFERENCES Locomotive_Class(class_id)
);
GO

-- ============================================
-- 13. TRAIN Table
-- ============================================
CREATE TABLE Train (
    train_id INT IDENTITY(1,1) PRIMARY KEY,
    consignment_id INT NOT NULL,
    route_id INT NOT NULL,
    loco_id CHAR(5) NOT NULL,
    driver1_id INT NOT NULL,
    driver2_id INT NOT NULL,
    total_length DECIMAL(6,2) NOT NULL CHECK (total_length > 0),
    gross_weight DECIMAL(8,2) NOT NULL CHECK (gross_weight > 0),
    schedule_date DATE NULL
    CONSTRAINT FK_Train_Consignment FOREIGN KEY (consignment_id) 
        REFERENCES Consignment(consignment_id),
    CONSTRAINT FK_Train_Route FOREIGN KEY (route_id) 
        REFERENCES Route(route_id),
    CONSTRAINT FK_Train_Locomotive FOREIGN KEY (loco_id) 
        REFERENCES Locomotive(loco_id),
    CONSTRAINT FK_Train_Driver1 FOREIGN KEY (driver1_id) 
        REFERENCES Driver(driver_id),
    CONSTRAINT FK_Train_Driver2 FOREIGN KEY (driver2_id) 
        REFERENCES Driver(driver_id),
    CONSTRAINT CHK_DifferentDrivers CHECK (driver1_id != driver2_id),
    CONSTRAINT CHK_TrainLength CHECK (total_length <= 400) -- UK regulation
);
GO

-- ============================================
-- 14. TRAIN_WAGON Table (Junction)
-- ============================================
CREATE TABLE Train_Wagon (
    train_id INT NOT NULL,
    wagon_id CHAR(5) NOT NULL,
    PRIMARY KEY (train_id, wagon_id),
    CONSTRAINT FK_TrainWagon_Train FOREIGN KEY (train_id) 
        REFERENCES Train(train_id) ON DELETE CASCADE,
    CONSTRAINT FK_TrainWagon_Wagon FOREIGN KEY (wagon_id) 
        REFERENCES Freight_Wagon(wagon_id)
);
GO

-- ============================================
-- INDEXES for Performance
-- ============================================
CREATE INDEX IX_Consignment_Collection ON Consignment(collection_station);
CREATE INDEX IX_Consignment_Delivery ON Consignment(delivery_station);
CREATE INDEX IX_Consignment_Customer ON Consignment(company_id);
CREATE INDEX IX_Train_Consignment ON Train(consignment_id);
CREATE INDEX IX_Train_Route ON Train(route_id);
CREATE INDEX IX_Train_Driver1 ON Train(driver1_id);
CREATE INDEX IX_Train_Driver2 ON Train(driver2_id);
CREATE INDEX IX_Stage_Route ON Route_Stage(route_id);
CREATE INDEX IX_Stage_StartStation ON Route_Stage(start_station);
CREATE INDEX IX_Stage_EndStation ON Route_Stage(end_station);
CREATE INDEX IX_DriverQual_Driver ON Driver_Qualification(driver_id);
CREATE INDEX IX_DriverQual_Class ON Driver_Qualification(class_id);
GO

-- ============================================
-- VIEWS for Common Queries
-- ============================================

-- View: Train Details with Driver Names
CREATE VIEW vw_TrainDetails AS
SELECT 
    t.train_id,
    c.goods_id,
    c.quantity,
    l.loco_id AS locomotive_id,
    l.familiar_name AS locomotive_class,
    d1.full_name AS primary_driver,
    d2.full_name AS secondary_driver,
    r.total_distance AS route_miles,
    t.total_length,
    t.gross_weight
FROM Train t
JOIN Consignment c ON t.consignment_id = c.consignment_id
JOIN Locomotive l ON t.loco_id = l.loco_id
JOIN Locomotive_Class lc ON l.class_id = lc.class_id
JOIN Driver d1 ON t.driver1_id = d1.driver_id
JOIN Driver d2 ON t.driver2_id = d2.driver_id
JOIN Route r ON t.route_id = r.route_id;
GO

-- View: Available Locomotives
CREATE VIEW vw_AvailableLocomotives AS
SELECT l.loco_id, l.familiar_name, lc.max_towing_weight
FROM Locomotive l
JOIN Locomotive_Class lc ON l.class_id = lc.class_id
WHERE l.loco_id NOT IN (SELECT loco_id FROM Train);
GO

-- View: Available Wagons
CREATE VIEW vw_AvailableWagons AS
SELECT w.wagon_id, wt.description, wt.tare_weight, wt.max_payload
FROM Freight_Wagon w
JOIN Wagon_Type wt ON w.type_id = wt.type_id
WHERE w.wagon_id NOT IN (SELECT wagon_id FROM Train_Wagon);
GO

--View: Route Details
CREATE VIEW vw_RouteDetails AS
    SELECT 
        r.route_id,
        r.total_distance,
        s1.station_name AS start_station,
        s2.station_name AS end_station,
        rs.distance AS stage_distance,
        rs.stage_order
    FROM Route r
    JOIN Route_Stage rs ON r.route_id = rs.route_id
    JOIN Station s1 ON rs.start_station = s1.station_id
    JOIN Station s2 ON rs.end_station = s2.station_id;
GO

-- ============================================
-- STORED PROCEDURES
-- ============================================

-- Procedure: Calculate Required Trains for a Consignment
GO
CREATE PROCEDURE sp_CalculateRequiredTrains
    @consignment_id INT
AS
BEGIN
    DECLARE @total_weight DECIMAL(10,2);
    DECLARE @max_loco_weight INT;
    DECLARE @trains_needed INT;
    
    -- Get total consignment weight
    SELECT 
        @total_weight = 
        CASE 
            WHEN g.unit_weight IS NOT NULL THEN c.quantity * g.unit_weight
            ELSE c.quantity
        END
    FROM Consignment c
    LEFT JOIN Goods g ON c.goods_id = g.goods_id
    WHERE c.consignment_id = @consignment_id;
    
    -- Get maximum locomotive capacity
    SELECT @max_loco_weight = MAX(max_towing_weight) 
    FROM Locomotive_Class;
    
    -- Calculate trains needed
    SET @trains_needed = CEILING(@total_weight / @max_loco_weight);
    
    SELECT 
        @total_weight AS total_weight_tonnes,
        @max_loco_weight AS max_loco_capacity_tonnes,
        @trains_needed AS number_of_trains_required;
END;
GO

-- Procedure: Find Suitable Locomotives for a Consignment
GO
CREATE PROCEDURE sp_FindSuitableLocomotives
    @consignment_id INT
AS
BEGIN
    DECLARE @required_weight DECIMAL(10,2);
    
    -- Calculate required towing weight
    SELECT 
        @required_weight = 
        CASE 
            WHEN g.unit_weight IS NOT NULL THEN c.quantity * g.unit_weight
            ELSE c.quantity
        END
    FROM Consignment c
    LEFT JOIN Goods g ON c.goods_id = g.goods_id 
    WHERE c.consignment_id = @consignment_id;
    
    -- Find available locomotives that can handle the weight
    SELECT 
        l.loco_id,
        ISNULL(l.familiar_name, 'N/A') AS familiar_name,
        lc.max_towing_weight,
        lc.length_metres AS loco_length
    FROM Locomotive l
    JOIN Locomotive_Class lc ON l.class_id = lc.class_id
    WHERE lc.max_towing_weight >= @required_weight
        AND l.loco_id NOT IN (SELECT loco_id FROM Train)
    ORDER BY lc.max_towing_weight ASC;
END;
GO

-- Procedure: Get Route Details
GO
CREATE PROCEDURE sp_GetRouteDetails
    @route_id INT
AS
BEGIN
    SELECT 
        s.stage_id,
        start_station.station_name AS from_station,
        end_station.station_name AS to_station,
        s.distance,
        SUM(s.distance) OVER (ORDER BY s.stage_order) AS cumulative_distance,
        s.stage_order
    FROM Route_Stage s
    JOIN Station start_station ON s.start_station = start_station.station_id
    JOIN Station end_station ON s.end_station = end_station.station_id
    WHERE s.route_id = @route_id
    ORDER BY s.stage_order;
END;
GO

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger: Validate driver qualification before assigning to train
GO
CREATE TRIGGER trg_ValidateDriverQualification
ON Train
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if both drivers are qualified for the locomotive class
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Locomotive l ON i.loco_id = l.loco_id
        WHERE NOT EXISTS (
            SELECT 1 FROM Driver_Qualification dq
            WHERE dq.driver_id = i.driver1_id 
                AND dq.class_id = l.class_id
        )
        OR NOT EXISTS (
            SELECT 1 FROM Driver_Qualification dq
            WHERE dq.driver_id = i.driver2_id 
                AND dq.class_id = l.class_id
        )
    )
    BEGIN
        RAISERROR('Both drivers must be qualified for the locomotive class.', 16, 1);
        RETURN;
    END;
    
    -- Insert if validation passes
    INSERT INTO Train (
        consignment_id, route_id, loco_id, 
        driver1_id, driver2_id, total_length, gross_weight, schedule_date
    )
    SELECT 
        consignment_id, route_id, loco_id,
        driver1_id, driver2_id, total_length, gross_weight, 
        ISNULL(schedule_date, GETDATE())
    FROM inserted;
END;
GO

-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- Insert Station Data
INSERT INTO Station (station_id, station_name) VALUES
('PLY', 'Plymouth'),
('EXT', 'Exeter'),
('TAU', 'Taunton'),
('BRI', 'Bristol'),
('BIR', 'Birmingham'),
('RUG', 'Rugby'),
('SWA', 'Swansea'),
('EUS', 'Euston'),
('MAN', 'Manchester'),
('GLA', 'Glasgow'),
('YOR', 'York'),
('EDI', 'Edinburgh');
GO

-- Insert Locomotive Classes
INSERT INTO Locomotive_Class (class_id, max_towing_weight, length_metres) VALUES
('07', 1500, 16.4),
('08', 1600, 17.8),
('09', 2000, 21.4);
GO

-- Insert Locomotives
INSERT INTO Locomotive (loco_id, class_id, familiar_name) VALUES
('07100', '07', NULL),
('07101', '07', 'Red Arrow'),
('07102', '07', NULL),
('07103', '07', 'Tug'),
('07104', '07', NULL),
('08200', '08', NULL),
('08201', '08', 'Buckets'),
('08203', '08', NULL),
('08204', '08', NULL),
('09001', '09', 'Rapid Bullet'),
('09002', '09', NULL),
('09003', '09', NULL);
GO

-- Insert Wagon Types
INSERT INTO Wagon_Type (type_id, description, tare_weight, max_payload, length) VALUES
('90', 'Flat wagon - low-sided open wagon for cable drums and machinery', 21, 66, 14.6),
('91', 'Open wagon - high-sided open-box wagon for scrap steel', 33, 69, 16.2),
('92', 'Covered wagon - plastic sheeting covered for palletised goods', 23, 66, 20.6),
('93', 'Car carrier - covered wagon for cars and vans', 35, 15, 24.3),
('94', 'Tank wagon - stainless steel chemical tank', 27, 62, 18.9);
GO

-- Insert Freight Wagons
INSERT INTO Freight_Wagon (wagon_id, type_id) VALUES
('94005', '94'), ('94007', '94'), ('94102', '94'), ('94103', '94'), ('94104', '94'),
('94203', '94'), ('94204', '94'), ('94205', '94'), ('94206', '94'), ('94501', '94'),
('94502', '94'), ('94503', '94'), ('94506', '94'), ('94507', '94'), ('94508', '94'),
('94600', '94');
GO
INSERT INTO Freight_Wagon (wagon_id, type_id) VALUES
('94008', '94'),
('94009', '94'),
('94110', '94'),
('94111', '94');
GO
-- Insert Goods
INSERT INTO Goods (description, unit_weight) VALUES
('Cement', NULL),
('Cars', 1.2),
('Perishable Goods', 0.8),
('Mineral Oil', NULL);
GO

-- Insert Companies
INSERT INTO Company (company_name, contact_name, address, phone_number, email) VALUES
('Cement UK Ltd', 'John Smith', '123 Industrial Estate, London', '020 1234 5678', 'john@cementuk.co.uk'),
('Auto Transport Co', 'Sarah Jones', '456 Motorway, Birmingham', '0121 987 6543', 'sarah@autotransport.co.uk'),
('Fresh Foods Ltd', 'Mike Brown', '789 Food Park, Manchester', '0161 456 7890', 'mike@freshfoods.co.uk'),
('Petroleum Distributors', 'David Wilson', '321 Oil Refinery, Southampton', '023 8765 4321', 'david@petrodist.co.uk');
GO

-- Insert Consignments
INSERT INTO Consignment (goods_id, quantity, collection_station, delivery_station, company_id) VALUES
(1, 1000, 'PLY', 'BIR', 1),
(2, 200, 'RUG', 'SWA', 2),
(3, 500, 'BIR', 'EUS', 3),
(4, 1000, 'MAN', 'GLA', 4),
(1, 2000, 'YOR', 'EDI', 1);
GO

-- Insert Routes
INSERT INTO Route (total_distance) VALUES (209);  -- Plymouth to Birmingham
INSERT INTO Route (total_distance) VALUES (175);  -- Rugby to Swansea
INSERT INTO Route (total_distance) VALUES (112);  -- Birmingham to Euston
INSERT INTO Route (total_distance) VALUES (220);  -- Manchester to Glasgow
INSERT INTO Route (total_distance) VALUES (150);  -- York to Edinburgh
GO

-- Insert Stages for Route 1 (Plymouth to Birmingham)
INSERT INTO Route_Stage (route_id, start_station, end_station, distance, stage_order) VALUES
(1, 'PLY', 'EXT', 57, 1),
(1, 'EXT', 'TAU', 45, 2),
(1, 'TAU', 'BRI', 35, 3),
(1, 'BRI', 'BIR', 72, 4);
GO

-- Insert Stages for Route 2 (Rugby to Swansea)
INSERT INTO Route_Stage (route_id, start_station, end_station, distance, stage_order) VALUES
(2, 'RUG', 'BIR', 25, 1),
(2, 'BIR', 'BRI', 72, 2),
(2, 'BRI', 'SWA', 78, 3);
GO

-- Insert Stages for Route 3 (Birmingham to Euston)
INSERT INTO Route_Stage (route_id, start_station, end_station, distance, stage_order) VALUES
(3, 'BIR', 'EUS', 112, 1);
GO

-- Insert Stages for Route 4 (Manchester to Glasgow)
INSERT INTO Route_Stage (route_id, start_station, end_station, distance, stage_order) VALUES
(4, 'MAN', 'GLA', 220, 1);
GO

-- Insert Stages for Route 5 (York to Edinburgh)
INSERT INTO Route_Stage (route_id, start_station, end_station, distance, stage_order) VALUES
(5, 'YOR', 'EDI', 150, 1);
GO

-- Insert Drivers
INSERT INTO Driver (full_name, date_of_birth, address, phone_number, email, start_date, licence_number) VALUES
('Bert Smith', '1980-05-15', '1 Railway Cottages, Crewe', '01270 111111', 'bert.smith@tfr.co.uk', '2010-06-01', 'TDL123456'),
('Edward Jones', '1975-08-22', '2 Station Road, Derby', '01332 222222', 'edward.jones@tfr.co.uk', '2012-03-15', 'TDL789012'),
('Alice Cooper', '1988-11-30', '3 Train Yard, York', '01904 333333', 'alice.cooper@tfr.co.uk', '2015-01-10', 'TDL345678'),
('Robert Green', '1990-03-12', '4 Locomotive Shed, Bristol', '0117 444444', 'robert.green@tfr.co.uk', '2018-07-22', 'TDL901234'),
('Emma Watson', '1985-07-25', '5 Station Approach, Manchester', '0161 555555', 'emma.watson@tfr.co.uk', '2014-09-15', 'TDL567890');
GO

-- Insert Driver Qualifications
INSERT INTO Driver_Qualification (driver_id, class_id, issue_date) VALUES
(1, '07', '2010-06-01'),
(1, '08', '2010-06-01'),
(2, '07', '2012-03-15'),
(2, '08', '2012-03-15'),
(2, '09', '2015-06-20'),
(3, '09', '2015-01-10'),
(4, '07', '2018-07-22'),
(4, '08', '2018-07-22'),
(5, '08', '2014-09-15'),
(5, '09', '2016-11-01');
GO

-- Insert Train
INSERT INTO Train (consignment_id, route_id, loco_id, driver1_id, driver2_id, total_length, gross_weight, schedule_date)
VALUES (1, 1, '09001', 2, 3, 320.2, 1436.8, '2026-04-15');
GO

-- Insert Train Wagons
INSERT INTO Train_Wagon (train_id, wagon_id) VALUES
(1, '94005'), (1, '94007'), (1, '94102'), (1, '94103'), (1, '94104'),
(1, '94203'), (1, '94204'), (1, '94205'), (1, '94206'), (1, '94501'),
(1, '94502'), (1, '94503'), (1, '94506'), (1, '94507'), (1, '94508'),
(1, '94600');
GO

USE TFR_Train_Scheduling_System;
GO

-- ============================================
-- REQUIREMENT 1: Maintaining rail network details for routing
-- ============================================

-- 1.1 Display complete rail network
PRINT '=== 1.1 Complete Rail Network Map ===';
SELECT * FROM vw_RouteDetails;
GO

-- 1.2 Find route and calculate journey distance for a consignment
PRINT '=== 1.2 Route and Distance for Consignment #1 ===';
EXEC sp_GetRouteDetails @route_id = 1;
GO

-- ============================================
-- REQUIREMENT 2: Rolling stock details and availability
-- ============================================

-- 2.1 View available rolling stock
PRINT '=== 2.1 Available Locomotives ===';
SELECT * FROM vw_AvailableLocomotives;
GO

PRINT '=== 2.2 Available Wagons ===';
SELECT * FROM vw_AvailableWagons;
GO

-- 2.2 Summary of all rolling stock
PRINT '=== 2.3 Complete Rolling Stock Inventory ===';
SELECT 
    'LOCOMOTIVE' AS stock_type,
    l.loco_id AS id,
    l.class_id,
    ISNULL(l.familiar_name, 'Unnamed') AS name,
    lc.max_towing_weight AS capacity_tonnes,
    lc.length_metres AS length_metres,
    CASE WHEN l.loco_id IN (SELECT loco_id FROM Train) THEN 'ASSIGNED' ELSE 'AVAILABLE' END AS status
FROM Locomotive l
JOIN Locomotive_Class lc ON l.class_id = lc.class_id

UNION ALL

SELECT 
    'WAGON' AS stock_type,
    w.wagon_id AS id,
    w.type_id AS class_id,
    wt.description AS name,
    wt.max_payload AS capacity_tonnes,
    wt.length AS length_metres,
    CASE WHEN w.wagon_id IN (SELECT wagon_id FROM Train_Wagon) THEN 'ASSIGNED' ELSE 'AVAILABLE' END AS status
FROM Freight_Wagon w
JOIN Wagon_Type wt ON w.type_id = wt.type_id
ORDER BY stock_type, status, id;
GO

-- ============================================
-- REQUIREMENT 3: Recording details of goods conveyed
-- ============================================

-- 3.1 View all consignments with goods details
PRINT '=== 3.1 All Consignments and Goods ===';
SELECT 
    c.consignment_id,
    g.description AS goods,
    c.quantity,
    g.unit_weight,
    c.quantity * ISNULL(g.unit_weight, 1) AS total_weight,
    s1.station_name AS collection,
    s2.station_name AS delivery,
    comp.company_name AS customer
FROM Consignment c
JOIN Goods g ON c.goods_id = g.goods_id
JOIN Station s1 ON c.collection_station = s1.station_id
JOIN Station s2 ON c.delivery_station = s2.station_id
JOIN Company comp ON c.company_id = comp.company_id;
GO

-- 3.2 Pending consignments (not yet scheduled)
PRINT '=== 3.2 Pending Consignments ===';
SELECT 
    c.consignment_id,
    g.description,
    c.quantity * ISNULL(g.unit_weight, 1) AS weight_tonnes
FROM Consignment c
JOIN Goods g ON c.goods_id = g.goods_id
WHERE c.consignment_id NOT IN (SELECT consignment_id FROM Train);
GO

-- ============================================
-- REQUIREMENT 4: Production of train schedules with efficient allocation
-- ============================================

-- 4.1 Calculate required trains for a consignment (using existing procedure)
PRINT '=== 4.1 Calculate Required Trains for Consignment #1 ===';
EXEC sp_CalculateRequiredTrains @consignment_id = 1;
GO

-- 4.2 Find suitable locomotives for a consignment (using existing procedure)
PRINT '=== 4.2 Suitable Locomotives for Consignment #1 ===';
EXEC sp_FindSuitableLocomotives @consignment_id = 1;
GO

-- 4.3 View current train schedule (using existing view)
PRINT '=== 4.3 Current Train Schedule ===';
SELECT 
    train_id,
    locomotive_id,
    locomotive_class,
    primary_driver,
    secondary_driver,
    route_miles,
    total_length,
    gross_weight
FROM vw_TrainDetails;
GO


SELECT lc.class_id, COUNT(l.loco_id) AS locomotive_count
FROM Locomotive_Class lc
LEFT JOIN Locomotive l ON lc.class_id = l.class_id
GROUP BY lc.class_id;