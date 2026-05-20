USE hospital_db;
SET NAMES utf8mb4;

-- =====================================================
-- OFFICIAL REFERENCE DATA
-- Τα παρακάτω CSV προέρχονται από τις επίσημες πηγές
-- ICD-10, ΚΕΝ, ιατρικές πράξεις και EMA Article 57.
-- =====================================================

LOAD DATA LOCAL INFILE 'data/icd10_diagnosis.csv'
INTO TABLE icd10_diagnosis
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(icd10_code, description, category);

LOAD DATA LOCAL INFILE 'data/ken_code.csv'
INTO TABLE ken_code
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ken_code, description, base_cost, average_los_days, extra_daily_charge);

LOAD DATA LOCAL INFILE 'data/medical_procedure.csv'
INTO TABLE medical_procedure
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(procedure_code, name, category, duration_minutes, cost, required_room_type);

LOAD DATA LOCAL INFILE 'data/medication.csv'
IGNORE INTO TABLE medication
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(medication_id, @ema_product_code, @product_name, @form, @authorization_holder)
SET
    ema_product_code = NULLIF(LEFT(TRIM(@ema_product_code), 100), ''),
    product_name = CASE
        WHEN TRIM(@product_name) = '' THEN CONCAT('Unknown product ', medication_id)
        ELSE LEFT(TRIM(@product_name), 255)
    END,
    form = NULLIF(LEFT(TRIM(@form), 100), ''),
    authorization_holder = NULLIF(LEFT(TRIM(@authorization_holder), 255), '');

LOAD DATA LOCAL INFILE 'data/active_substance.csv'
IGNORE INTO TABLE active_substance
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(substance_id, @name)
SET
    name = LEFT(TRIM(@name), 255);

LOAD DATA LOCAL INFILE 'data/medication_substance.csv'
IGNORE INTO TABLE medication_substance
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(medication_id, substance_id);

-- =====================================================
-- OPERATIONAL HOSPITAL DATA
-- Synthetic operational data for the hospital system.
-- The reference data above remain official.
-- Names, surnames, phones, emails and identifiers are generated.
-- No real personal data are used.
-- =====================================================

INSERT INTO insurance_provider (insurance_provider_id, name, provider_type)
VALUES
(1, 'ΕΟΠΥΥ', 'Δημόσιος'),
(2, 'ΕΦΚΑ', 'Δημόσιος'),
(3, 'Ιδιωτική Ασφάλεια Α', 'Ιδιωτικός'),
(4, 'Ιδιωτική Ασφάλεια Β', 'Ιδιωτικός'),
(5, 'Ανασφάλιστος', 'Ανασφάλιστος');

INSERT INTO department (department_id, name, description, bed_count, floor_building, director_doctor_id)
VALUES
(1, 'Καρδιολογία', 'Τμήμα καρδιολογικών περιστατικών', 20, 'Κτίριο Α - 1ος όροφος', NULL),
(2, 'Χειρουργική', 'Τμήμα γενικής χειρουργικής', 20, 'Κτίριο Α - 2ος όροφος', NULL),
(3, 'Παθολογία', 'Τμήμα παθολογικών περιστατικών', 20, 'Κτίριο Β - 1ος όροφος', NULL),
(4, 'ΜΕΘ', 'Μονάδα Εντατικής Θεραπείας', 20, 'Κτίριο Β - 2ος όροφος', NULL),
(5, 'Επείγοντα', 'Τμήμα επειγόντων περιστατικών', 20, 'Κτίριο Γ - Ισόγειο', NULL),
(6, 'Ορθοπαιδική', 'Τμήμα ορθοπαιδικών περιστατικών', 20, 'Κτίριο Γ - 1ος όροφος', NULL),
(7, 'Πνευμονολογική', 'Τμήμα αναπνευστικών παθήσεων', 20, 'Κτίριο Δ - 1ος όροφος', NULL),
(8, 'Νευρολογική', 'Τμήμα νευρολογικών περιστατικών', 20, 'Κτίριο Δ - 2ος όροφος', NULL),
(9, 'Ουρολογική', 'Τμήμα ουρολογικών περιστατικών', 20, 'Κτίριο Ε - 1ος όροφος', NULL),
(10, 'Γαστρεντερολογική', 'Τμήμα πεπτικού συστήματος', 20, 'Κτίριο Ε - 2ος όροφος', NULL),
(11, 'Οφθαλμολογική', 'Τμήμα οφθαλμολογικών περιστατικών', 20, 'Κτίριο Ζ - 1ος όροφος', NULL),
(12, 'ΩΡΛ', 'Τμήμα ΩΡΛ περιστατικών', 20, 'Κτίριο Ζ - 2ος όροφος', NULL),
(13, 'Νεφρολογική', 'Τμήμα νεφρολογικών περιστατικών', 20, 'Κτίριο Η - 1ος όροφος', NULL),
(14, 'Ενδοκρινολογική', 'Τμήμα ενδοκρινολογικών περιστατικών', 20, 'Κτίριο Η - 2ος όροφος', NULL),
(15, 'Παιδιατρική', 'Παιδιατρικό τμήμα', 20, 'Κτίριο Θ - 1ος όροφος', NULL);

INSERT INTO procedure_room (room_id, name, room_type, location)
VALUES
(1, 'Χειρουργείο 1', 'χειρουργείο', 'Κτίριο Α - 2ος όροφος'),
(2, 'Χειρουργείο 2', 'χειρουργείο', 'Κτίριο Α - 2ος όροφος'),
(3, 'Χειρουργείο 3', 'χειρουργείο', 'Κτίριο Α - 2ος όροφος'),
(4, 'Χειρουργείο 4', 'χειρουργείο', 'Κτίριο Β - 2ος όροφος'),
(5, 'Χειρουργείο 5', 'χειρουργείο', 'Κτίριο Β - 2ος όροφος'),
(6, 'Αίθουσα Επεμβάσεων 1', 'αίθουσα επέμβασης', 'Κτίριο Γ - 1ος όροφος'),
(7, 'Αίθουσα Επεμβάσεων 2', 'αίθουσα επέμβασης', 'Κτίριο Γ - 1ος όροφος'),
(8, 'Αίθουσα Επεμβάσεων 3', 'αίθουσα επέμβασης', 'Κτίριο Δ - 1ος όροφος'),
(9, 'Αίθουσα Διαγνωστικών Πράξεων 1', 'διαγνωστική αίθουσα', 'Κτίριο Δ - 2ος όροφος'),
(10, 'Αίθουσα Διαγνωστικών Πράξεων 2', 'διαγνωστική αίθουσα', 'Κτίριο Ε - 1ος όροφος');

DELIMITER $$

CREATE PROCEDURE populate_operational_data()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1;
    DECLARE d INT DEFAULT 1;
    DECLARE s INT DEFAULT 1;

    DECLARE v_bed_id INT;
    DECLARE v_department_id INT;
    DECLARE v_patient_id INT;
    DECLARE v_admission_date DATE;
    DECLARE v_los INT;

    DECLARE v_icd_code VARCHAR(20);
    DECLARE v_ken_code VARCHAR(20);
    DECLARE v_proc_code VARCHAR(50);
    DECLARE v_medication_id INT;
    DECLARE v_substance_id INT;

    DECLARE v_icd_count INT;
    DECLARE v_ken_count INT;
    DECLARE v_proc_count INT;
    DECLARE v_med_count INT;
    DECLARE v_substance_count INT;

    DECLARE v_base_cost DECIMAL(10,2);
    DECLARE v_avg_los INT;
    DECLARE v_extra_daily DECIMAL(10,2);
    DECLARE v_extra_charge DECIMAL(10,2);
    DECLARE v_total_cost DECIMAL(10,2);

    DECLARE v_first_name VARCHAR(50);
    DECLARE v_last_name VARCHAR(50);
    DECLARE v_father_name VARCHAR(50);

    -- Temporary helper tables for deterministic selection from official reference data

    DROP TEMPORARY TABLE IF EXISTS tmp_icd;
    CREATE TEMPORARY TABLE tmp_icd (
        rn INT AUTO_INCREMENT PRIMARY KEY,
        icd10_code VARCHAR(20)
    );

    INSERT INTO tmp_icd (icd10_code)
    SELECT icd10_code
    FROM icd10_diagnosis
    ORDER BY icd10_code;

    DROP TEMPORARY TABLE IF EXISTS tmp_ken;
    CREATE TEMPORARY TABLE tmp_ken (
        rn INT AUTO_INCREMENT PRIMARY KEY,
        ken_code VARCHAR(20)
    );

    INSERT INTO tmp_ken (ken_code)
    SELECT ken_code
    FROM ken_code
    ORDER BY ken_code;

    DROP TEMPORARY TABLE IF EXISTS tmp_proc;
    CREATE TEMPORARY TABLE tmp_proc (
        rn INT AUTO_INCREMENT PRIMARY KEY,
        procedure_code VARCHAR(50)
    );

    INSERT INTO tmp_proc (procedure_code)
    SELECT procedure_code
    FROM medical_procedure
    ORDER BY procedure_code;

    DROP TEMPORARY TABLE IF EXISTS tmp_med;
    CREATE TEMPORARY TABLE tmp_med (
        rn INT AUTO_INCREMENT PRIMARY KEY,
        medication_id INT
    );

    INSERT INTO tmp_med (medication_id)
    SELECT medication_id
    FROM medication
    ORDER BY medication_id;

    DROP TEMPORARY TABLE IF EXISTS tmp_substance;
    CREATE TEMPORARY TABLE tmp_substance (
        rn INT AUTO_INCREMENT PRIMARY KEY,
        substance_id INT
    );

    INSERT INTO tmp_substance (substance_id)
    SELECT substance_id
    FROM active_substance
    ORDER BY substance_id;

    SELECT COUNT(*) INTO v_icd_count FROM tmp_icd;
    SELECT COUNT(*) INTO v_ken_count FROM tmp_ken;
    SELECT COUNT(*) INTO v_proc_count FROM tmp_proc;
    SELECT COUNT(*) INTO v_med_count FROM tmp_med;
    SELECT COUNT(*) INTO v_substance_count FROM tmp_substance;

    -- =====================================================
    -- 90 doctors
    -- =====================================================

    SET i = 1;
    WHILE i <= 90 DO
        SET v_first_name = CASE MOD(i - 1, 20)
            WHEN 0 THEN 'Αλέξανδρος'
            WHEN 1 THEN 'Ελένη'
            WHEN 2 THEN 'Γεώργιος'
            WHEN 3 THEN 'Μαρία'
            WHEN 4 THEN 'Δημήτριος'
            WHEN 5 THEN 'Σοφία'
            WHEN 6 THEN 'Νικόλαος'
            WHEN 7 THEN 'Κατερίνα'
            WHEN 8 THEN 'Ιωάννης'
            WHEN 9 THEN 'Αναστασία'
            WHEN 10 THEN 'Παναγιώτης'
            WHEN 11 THEN 'Χριστίνα'
            WHEN 12 THEN 'Ανδρέας'
            WHEN 13 THEN 'Ειρήνη'
            WHEN 14 THEN 'Σταύρος'
            WHEN 15 THEN 'Βασιλική'
            WHEN 16 THEN 'Μιχαήλ'
            WHEN 17 THEN 'Δέσποινα'
            WHEN 18 THEN 'Κωνσταντίνος'
            ELSE 'Άννα'
        END;

        SET v_last_name = CASE MOD(i - 1, 20)
            WHEN 0 THEN 'Παπαδόπουλος'
            WHEN 1 THEN 'Γεωργίου'
            WHEN 2 THEN 'Νικολάου'
            WHEN 3 THEN 'Ιωάννου'
            WHEN 4 THEN 'Δημητρίου'
            WHEN 5 THEN 'Κωνσταντίνου'
            WHEN 6 THEN 'Αντωνίου'
            WHEN 7 THEN 'Χριστοδούλου'
            WHEN 8 THEN 'Αλεξίου'
            WHEN 9 THEN 'Σταύρου'
            WHEN 10 THEN 'Πετρίδης'
            WHEN 11 THEN 'Μιχαηλίδης'
            WHEN 12 THEN 'Αθανασίου'
            WHEN 13 THEN 'Παντελίδης'
            WHEN 14 THEN 'Σωτηρίου'
            WHEN 15 THEN 'Οικονόμου'
            WHEN 16 THEN 'Καραγιάννης'
            WHEN 17 THEN 'Μακρή'
            WHEN 18 THEN 'Βασιλείου'
            ELSE 'Λάμπρου'
        END;

        INSERT INTO staff
        (staff_id, amka, first_name, last_name, age, email, phone, hire_date, staff_type)
        VALUES
        (
            i,
            CONCAT('STF', LPAD(i, 8, '0')),
            v_first_name,
            v_last_name,
            28 + MOD(i, 22),
            CONCAT('doctor.', i, '@ygeiopolis-hospital.gr'),
            CONCAT('210', LPAD(5000000 + i, 7, '0')),
            DATE_ADD('2005-01-01', INTERVAL i MONTH),
            'DOCTOR'
        );

        INSERT INTO doctor
        (staff_id, medical_license_no, specialty, doctor_rank, supervisor_id)
        VALUES
        (
            i,
            CONCAT('MD', LPAD(70000 + i, 6, '0')),
            CASE (i MOD 10)
                WHEN 0 THEN 'Καρδιολογία'
                WHEN 1 THEN 'Χειρουργική'
                WHEN 2 THEN 'Παθολογία'
                WHEN 3 THEN 'ΜΕΘ'
                WHEN 4 THEN 'Επείγοντα'
                WHEN 5 THEN 'Ορθοπαιδική'
                WHEN 6 THEN 'Πνευμονολογική'
                WHEN 7 THEN 'Νευρολογική'
                WHEN 8 THEN 'Ουρολογική'
                ELSE 'Γαστρεντερολογία'
            END,
            CASE
                WHEN i <= 15 THEN 'Διευθυντής'
                WHEN i MOD 5 = 0 THEN 'Ειδικευόμενος'
                WHEN i MOD 2 = 0 THEN 'Επιμελητής Α'
                ELSE 'Επιμελητής Β'
            END,
            CASE
                WHEN i MOD 5 = 0 AND i > 15 THEN ((i - 1) MOD 15) + 1
                ELSE NULL
            END
        );

        INSERT INTO doctor_department (doctor_id, department_id)
        VALUES (i, ((i - 1) MOD 15) + 1);

        IF i MOD 4 = 0 THEN
            INSERT IGNORE INTO doctor_department (doctor_id, department_id)
            VALUES (i, (i MOD 15) + 1);
        END IF;

        SET i = i + 1;
    END WHILE;


    -- Ensure that every generated doctor group used in shifts
    -- has senior coverage when a resident is present.
    UPDATE doctor
    SET doctor_rank = 'Επιμελητής Α'
    WHERE staff_id IN (19, 49, 79);

    -- Department directors
    SET i = 1;
    WHILE i <= 15 DO
        UPDATE department
        SET director_doctor_id = i
        WHERE department_id = i;

        SET i = i + 1;
    END WHILE;

    -- =====================================================
    -- 180 nurses
    -- =====================================================

    SET i = 91;
    WHILE i <= 270 DO
        SET v_first_name = CASE MOD(i - 1, 20)
            WHEN 0 THEN 'Αλέξανδρος'
            WHEN 1 THEN 'Ελένη'
            WHEN 2 THEN 'Γεώργιος'
            WHEN 3 THEN 'Μαρία'
            WHEN 4 THEN 'Δημήτριος'
            WHEN 5 THEN 'Σοφία'
            WHEN 6 THEN 'Νικόλαος'
            WHEN 7 THEN 'Κατερίνα'
            WHEN 8 THEN 'Ιωάννης'
            WHEN 9 THEN 'Αναστασία'
            WHEN 10 THEN 'Παναγιώτης'
            WHEN 11 THEN 'Χριστίνα'
            WHEN 12 THEN 'Ανδρέας'
            WHEN 13 THEN 'Ειρήνη'
            WHEN 14 THEN 'Σταύρος'
            WHEN 15 THEN 'Βασιλική'
            WHEN 16 THEN 'Μιχαήλ'
            WHEN 17 THEN 'Δέσποινα'
            WHEN 18 THEN 'Κωνσταντίνος'
            ELSE 'Άννα'
        END;

        SET v_last_name = CASE MOD(i - 1, 20)
            WHEN 0 THEN 'Παπαδόπουλος'
            WHEN 1 THEN 'Γεωργίου'
            WHEN 2 THEN 'Νικολάου'
            WHEN 3 THEN 'Ιωάννου'
            WHEN 4 THEN 'Δημητρίου'
            WHEN 5 THEN 'Κωνσταντίνου'
            WHEN 6 THEN 'Αντωνίου'
            WHEN 7 THEN 'Χριστοδούλου'
            WHEN 8 THEN 'Αλεξίου'
            WHEN 9 THEN 'Σταύρου'
            WHEN 10 THEN 'Πετρίδης'
            WHEN 11 THEN 'Μιχαηλίδης'
            WHEN 12 THEN 'Αθανασίου'
            WHEN 13 THEN 'Παντελίδης'
            WHEN 14 THEN 'Σωτηρίου'
            WHEN 15 THEN 'Οικονόμου'
            WHEN 16 THEN 'Καραγιάννης'
            WHEN 17 THEN 'Μακρή'
            WHEN 18 THEN 'Βασιλείου'
            ELSE 'Λάμπρου'
        END;

        INSERT INTO staff
        (staff_id, amka, first_name, last_name, age, email, phone, hire_date, staff_type)
        VALUES
        (
            i,
            CONCAT('STF', LPAD(i, 8, '0')),
            v_first_name,
            v_last_name,
            24 + MOD(i, 36),
            CONCAT('nurse.', i, '@ygeiopolis-hospital.gr'),
            CONCAT('210', LPAD(5000000 + i, 7, '0')),
            DATE_ADD('2010-01-01', INTERVAL i DAY),
            'NURSE'
        );

        INSERT INTO nurse (staff_id, nurse_rank, department_id)
        VALUES
        (
            i,
            CASE
                WHEN i MOD 10 = 0 THEN 'Προϊστάμενος'
                WHEN i MOD 3 = 0 THEN 'Βοηθός Νοσηλευτή'
                ELSE 'Νοσηλευτής'
            END,
            ((i - 91) MOD 15) + 1
        );

        SET i = i + 1;
    END WHILE;

    -- =====================================================
    -- 60 administrative staff
    -- =====================================================

    SET i = 271;
    WHILE i <= 330 DO
        SET v_first_name = CASE MOD(i - 1, 20)
            WHEN 0 THEN 'Αλέξανδρος'
            WHEN 1 THEN 'Ελένη'
            WHEN 2 THEN 'Γεώργιος'
            WHEN 3 THEN 'Μαρία'
            WHEN 4 THEN 'Δημήτριος'
            WHEN 5 THEN 'Σοφία'
            WHEN 6 THEN 'Νικόλαος'
            WHEN 7 THEN 'Κατερίνα'
            WHEN 8 THEN 'Ιωάννης'
            WHEN 9 THEN 'Αναστασία'
            WHEN 10 THEN 'Παναγιώτης'
            WHEN 11 THEN 'Χριστίνα'
            WHEN 12 THEN 'Ανδρέας'
            WHEN 13 THEN 'Ειρήνη'
            WHEN 14 THEN 'Σταύρος'
            WHEN 15 THEN 'Βασιλική'
            WHEN 16 THEN 'Μιχαήλ'
            WHEN 17 THEN 'Δέσποινα'
            WHEN 18 THEN 'Κωνσταντίνος'
            ELSE 'Άννα'
        END;

        SET v_last_name = CASE MOD(i - 1, 20)
            WHEN 0 THEN 'Παπαδόπουλος'
            WHEN 1 THEN 'Γεωργίου'
            WHEN 2 THEN 'Νικολάου'
            WHEN 3 THEN 'Ιωάννου'
            WHEN 4 THEN 'Δημητρίου'
            WHEN 5 THEN 'Κωνσταντίνου'
            WHEN 6 THEN 'Αντωνίου'
            WHEN 7 THEN 'Χριστοδούλου'
            WHEN 8 THEN 'Αλεξίου'
            WHEN 9 THEN 'Σταύρου'
            WHEN 10 THEN 'Πετρίδης'
            WHEN 11 THEN 'Μιχαηλίδης'
            WHEN 12 THEN 'Αθανασίου'
            WHEN 13 THEN 'Παντελίδης'
            WHEN 14 THEN 'Σωτηρίου'
            WHEN 15 THEN 'Οικονόμου'
            WHEN 16 THEN 'Καραγιάννης'
            WHEN 17 THEN 'Μακρή'
            WHEN 18 THEN 'Βασιλείου'
            ELSE 'Λάμπρου'
        END;

        INSERT INTO staff
        (staff_id, amka, first_name, last_name, age, email, phone, hire_date, staff_type)
        VALUES
        (
            i,
            CONCAT('STF', LPAD(i, 8, '0')),
            v_first_name,
            v_last_name,
            25 + MOD(i, 35),
            CONCAT('admin.', i, '@ygeiopolis-hospital.gr'),
            CONCAT('210', LPAD(5000000 + i, 7, '0')),
            DATE_ADD('2012-01-01', INTERVAL i DAY),
            'ADMIN'
        );

        INSERT INTO administrative_staff (staff_id, role, office, department_id)
        VALUES
        (
            i,
            CASE
                WHEN i MOD 3 = 0 THEN 'Γραμματεία'
                WHEN i MOD 3 = 1 THEN 'Λογιστήριο'
                ELSE 'Υποδοχή'
            END,
            CONCAT('Γρ.', i),
            ((i - 271) MOD 15) + 1
        );

        SET i = i + 1;
    END WHILE;

    -- =====================================================
    -- 300 beds, 20 per department
    -- =====================================================

    SET i = 1;
    WHILE i <= 300 DO
        SET v_department_id = FLOOR((i - 1) / 20) + 1;

        INSERT INTO bed (bed_id, department_id, bed_number, bed_type, status)
        VALUES
        (
            i,
            v_department_id,
            CONCAT('D', LPAD(v_department_id, 2, '0'), '-B', LPAD(((i - 1) MOD 20) + 1, 2, '0')),
            CASE
                WHEN v_department_id = 4 THEN 'ΜΕΘ'
                WHEN i MOD 5 = 0 THEN 'μονόκλινο'
                ELSE 'πολύκλινο'
            END,
            'διαθέσιμη'
        );

        SET i = i + 1;
    END WHILE;

    -- =====================================================
    -- 200 patients + emergency contacts
    -- =====================================================

    SET i = 1;
    WHILE i <= 200 DO
        SET v_first_name = CASE MOD(i - 1, 20)
            WHEN 0 THEN 'Γεώργιος'
            WHEN 1 THEN 'Μαρία'
            WHEN 2 THEN 'Κωνσταντίνος'
            WHEN 3 THEN 'Ελένη'
            WHEN 4 THEN 'Νικόλαος'
            WHEN 5 THEN 'Αναστασία'
            WHEN 6 THEN 'Δημήτριος'
            WHEN 7 THEN 'Σοφία'
            WHEN 8 THEN 'Ιωάννης'
            WHEN 9 THEN 'Κατερίνα'
            WHEN 10 THEN 'Παναγιώτης'
            WHEN 11 THEN 'Χριστίνα'
            WHEN 12 THEN 'Ανδρέας'
            WHEN 13 THEN 'Βασιλική'
            WHEN 14 THEN 'Σταύρος'
            WHEN 15 THEN 'Ειρήνη'
            WHEN 16 THEN 'Αλέξανδρος'
            WHEN 17 THEN 'Δέσποινα'
            WHEN 18 THEN 'Μιχαήλ'
            ELSE 'Άννα'
        END;

        SET v_last_name = CASE MOD(i - 1, 20)
            WHEN 0 THEN 'Παπαδόπουλος'
            WHEN 1 THEN 'Γεωργίου'
            WHEN 2 THEN 'Νικολάου'
            WHEN 3 THEN 'Ιωάννου'
            WHEN 4 THEN 'Δημητρίου'
            WHEN 5 THEN 'Κωνσταντίνου'
            WHEN 6 THEN 'Αντωνίου'
            WHEN 7 THEN 'Χριστοδούλου'
            WHEN 8 THEN 'Αλεξίου'
            WHEN 9 THEN 'Σταύρου'
            WHEN 10 THEN 'Πετρίδης'
            WHEN 11 THEN 'Μιχαηλίδης'
            WHEN 12 THEN 'Αθανασίου'
            WHEN 13 THEN 'Παντελίδης'
            WHEN 14 THEN 'Σωτηρίου'
            WHEN 15 THEN 'Οικονόμου'
            WHEN 16 THEN 'Καραγιάννης'
            WHEN 17 THEN 'Μακρή'
            WHEN 18 THEN 'Βασιλείου'
            ELSE 'Λάμπρου'
        END;

        SET v_father_name = CASE MOD(i - 1, 10)
            WHEN 0 THEN 'Ιωάννης'
            WHEN 1 THEN 'Γεώργιος'
            WHEN 2 THEN 'Νικόλαος'
            WHEN 3 THEN 'Δημήτριος'
            WHEN 4 THEN 'Κωνσταντίνος'
            WHEN 5 THEN 'Ανδρέας'
            WHEN 6 THEN 'Σταύρος'
            WHEN 7 THEN 'Μιχαήλ'
            WHEN 8 THEN 'Χρήστος'
            ELSE 'Παναγιώτης'
        END;

        INSERT INTO patient
        (patient_id, amka, first_name, last_name, father_name, age, gender, weight, height, address, phone, email, profession, nationality, insurance_provider_id)
        VALUES
        (
            i,
            CONCAT('2801', LPAD(i, 7, '0')),
            v_first_name,
            v_last_name,
            v_father_name,
            18 + MOD(i * 7, 72),
            CASE WHEN i MOD 2 = 0 THEN 'Γυναίκα' ELSE 'Άνδρας' END,
            ROUND(50 + MOD(i * 3, 55), 2),
            ROUND(1.50 + (MOD(i * 5, 40) / 100), 2),
            CONCAT('Οδός Υγείας ', i, ', Αθήνα'),
            CONCAT('69', LPAD(10000000 + i, 8, '0')),
            CONCAT('patient', i, '@example-hospital.gr'),
            CASE MOD(i - 1, 10)
                WHEN 0 THEN 'Ιδιωτικός υπάλληλος'
                WHEN 1 THEN 'Δημόσιος υπάλληλος'
                WHEN 2 THEN 'Ελεύθερος επαγγελματίας'
                WHEN 3 THEN 'Φοιτητής'
                WHEN 4 THEN 'Συνταξιούχος'
                WHEN 5 THEN 'Εκπαιδευτικός'
                WHEN 6 THEN 'Μηχανικός'
                WHEN 7 THEN 'Οδηγός'
                WHEN 8 THEN 'Λογιστής'
                ELSE 'Άνεργος'
            END,
            'Ελληνική',
            ((i - 1) MOD 5) + 1
        );

        INSERT INTO emergency_contact
        (patient_id, full_name, relationship, phone, email)
        VALUES
        (
            i,
            CONCAT(
                CASE MOD(i, 10)
                    WHEN 0 THEN 'Αντώνης'
                    WHEN 1 THEN 'Γεωργία'
                    WHEN 2 THEN 'Νίκη'
                    WHEN 3 THEN 'Χρήστος'
                    WHEN 4 THEN 'Αθηνά'
                    WHEN 5 THEN 'Μάριος'
                    WHEN 6 THEN 'Ευαγγελία'
                    WHEN 7 THEN 'Πέτρος'
                    WHEN 8 THEN 'Λουκία'
                    ELSE 'Θεόδωρος'
                END,
                ' ',
                v_last_name
            ),
            CASE
                WHEN i MOD 4 = 0 THEN 'Σύζυγος'
                WHEN i MOD 4 = 1 THEN 'Γονέας'
                WHEN i MOD 4 = 2 THEN 'Τέκνο'
                ELSE 'Αδελφός/ή'
            END,
            CONCAT('69', LPAD(20000000 + i, 8, '0')),
            CONCAT('contact', i, '@example-hospital.gr')
        );

        SET i = i + 1;
    END WHILE;

    -- =====================================================
    -- 500 hospitalizations
    -- =====================================================

    SET i = 1;
    WHILE i <= 500 DO
        SET v_patient_id = ((i - 1) MOD 200) + 1;
        SET v_bed_id = ((i - 1) MOD 300) + 1;
        SET v_department_id = FLOOR((v_bed_id - 1) / 20) + 1;
        SET v_admission_date = DATE_ADD('2025-01-01', INTERVAL i DAY);
        SET v_los = 1 + (i MOD 12);

        SELECT icd10_code
        INTO v_icd_code
        FROM tmp_icd
        WHERE rn = ((i - 1) MOD v_icd_count) + 1;

        SELECT ken_code
        INTO v_ken_code
        FROM tmp_ken
        WHERE rn = ((i - 1) MOD v_ken_count) + 1;

        SELECT base_cost, average_los_days, extra_daily_charge
        INTO v_base_cost, v_avg_los, v_extra_daily
        FROM ken_code
        WHERE ken_code = v_ken_code;

        SET v_extra_charge = GREATEST(v_los - v_avg_los, 0) * v_extra_daily;
        SET v_total_cost = v_base_cost + v_extra_charge;

        INSERT INTO hospitalization
        (hospitalization_id, patient_id, department_id, bed_id, admission_date, discharge_date,
         admission_icd10_code, discharge_icd10_code, ken_code, base_cost, extra_charge, total_cost)
        VALUES
        (
            i,
            v_patient_id,
            v_department_id,
            v_bed_id,
            v_admission_date,
            DATE_ADD(v_admission_date, INTERVAL v_los DAY),
            v_icd_code,
            v_icd_code,
            v_ken_code,
            v_base_cost,
            v_extra_charge,
            v_total_cost
        );

        SET i = i + 1;
    END WHILE;

    -- =====================================================
    -- 350 triage cases
    -- =====================================================

    SET i = 1;
    WHILE i <= 350 DO
        INSERT INTO triage_case
        (patient_id, triage_nurse_id, arrival_time, service_time, symptoms, urgency_level, outcome, referred_department_id, hospitalization_id)
        VALUES
        (
            ((i - 1) MOD 200) + 1,
            91 + ((i - 1) MOD 180),
            DATE_ADD('2025-01-01 08:00:00', INTERVAL i HOUR),
            DATE_ADD('2025-01-01 08:20:00', INTERVAL i HOUR),
            CASE
                WHEN i MOD 5 = 0 THEN 'Πόνος στο στήθος'
                WHEN i MOD 5 = 1 THEN 'Πυρετός και δύσπνοια'
                WHEN i MOD 5 = 2 THEN 'Κοιλιακό άλγος'
                WHEN i MOD 5 = 3 THEN 'Τραυματισμός'
                ELSE 'Γενική αδιαθεσία'
            END,
            (i MOD 5) + 1,
            CASE
                WHEN i <= 300 THEN 'παραπομπή για νοσηλεία'
                ELSE 'οδηγίες και αποχώρηση'
            END,
            CASE
                WHEN i <= 300 THEN ((i - 1) MOD 15) + 1
                ELSE NULL
            END,
            CASE
                WHEN i <= 300 THEN i
                ELSE NULL
            END
        );

        SET i = i + 1;
    END WHILE;

    -- =====================================================
    -- 315 shifts and assignments
    -- 15 departments * 7 days * 3 shift types
    -- =====================================================

    SET i = 1;
    SET d = 1;

    WHILE d <= 15 DO
        SET j = 0;
        WHILE j <= 6 DO
            SET s = 1;
            WHILE s <= 3 DO
                INSERT INTO shift
                (shift_id, department_id, shift_date, shift_type, start_datetime, end_datetime)
                VALUES
                (
                    i,
                    d,
                    DATE_ADD('2026-05-01', INTERVAL j DAY),
                    CASE s
                        WHEN 1 THEN 'πρωινή'
                        WHEN 2 THEN 'απογευματινή'
                        ELSE 'νυχτερινή'
                    END,
                    CASE s
                        WHEN 1 THEN DATE_ADD(DATE_ADD('2026-05-01 07:00:00', INTERVAL j DAY), INTERVAL 0 HOUR)
                        WHEN 2 THEN DATE_ADD(DATE_ADD('2026-05-01 15:00:00', INTERVAL j DAY), INTERVAL 0 HOUR)
                        ELSE DATE_ADD(DATE_ADD('2026-05-01 23:00:00', INTERVAL j DAY), INTERVAL 0 HOUR)
                    END,
                    CASE s
                        WHEN 1 THEN DATE_ADD(DATE_ADD('2026-05-01 15:00:00', INTERVAL j DAY), INTERVAL 0 HOUR)
                        WHEN 2 THEN DATE_ADD(DATE_ADD('2026-05-01 23:00:00', INTERVAL j DAY), INTERVAL 0 HOUR)
                        ELSE DATE_ADD(DATE_ADD('2026-05-02 07:00:00', INTERVAL j DAY), INTERVAL 0 HOUR)
                    END
                );

                -- Staff assignments respecting the 8-hour rest rule.
                -- Two alternating staff pools are used per department.
                -- Odd shift slots use pool A, even shift slots use pool B.
                SET @slot_group = MOD(j * 3 + s, 2);

                -- 3 doctors per shift
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, ((d - 1) * 3) + 1, 45 + ((d - 1) * 3) + 1));
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, ((d - 1) * 3) + 2, 45 + ((d - 1) * 3) + 2));
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, ((d - 1) * 3) + 3, 45 + ((d - 1) * 3) + 3));

                -- 6 nurses per shift
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, 90 + ((d - 1) * 6) + 1, 180 + ((d - 1) * 6) + 1));
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, 90 + ((d - 1) * 6) + 2, 180 + ((d - 1) * 6) + 2));
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, 90 + ((d - 1) * 6) + 3, 180 + ((d - 1) * 6) + 3));
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, 90 + ((d - 1) * 6) + 4, 180 + ((d - 1) * 6) + 4));
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, 90 + ((d - 1) * 6) + 5, 180 + ((d - 1) * 6) + 5));
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, 90 + ((d - 1) * 6) + 6, 180 + ((d - 1) * 6) + 6));

                -- 2 administrative staff per shift
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, 270 + ((d - 1) * 2) + 1, 300 + ((d - 1) * 2) + 1));
                INSERT INTO shift_assignment (shift_id, staff_id)
                VALUES (i, IF(@slot_group = 1, 270 + ((d - 1) * 2) + 2, 300 + ((d - 1) * 2) + 2));

                SET i = i + 1;
                SET s = s + 1;
            END WHILE;
            SET j = j + 1;
        END WHILE;
        SET d = d + 1;
    END WHILE;

    -- =====================================================
    -- 200 laboratory tests
    -- =====================================================

    SET i = 1;
    WHILE i <= 200 DO
        INSERT INTO lab_test
        (lab_test_id, hospitalization_id, test_code, test_type, test_date, result_text, result_value, result_unit, cost, ordering_doctor_id)
        VALUES
        (
            i,
            ((i - 1) MOD 500) + 1,
            CONCAT('LAB', LPAD(i, 5, '0')),
            CASE
                WHEN i MOD 4 = 0 THEN 'Αιματολογική'
                WHEN i MOD 4 = 1 THEN 'Βιοχημική'
                WHEN i MOD 4 = 2 THEN 'Απεικονιστική'
                ELSE 'Μικροβιολογική'
            END,
            DATE_ADD('2025-01-01 10:00:00', INTERVAL i HOUR),
            CONCAT('Αποτέλεσμα εξέτασης ', i),
            ROUND((i MOD 100) * 1.25, 2),
            CASE
                WHEN i MOD 4 = 0 THEN 'mg/dL'
                WHEN i MOD 4 = 1 THEN 'g/dL'
                WHEN i MOD 4 = 2 THEN NULL
                ELSE 'U/L'
            END,
            15.00 + (i MOD 50),
            ((i - 1) MOD 90) + 1
        );

        SET i = i + 1;
    END WHILE;

    -- =====================================================
    -- 150 performed procedures
    -- =====================================================

    SET i = 1;
    WHILE i <= 150 DO
        SELECT procedure_code
        INTO v_proc_code
        FROM tmp_proc
        WHERE rn = ((i - 1) MOD v_proc_count) + 1;

        INSERT INTO performed_procedure
        (performed_id, hospitalization_id, procedure_code, room_id, main_surgeon_id, start_datetime, end_datetime, cost)
        VALUES
        (
            i,
            ((i - 1) MOD 500) + 1,
            v_proc_code,
            ((i - 1) MOD 10) + 1,
            ((i - 1) MOD 90) + 1,
            DATE_ADD('2025-01-01 09:00:00', INTERVAL i * 3 HOUR),
            DATE_ADD('2025-01-01 10:30:00', INTERVAL i * 3 HOUR),
            300.00 + (i MOD 30) * 25.00
        );

        INSERT INTO procedure_participant (performed_id, staff_id, role)
        VALUES
        (i, 91 + ((i - 1) MOD 180), 'Βοηθός νοσηλευτής');

        INSERT INTO procedure_participant (performed_id, staff_id, role)
        VALUES
        (i, 1 + (i MOD 90), 'Συμμετέχων ιατρός');

        SET i = i + 1;
    END WHILE;


    -- =====================================================
    -- 300 prescriptions
    -- =====================================================

    SET i = 1;
    WHILE i <= 300 DO
        SELECT medication_id
        INTO v_medication_id
        FROM tmp_med
        WHERE rn = ((i - 1) MOD v_med_count) + 1;

        INSERT INTO prescription
        (prescription_id, doctor_id, patient_id, hospitalization_id, medication_id, dosage, frequency, start_date, end_date)
        VALUES
        (
            i,
            ((i - 1) MOD 90) + 1,
            ((i - 1) MOD 200) + 1,
            ((i - 1) MOD 500) + 1,
            v_medication_id,
            CASE
                WHEN i MOD 3 = 0 THEN '1 δισκίο'
                WHEN i MOD 3 = 1 THEN '500mg'
                ELSE '10ml'
            END,
            CASE
                WHEN i MOD 3 = 0 THEN '1 φορά/ημέρα'
                WHEN i MOD 3 = 1 THEN '2 φορές/ημέρα'
                ELSE '3 φορές/ημέρα'
            END,
            (SELECT h.admission_date FROM hospitalization h WHERE h.hospitalization_id = ((i - 1) MOD 500) + 1),
            (SELECT h.discharge_date FROM hospitalization h WHERE h.hospitalization_id = ((i - 1) MOD 500) + 1)
        );

        SET i = i + 1;
    END WHILE;

    -- =====================================================
    -- 350 hospitalization reviews
    -- =====================================================

    SET i = 1;
    WHILE i <= 350 DO
        INSERT INTO hospitalization_review
        (review_id, hospitalization_id, medical_care, nursing_care, cleanliness, food, overall_experience, review_date, comments)
        VALUES
        (
            i,
            i,
            (i MOD 5) + 1,
            ((i + 1) MOD 5) + 1,
            ((i + 2) MOD 5) + 1,
            ((i + 3) MOD 5) + 1,
            ((i + 4) MOD 5) + 1,
            DATE_ADD('2025-01-15', INTERVAL i DAY),
            CONCAT('Αξιολόγηση νοσηλείας ', i)
        );

        SET i = i + 1;
    END WHILE;


    -- =====================================================
    -- 100 entity images
    -- =====================================================

    SET i = 1;
    WHILE i <= 100 DO
        INSERT INTO entity_image
        (image_id, entity_type, entity_id, image_url, description)
        VALUES
        (
            i,
            CASE
                WHEN i MOD 5 = 0 THEN 'department'
                WHEN i MOD 5 = 1 THEN 'doctor'
                WHEN i MOD 5 = 2 THEN 'patient'
                WHEN i MOD 5 = 3 THEN 'procedure_room'
                ELSE 'medication'
            END,
            CASE
                WHEN i MOD 5 = 0 THEN ((i - 1) MOD 15) + 1
                WHEN i MOD 5 = 1 THEN ((i - 1) MOD 90) + 1
                WHEN i MOD 5 = 2 THEN ((i - 1) MOD 200) + 1
                WHEN i MOD 5 = 3 THEN ((i - 1) MOD 10) + 1
                ELSE ((i - 1) MOD v_med_count) + 1
            END,
            CONCAT('images/entity_', i, '.jpg'),
            CONCAT('Εικόνα οντότητας ', i)
        );

        SET i = i + 1;
    END WHILE;

END$$

DELIMITER ;

CALL populate_operational_data();

DROP PROCEDURE populate_operational_data;

-- =====================================================
-- GUARANTEE DATA FOR QUERIES
-- Τα παρακάτω blocks χρησιμοποιούν ήδη υπάρχουσες εγγραφές.
-- Δεν αλλοιώνουν τα επίσημα reference data.
-- Εξασφαλίζουν ότι τα ζητούμενα queries επιστρέφουν αποτέλεσμα.
-- =====================================================

-- Guarantee data for Q03:
-- patient_id = 1 has more than 3 hospitalizations in the same department.
UPDATE hospitalization h
JOIN (
    SELECT hospitalization_id
    FROM hospitalization
    ORDER BY hospitalization_id
    LIMIT 4
) x
    ON h.hospitalization_id = x.hospitalization_id
SET
    h.patient_id = 1,
    h.department_id = 1,
    h.bed_id = h.hospitalization_id;


-- Keep prescriptions consistent with the adjusted hospitalizations for Q03.
UPDATE prescription p
JOIN hospitalization h
    ON h.hospitalization_id = p.hospitalization_id
SET
    p.patient_id = h.patient_id,
    p.start_date = h.admission_date,
    p.end_date = h.discharge_date
WHERE h.hospitalization_id IN (1, 2, 3, 4);

-- Guarantee data for Q10:
-- Create co-prescribed active substance pairs in the same hospitalization.
-- Dates and patient IDs are kept consistent with the selected hospitalizations.
UPDATE prescription
SET
    patient_id = 1,
    hospitalization_id = 1,
    medication_id = 1,
    start_date = (SELECT h.admission_date FROM hospitalization h WHERE h.hospitalization_id = 1),
    end_date = (SELECT h.discharge_date FROM hospitalization h WHERE h.hospitalization_id = 1)
WHERE prescription_id = 1;

UPDATE prescription
SET
    patient_id = 1,
    hospitalization_id = 1,
    medication_id = 3,
    start_date = (SELECT h.admission_date FROM hospitalization h WHERE h.hospitalization_id = 1),
    end_date = (SELECT h.discharge_date FROM hospitalization h WHERE h.hospitalization_id = 1)
WHERE prescription_id = 2;

UPDATE prescription
SET
    patient_id = 1,
    hospitalization_id = 1,
    medication_id = 5,
    start_date = (SELECT h.admission_date FROM hospitalization h WHERE h.hospitalization_id = 1),
    end_date = (SELECT h.discharge_date FROM hospitalization h WHERE h.hospitalization_id = 1)
WHERE prescription_id = 3;

UPDATE prescription
SET
    patient_id = 5,
    hospitalization_id = 5,
    medication_id = 1,
    start_date = (SELECT h.admission_date FROM hospitalization h WHERE h.hospitalization_id = 5),
    end_date = (SELECT h.discharge_date FROM hospitalization h WHERE h.hospitalization_id = 5)
WHERE prescription_id = 4;

UPDATE prescription
SET
    patient_id = 5,
    hospitalization_id = 5,
    medication_id = 3,
    start_date = (SELECT h.admission_date FROM hospitalization h WHERE h.hospitalization_id = 5),
    end_date = (SELECT h.discharge_date FROM hospitalization h WHERE h.hospitalization_id = 5)
WHERE prescription_id = 5;

UPDATE prescription
SET
    patient_id = 6,
    hospitalization_id = 6,
    medication_id = 1,
    start_date = (SELECT h.admission_date FROM hospitalization h WHERE h.hospitalization_id = 6),
    end_date = (SELECT h.discharge_date FROM hospitalization h WHERE h.hospitalization_id = 6)
WHERE prescription_id = 6;

UPDATE prescription
SET
    patient_id = 6,
    hospitalization_id = 6,
    medication_id = 5,
    start_date = (SELECT h.admission_date FROM hospitalization h WHERE h.hospitalization_id = 6),
    end_date = (SELECT h.discharge_date FROM hospitalization h WHERE h.hospitalization_id = 6)
WHERE prescription_id = 7;

-- Generate patient allergies after final prescriptions, avoiding conflicts
-- with each patient's prescribed medication substances.
INSERT IGNORE INTO patient_allergy (patient_id, substance_id)
SELECT
    p.patient_id,
    (
        SELECT a.substance_id
        FROM active_substance a
        WHERE NOT EXISTS (
            SELECT 1
            FROM prescription pr
            JOIN medication_substance ms
                ON ms.medication_id = pr.medication_id
            WHERE pr.patient_id = p.patient_id
              AND ms.substance_id = a.substance_id
        )
        ORDER BY a.substance_id
        LIMIT 1
    ) AS safe_substance_id
FROM patient p
WHERE p.patient_id BETWEEN 1 AND 80;

-- Regenerate doctor reviews from the final prescription data.
DELETE FROM doctor_review;

INSERT INTO doctor_review
(hospitalization_id, doctor_id, medical_care, review_date, comments)
SELECT
    x.hospitalization_id,
    x.doctor_id,
    3 + (x.rn MOD 3) AS medical_care,
    h.discharge_date AS review_date,
    CONCAT('Αξιολόγηση ιατρικής φροντίδας για ιατρό ', x.doctor_id)
FROM (
    SELECT
        p.hospitalization_id,
        p.doctor_id,
        MIN(p.prescription_id) AS rn
    FROM prescription p
    GROUP BY p.hospitalization_id, p.doctor_id
) x
JOIN hospitalization h
    ON h.hospitalization_id = x.hospitalization_id
WHERE h.discharge_date IS NOT NULL;

-- Guarantee data for Q11:
-- Make doctor_id = 21 the top doctor in the current year.
-- Q11 filters by performed_procedure.start_datetime, so these
-- guaranteed procedures must also have current-year start/end times.
UPDATE performed_procedure pp
JOIN (
    SELECT performed_id
    FROM performed_procedure
    ORDER BY performed_id DESC
    LIMIT 10
) x
    ON pp.performed_id = x.performed_id
SET
    pp.main_surgeon_id = 21,
    pp.start_datetime = TIMESTAMP(
        DATE_ADD(MAKEDATE(YEAR(CURDATE()), 1), INTERVAL (pp.performed_id MOD 30) DAY),
        '09:00:00'
    ),
    pp.end_datetime = TIMESTAMP(
        DATE_ADD(MAKEDATE(YEAR(CURDATE()), 1), INTERVAL (pp.performed_id MOD 30) DAY),
        '10:30:00'
    );

-- Guarantee data for Q14:
-- Create one ICD-10 category with exactly 5 admissions in 2025
-- and exactly 5 admissions in 2026, using existing ICD-10 codes.
SET @target_category := (
    SELECT category
    FROM icd10_diagnosis
    WHERE category IS NOT NULL
    GROUP BY category
    ORDER BY category
    LIMIT 1
);

SET @target_code := (
    SELECT icd10_code
    FROM icd10_diagnosis
    WHERE category = @target_category
    ORDER BY icd10_code
    LIMIT 1
);

SET @backup_code := (
    SELECT icd10_code
    FROM icd10_diagnosis
    WHERE category <> @target_category
    ORDER BY icd10_code
    LIMIT 1
);

UPDATE hospitalization h
JOIN icd10_diagnosis icd
    ON h.admission_icd10_code = icd.icd10_code
SET h.admission_icd10_code = @backup_code
WHERE icd.category = @target_category;

UPDATE hospitalization h
JOIN icd10_diagnosis icd
    ON h.discharge_icd10_code = icd.icd10_code
SET h.discharge_icd10_code = @backup_code
WHERE icd.category = @target_category;

UPDATE hospitalization
SET
    admission_date = '2025-06-01',
    discharge_date = '2025-06-05',
    admission_icd10_code = @target_code,
    discharge_icd10_code = @target_code
WHERE hospitalization_id IN (1, 2, 3, 4, 5);

UPDATE hospitalization
SET
    admission_date = '2026-06-01',
    discharge_date = '2026-06-05',
    admission_icd10_code = @target_code,
    discharge_icd10_code = @target_code
WHERE hospitalization_id IN (6, 7, 8, 9, 10);


-- Keep existing prescriptions valid after the Q14 date adjustments.
UPDATE prescription p
JOIN hospitalization h
    ON h.hospitalization_id = p.hospitalization_id
SET
    p.start_date = h.admission_date,
    p.end_date = h.discharge_date
WHERE p.start_date < h.admission_date
   OR p.end_date > h.discharge_date
   OR p.end_date IS NULL;

-- Keep existing reviews valid after the Q14 date adjustments.
UPDATE hospitalization_review hr
JOIN hospitalization h
    ON h.hospitalization_id = hr.hospitalization_id
SET hr.review_date = h.discharge_date
WHERE hr.review_date < h.discharge_date;

UPDATE doctor_review dr
JOIN hospitalization h
    ON h.hospitalization_id = dr.hospitalization_id
SET dr.review_date = h.discharge_date
WHERE dr.review_date < h.discharge_date;

-- Validate aggregate shift requirements enforced by the strict install.sql.
UPDATE shift
SET is_finalized = TRUE;

CALL validate_shift_requirements();

-- =====================================================
-- BASIC LOAD CHECKS
-- =====================================================

SELECT 'staff' AS table_name, COUNT(*) AS row_count FROM staff
UNION ALL
SELECT 'doctor', COUNT(*) FROM doctor
UNION ALL
SELECT 'nurse', COUNT(*) FROM nurse
UNION ALL
SELECT 'administrative_staff', COUNT(*) FROM administrative_staff
UNION ALL
SELECT 'department', COUNT(*) FROM department
UNION ALL
SELECT 'bed', COUNT(*) FROM bed
UNION ALL
SELECT 'patient', COUNT(*) FROM patient
UNION ALL
SELECT 'hospitalization', COUNT(*) FROM hospitalization
UNION ALL
SELECT 'prescription', COUNT(*) FROM prescription
UNION ALL
SELECT 'procedure_room', COUNT(*) FROM procedure_room
UNION ALL
SELECT 'performed_procedure', COUNT(*) FROM performed_procedure
UNION ALL
SELECT 'lab_test', COUNT(*) FROM lab_test
UNION ALL
SELECT 'hospitalization_review', COUNT(*) FROM hospitalization_review
UNION ALL
SELECT 'doctor_review', COUNT(*) FROM doctor_review
UNION ALL
SELECT 'icd10_diagnosis', COUNT(*) FROM icd10_diagnosis
UNION ALL
SELECT 'ken_code', COUNT(*) FROM ken_code
UNION ALL
SELECT 'medical_procedure', COUNT(*) FROM medical_procedure
UNION ALL
SELECT 'medication', COUNT(*) FROM medication
UNION ALL
SELECT 'active_substance', COUNT(*) FROM active_substance
UNION ALL
SELECT 'medication_substance', COUNT(*) FROM medication_substance
UNION ALL
SELECT 'patient_allergy', COUNT(*) FROM patient_allergy;
