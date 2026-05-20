DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hospital_db;

CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    amka VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    age INT NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(30),
    hire_date DATE NOT NULL,
    staff_type VARCHAR(20) NOT NULL,
    CHECK (age > 0),
    CHECK (staff_type IN ('DOCTOR', 'NURSE', 'ADMIN'))
);

CREATE TABLE department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    bed_count INT NOT NULL,
    floor_building VARCHAR(100),
    director_doctor_id INT NULL,
    CHECK (bed_count >= 0)
);

CREATE TABLE doctor (
    staff_id INT PRIMARY KEY,
    medical_license_no VARCHAR(50) NOT NULL UNIQUE,
    specialty VARCHAR(100) NOT NULL,
    doctor_rank VARCHAR(50) NOT NULL,
    supervisor_id INT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (supervisor_id) REFERENCES doctor(staff_id),
    CHECK (
        (doctor_rank = 'Ειδικευόμενος' AND supervisor_id IS NOT NULL)
        OR
        (doctor_rank = 'Διευθυντής' AND supervisor_id IS NULL)
        OR
        (doctor_rank NOT IN ('Ειδικευόμενος', 'Διευθυντής'))
    )
);

ALTER TABLE department
ADD CONSTRAINT fk_department_director
FOREIGN KEY (director_doctor_id) REFERENCES doctor(staff_id);

CREATE TABLE nurse (
    staff_id INT PRIMARY KEY,
    nurse_rank VARCHAR(50) NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    CHECK (nurse_rank IN ('Βοηθός Νοσηλευτή', 'Νοσηλευτής', 'Προϊστάμενος'))
);

CREATE TABLE administrative_staff (
    staff_id INT PRIMARY KEY,
    role VARCHAR(100) NOT NULL,
    office VARCHAR(100),
    department_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

CREATE TABLE doctor_department (
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (doctor_id, department_id),
    FOREIGN KEY (doctor_id) REFERENCES doctor(staff_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

CREATE TABLE bed (
    bed_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    bed_number VARCHAR(20) NOT NULL,
    bed_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    UNIQUE (department_id, bed_number),
    CHECK (status IN ('διαθέσιμη', 'κατειλημμένη', 'υπό συντήρηση'))
);

CREATE TABLE insurance_provider (
    insurance_provider_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    provider_type VARCHAR(50) NOT NULL,
    CHECK (provider_type IN ('Δημόσιος', 'Ιδιωτικός', 'Ανασφάλιστος'))
);

CREATE TABLE patient (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    amka VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    father_name VARCHAR(50),
    age INT NOT NULL,
    gender VARCHAR(20),
    weight DECIMAL(5,2),
    height DECIMAL(5,2),
    address VARCHAR(200),
    phone VARCHAR(30),
    email VARCHAR(100),
    profession VARCHAR(100),
    nationality VARCHAR(100),
    insurance_provider_id INT NOT NULL, 
    FOREIGN KEY(insurance_provider_id) REFERENCES insurance_provider(insurance_provider_id),
    CHECK (age >= 0)
);

CREATE TABLE emergency_contact (
    contact_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    relationship VARCHAR(50),
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(100),
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
);

CREATE TABLE icd10_diagnosis (
    icd10_code VARCHAR(20) PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    category VARCHAR(20) NOT NULL
);

CREATE TABLE ken_code (
    ken_code VARCHAR(20) PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    base_cost DECIMAL(10,2) NOT NULL,
    average_los_days INT NOT NULL,
    extra_daily_charge DECIMAL(10,2) NOT NULL,
    CHECK (base_cost >= 0),
    CHECK (average_los_days > 0),
    CHECK (extra_daily_charge >= 0)
);

CREATE TABLE hospitalization (
    hospitalization_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    department_id INT NOT NULL,
    bed_id INT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE,
    admission_icd10_code VARCHAR(20) NOT NULL,
    discharge_icd10_code VARCHAR(20),
    ken_code VARCHAR(20) NOT NULL,
    base_cost DECIMAL(10,2) NOT NULL,
    extra_charge DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_cost DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (bed_id) REFERENCES bed(bed_id),
    FOREIGN KEY (admission_icd10_code) REFERENCES icd10_diagnosis(icd10_code),
    FOREIGN KEY (discharge_icd10_code) REFERENCES icd10_diagnosis(icd10_code),
    FOREIGN KEY (ken_code) REFERENCES ken_code(ken_code),
    CHECK (base_cost >= 0),
    CHECK (extra_charge >= 0),
    CHECK (total_cost >= 0),
    CHECK (discharge_date IS NULL OR discharge_date >= admission_date)
);

CREATE TABLE triage_case (
    triage_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    triage_nurse_id INT NOT NULL,
    arrival_time DATETIME NOT NULL,
    service_time DATETIME,
    symptoms TEXT NOT NULL,
    urgency_level INT NOT NULL,
    outcome VARCHAR(50) NOT NULL,
    referred_department_id INT,
    hospitalization_id INT,
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (triage_nurse_id) REFERENCES nurse(staff_id),
    FOREIGN KEY (referred_department_id) REFERENCES department(department_id),
    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    UNIQUE (hospitalization_id),
    CHECK (urgency_level BETWEEN 1 AND 5),
    CHECK (service_time IS NULL OR service_time >= arrival_time),
    CHECK (outcome IN ('οδηγίες και αποχώρηση', 'παραπομπή για νοσηλεία'))
);

CREATE TABLE shift (
    shift_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    shift_date DATE NOT NULL,
    shift_type VARCHAR(20) NOT NULL,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    is_finalized BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    UNIQUE (department_id, shift_date, shift_type),
    CHECK (shift_type IN ('πρωινή', 'απογευματινή', 'νυχτερινή')),
    CHECK (end_datetime > start_datetime)
);

CREATE TABLE shift_assignment (
    shift_id INT NOT NULL,
    staff_id INT NOT NULL,
    PRIMARY KEY (shift_id, staff_id),
    FOREIGN KEY (shift_id) REFERENCES shift(shift_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE lab_test (
    lab_test_id INT AUTO_INCREMENT PRIMARY KEY,
    hospitalization_id INT NOT NULL,
    test_code VARCHAR(50) NOT NULL,
    test_type VARCHAR(100) NOT NULL,
    test_date DATETIME NOT NULL,
    result_text TEXT,
    result_value DECIMAL(10,2),
    result_unit VARCHAR(50),
    cost DECIMAL(10,2) NOT NULL,
    ordering_doctor_id INT NOT NULL,
    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    FOREIGN KEY (ordering_doctor_id) REFERENCES doctor(staff_id),
    CHECK (cost >= 0)
);

CREATE TABLE medical_procedure (
    procedure_code VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    duration_minutes INT NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    required_room_type VARCHAR(100) NOT NULL,
    CHECK (duration_minutes > 0),
    CHECK (cost >= 0),
    CHECK (category IN ('χειρουργική', 'διαγνωστική', 'θεραπευτική'))
);

CREATE TABLE procedure_room (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    room_type VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);

CREATE TABLE performed_procedure (
    performed_id INT AUTO_INCREMENT PRIMARY KEY,
    hospitalization_id INT NOT NULL,
    procedure_code VARCHAR(50) NOT NULL,
    room_id INT NOT NULL,
    main_surgeon_id INT NOT NULL,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    FOREIGN KEY (procedure_code) REFERENCES medical_procedure(procedure_code),
    FOREIGN KEY (room_id) REFERENCES procedure_room(room_id),
    FOREIGN KEY (main_surgeon_id) REFERENCES doctor(staff_id),
    CHECK (end_datetime > start_datetime),
    CHECK (cost >= 0)
);

CREATE TABLE procedure_participant (
    performed_id INT NOT NULL,
    staff_id INT NOT NULL,
    role VARCHAR(100) NOT NULL,
    PRIMARY KEY (performed_id, staff_id),
    FOREIGN KEY (performed_id) REFERENCES performed_procedure(performed_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE medication (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    ema_product_code VARCHAR(100),
    product_name VARCHAR(255) NOT NULL,
    form VARCHAR(100),
    authorization_holder VARCHAR(255)
);

CREATE TABLE active_substance (
    substance_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE medication_substance (
    medication_id INT NOT NULL,
    substance_id INT NOT NULL,
    PRIMARY KEY (medication_id, substance_id),
    FOREIGN KEY (medication_id) REFERENCES medication(medication_id),
    FOREIGN KEY (substance_id) REFERENCES active_substance(substance_id)
);

CREATE TABLE patient_allergy (
    patient_id INT NOT NULL,
    substance_id INT NOT NULL,
    PRIMARY KEY (patient_id, substance_id),
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (substance_id) REFERENCES active_substance(substance_id)
);

CREATE TABLE prescription (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    patient_id INT NOT NULL,
    hospitalization_id INT NOT NULL,
    medication_id INT NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    FOREIGN KEY (doctor_id) REFERENCES doctor(staff_id),
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    FOREIGN KEY (medication_id) REFERENCES medication(medication_id),
    UNIQUE (doctor_id, patient_id, medication_id, start_date),
    CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE hospitalization_review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    hospitalization_id INT NOT NULL UNIQUE,
    medical_care INT NOT NULL,
    nursing_care INT NOT NULL,
    cleanliness INT NOT NULL,
    food INT NOT NULL,
    overall_experience INT NOT NULL,
    review_date DATE NOT NULL,
    comments TEXT,
    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    CHECK (medical_care BETWEEN 1 AND 5),
    CHECK (nursing_care BETWEEN 1 AND 5),
    CHECK (cleanliness BETWEEN 1 AND 5),
    CHECK (food BETWEEN 1 AND 5),
    CHECK (overall_experience BETWEEN 1 AND 5)
);

CREATE TABLE doctor_review (
    doctor_review_id INT AUTO_INCREMENT PRIMARY KEY,
    hospitalization_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medical_care INT NOT NULL,
    review_date DATE NOT NULL,
    comments TEXT,
    FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    FOREIGN KEY (doctor_id) REFERENCES doctor(staff_id),
    UNIQUE (hospitalization_id, doctor_id),
    CHECK (medical_care BETWEEN 1 AND 5)
);

CREATE TABLE entity_image (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type VARCHAR(100) NOT NULL,
    entity_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    description TEXT
);

CREATE INDEX idx_patient_insurance_provider_id
ON patient(insurance_provider_id);

CREATE INDEX idx_hospitalization_patient 
ON hospitalization(patient_id);

CREATE INDEX idx_hospitalization_department_date 
ON hospitalization(department_id, admission_date);

CREATE INDEX idx_doctor_specialty 
ON doctor(specialty);

CREATE INDEX idx_shift_department_date 
ON shift(department_id, shift_date);

CREATE INDEX idx_shift_assignment_staff 
ON shift_assignment(staff_id);

CREATE INDEX idx_performed_main_surgeon 
ON performed_procedure(main_surgeon_id);

CREATE INDEX idx_performed_hospitalization 
ON performed_procedure(hospitalization_id);

CREATE INDEX idx_prescription_patient_hosp 
ON prescription(patient_id, hospitalization_id);

CREATE INDEX idx_hospitalization_review_hosp 
ON hospitalization_review(hospitalization_id);

CREATE INDEX idx_doctor_review_doctor 
ON doctor_review(doctor_id);

CREATE INDEX idx_doctor_review_hosp 
ON doctor_review(hospitalization_id);

CREATE INDEX idx_triage_urgency_arrival 
ON triage_case(urgency_level, arrival_time);

-- =====================================================
-- AUTOMATIC BUSINESS RULES / TRIGGERS
-- Strict implementation of the complex constraints required
-- by the assignment. These rules cannot be fully expressed
-- with simple CHECK / FK constraints.
-- =====================================================

DELIMITER $$

-- -----------------------------------------------------
-- 1. Doctor supervision rules
-- - no self-supervision
-- - no cyclic supervision chain
-- - residents must be supervised by Επιμελητής Α or Διευθυντής
-- -----------------------------------------------------
CREATE TRIGGER trg_doctor_no_supervision_cycle_bi
BEFORE INSERT ON doctor
FOR EACH ROW
BEGIN
    DECLARE v_current_supervisor INT;
    DECLARE v_next_supervisor INT;
    DECLARE v_depth INT DEFAULT 0;
    DECLARE v_supervisor_rank VARCHAR(50);

    IF NEW.supervisor_id IS NOT NULL AND NEW.supervisor_id = NEW.staff_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid supervision: doctor cannot supervise himself/herself';
    END IF;

    IF NEW.doctor_rank = 'Ειδικευόμενος' THEN
        SELECT doctor_rank
        INTO v_supervisor_rank
        FROM doctor
        WHERE staff_id = NEW.supervisor_id;

        IF v_supervisor_rank NOT IN ('Επιμελητής Α', 'Διευθυντής') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid supervision: resident must be supervised by Επιμελητής Α or Διευθυντής';
        END IF;
    END IF;

    SET v_current_supervisor = NEW.supervisor_id;
    WHILE v_current_supervisor IS NOT NULL AND v_depth < 50 DO
        IF v_current_supervisor = NEW.staff_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid supervision: cyclic supervision is not allowed';
        END IF;

        SELECT supervisor_id
        INTO v_next_supervisor
        FROM doctor
        WHERE staff_id = v_current_supervisor;

        SET v_current_supervisor = v_next_supervisor;
        SET v_depth = v_depth + 1;
    END WHILE;
END$$

CREATE TRIGGER trg_doctor_no_supervision_cycle_bu
BEFORE UPDATE ON doctor
FOR EACH ROW
BEGIN
    DECLARE v_current_supervisor INT;
    DECLARE v_next_supervisor INT;
    DECLARE v_depth INT DEFAULT 0;
    DECLARE v_supervisor_rank VARCHAR(50);

    IF NEW.supervisor_id IS NOT NULL AND NEW.supervisor_id = NEW.staff_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid supervision: doctor cannot supervise himself/herself';
    END IF;

    IF NEW.doctor_rank NOT IN ('Επιμελητής Α', 'Διευθυντής')
       AND EXISTS (
           SELECT 1
           FROM doctor supervised
           WHERE supervised.supervisor_id = NEW.staff_id
             AND supervised.doctor_rank = 'Ειδικευόμενος'
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid supervision: a resident supervisor must remain Επιμελητής Α or Διευθυντής';
    END IF;

    IF NEW.doctor_rank = 'Ειδικευόμενος' THEN
        SELECT doctor_rank
        INTO v_supervisor_rank
        FROM doctor
        WHERE staff_id = NEW.supervisor_id;

        IF v_supervisor_rank NOT IN ('Επιμελητής Α', 'Διευθυντής') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid supervision: resident must be supervised by Επιμελητής Α or Διευθυντής';
        END IF;
    END IF;

    SET v_current_supervisor = NEW.supervisor_id;
    WHILE v_current_supervisor IS NOT NULL AND v_depth < 50 DO
        IF v_current_supervisor = NEW.staff_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid supervision: cyclic supervision is not allowed';
        END IF;

        SELECT supervisor_id
        INTO v_next_supervisor
        FROM doctor
        WHERE staff_id = v_current_supervisor;

        SET v_current_supervisor = v_next_supervisor;
        SET v_depth = v_depth + 1;
    END WHILE;
END$$

-- -----------------------------------------------------
-- 2. Hospitalization rules
-- - bed must belong to the hospitalization department
-- - no overlapping hospitalizations on the same bed
-- - cost is automatically derived from KEN and length of stay
-- -----------------------------------------------------
CREATE TRIGGER trg_hospitalization_cost_bi
BEFORE INSERT ON hospitalization
FOR EACH ROW
BEGIN
    DECLARE v_base_cost DECIMAL(10,2);
    DECLARE v_average_los_days INT;
    DECLARE v_extra_daily_charge DECIMAL(10,2);
    DECLARE v_los INT;

    IF NOT EXISTS (
        SELECT 1
        FROM bed b
        WHERE b.bed_id = NEW.bed_id
          AND b.department_id = NEW.department_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid hospitalization: bed must belong to the hospitalization department';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM hospitalization h
        WHERE h.bed_id = NEW.bed_id
          AND NEW.admission_date <= COALESCE(h.discharge_date, '9999-12-31')
          AND COALESCE(NEW.discharge_date, '9999-12-31') >= h.admission_date
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid hospitalization: overlapping hospitalization on the same bed';
    END IF;

    SELECT base_cost, average_los_days, extra_daily_charge
    INTO v_base_cost, v_average_los_days, v_extra_daily_charge
    FROM ken_code
    WHERE ken_code = NEW.ken_code;

    SET v_los = GREATEST(DATEDIFF(COALESCE(NEW.discharge_date, NEW.admission_date), NEW.admission_date), 0);
    SET NEW.base_cost = v_base_cost;
    SET NEW.extra_charge = GREATEST(v_los - v_average_los_days, 0) * v_extra_daily_charge;
    SET NEW.total_cost = NEW.base_cost + NEW.extra_charge;
END$$

CREATE TRIGGER trg_hospitalization_cost_bu
BEFORE UPDATE ON hospitalization
FOR EACH ROW
BEGIN
    DECLARE v_base_cost DECIMAL(10,2);
    DECLARE v_average_los_days INT;
    DECLARE v_extra_daily_charge DECIMAL(10,2);
    DECLARE v_los INT;

    IF NOT EXISTS (
        SELECT 1
        FROM bed b
        WHERE b.bed_id = NEW.bed_id
          AND b.department_id = NEW.department_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid hospitalization: bed must belong to the hospitalization department';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM hospitalization h
        WHERE h.hospitalization_id <> OLD.hospitalization_id
          AND h.bed_id = NEW.bed_id
          AND NEW.admission_date <= COALESCE(h.discharge_date, '9999-12-31')
          AND COALESCE(NEW.discharge_date, '9999-12-31') >= h.admission_date
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid hospitalization: overlapping hospitalization on the same bed';
    END IF;

    SELECT base_cost, average_los_days, extra_daily_charge
    INTO v_base_cost, v_average_los_days, v_extra_daily_charge
    FROM ken_code
    WHERE ken_code = NEW.ken_code;

    SET v_los = GREATEST(DATEDIFF(COALESCE(NEW.discharge_date, NEW.admission_date), NEW.admission_date), 0);
    SET NEW.base_cost = v_base_cost;
    SET NEW.extra_charge = GREATEST(v_los - v_average_los_days, 0) * v_extra_daily_charge;
    SET NEW.total_cost = NEW.base_cost + NEW.extra_charge;
END$$

CREATE TRIGGER trg_hospitalization_bed_status_ai
AFTER INSERT ON hospitalization
FOR EACH ROW
BEGIN
    IF NEW.discharge_date IS NULL THEN
        UPDATE bed
        SET status = 'κατειλημμένη'
        WHERE bed_id = NEW.bed_id;
    END IF;
END$$

CREATE TRIGGER trg_hospitalization_bed_status_au
AFTER UPDATE ON hospitalization
FOR EACH ROW
BEGIN
    IF NEW.discharge_date IS NULL THEN
        UPDATE bed
        SET status = 'κατειλημμένη'
        WHERE bed_id = NEW.bed_id;
    ELSEIF OLD.discharge_date IS NULL AND NEW.discharge_date IS NOT NULL THEN
        UPDATE bed
        SET status = 'διαθέσιμη'
        WHERE bed_id = NEW.bed_id
          AND NOT EXISTS (
              SELECT 1
              FROM hospitalization h
              WHERE h.bed_id = NEW.bed_id
                AND h.discharge_date IS NULL
          );
    END IF;
END$$

-- -----------------------------------------------------
-- 3. Prescription rules
-- - prescription patient must match hospitalization patient
-- - prescription dates must be inside hospitalization period
-- - no medication can be prescribed if it contains an active
--   substance to which the patient is allergic
-- -----------------------------------------------------
CREATE TRIGGER trg_prescription_validate_bi
BEFORE INSERT ON prescription
FOR EACH ROW
BEGIN
    DECLARE v_hosp_patient_id INT;
    DECLARE v_admission_date DATE;
    DECLARE v_discharge_date DATE;

    SELECT patient_id, admission_date, discharge_date
    INTO v_hosp_patient_id, v_admission_date, v_discharge_date
    FROM hospitalization
    WHERE hospitalization_id = NEW.hospitalization_id;

    IF v_hosp_patient_id <> NEW.patient_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid prescription: patient_id does not match hospitalization patient_id';
    END IF;

    IF NEW.start_date < v_admission_date
       OR (v_discharge_date IS NOT NULL AND NEW.start_date > v_discharge_date)
       OR (NEW.end_date IS NOT NULL AND NEW.end_date < v_admission_date)
       OR (v_discharge_date IS NOT NULL AND NEW.end_date IS NOT NULL AND NEW.end_date > v_discharge_date) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid prescription: prescription dates must be inside hospitalization period';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM medication_substance ms
        JOIN patient_allergy pa
            ON pa.substance_id = ms.substance_id
        WHERE ms.medication_id = NEW.medication_id
          AND pa.patient_id = NEW.patient_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid prescription: patient is allergic to an active substance of the medication';
    END IF;
END$$

CREATE TRIGGER trg_prescription_validate_bu
BEFORE UPDATE ON prescription
FOR EACH ROW
BEGIN
    DECLARE v_hosp_patient_id INT;
    DECLARE v_admission_date DATE;
    DECLARE v_discharge_date DATE;

    SELECT patient_id, admission_date, discharge_date
    INTO v_hosp_patient_id, v_admission_date, v_discharge_date
    FROM hospitalization
    WHERE hospitalization_id = NEW.hospitalization_id;

    IF v_hosp_patient_id <> NEW.patient_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid prescription: patient_id does not match hospitalization patient_id';
    END IF;

    IF NEW.start_date < v_admission_date
       OR (v_discharge_date IS NOT NULL AND NEW.start_date > v_discharge_date)
       OR (NEW.end_date IS NOT NULL AND NEW.end_date < v_admission_date)
       OR (v_discharge_date IS NOT NULL AND NEW.end_date IS NOT NULL AND NEW.end_date > v_discharge_date) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid prescription: prescription dates must be inside hospitalization period';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM medication_substance ms
        JOIN patient_allergy pa
            ON pa.substance_id = ms.substance_id
        WHERE ms.medication_id = NEW.medication_id
          AND pa.patient_id = NEW.patient_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid prescription: patient is allergic to an active substance of the medication';
    END IF;
END$$

-- -----------------------------------------------------
-- 4. Review rules
-- - reviews are allowed only for completed hospitalizations
-- - doctor_review is allowed only for a doctor who prescribed
--   medication during the specific hospitalization
-- -----------------------------------------------------
CREATE TRIGGER trg_hospitalization_review_validate_bi
BEFORE INSERT ON hospitalization_review
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM hospitalization h
        WHERE h.hospitalization_id = NEW.hospitalization_id
          AND h.discharge_date IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid hospitalization review: review is allowed only after discharge';
    END IF;
END$$

CREATE TRIGGER trg_hospitalization_review_validate_bu
BEFORE UPDATE ON hospitalization_review
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM hospitalization h
        WHERE h.hospitalization_id = NEW.hospitalization_id
          AND h.discharge_date IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid hospitalization review: review is allowed only after discharge';
    END IF;
END$$

CREATE TRIGGER trg_doctor_review_validate_bi
BEFORE INSERT ON doctor_review
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM hospitalization h
        WHERE h.hospitalization_id = NEW.hospitalization_id
          AND h.discharge_date IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid doctor review: review is allowed only after discharge';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM prescription p
        WHERE p.hospitalization_id = NEW.hospitalization_id
          AND p.doctor_id = NEW.doctor_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid doctor review: reviewed doctor must have prescribed during this hospitalization';
    END IF;
END$$

CREATE TRIGGER trg_doctor_review_validate_bu
BEFORE UPDATE ON doctor_review
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM hospitalization h
        WHERE h.hospitalization_id = NEW.hospitalization_id
          AND h.discharge_date IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid doctor review: review is allowed only after discharge';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM prescription p
        WHERE p.hospitalization_id = NEW.hospitalization_id
          AND p.doctor_id = NEW.doctor_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid doctor review: reviewed doctor must have prescribed during this hospitalization';
    END IF;
END$$

-- -----------------------------------------------------
-- 5. Performed procedure rules
-- - no overlapping procedures in the same room
-- - no doctor can be main surgeon or participant in overlapping procedures
-- -----------------------------------------------------
CREATE TRIGGER trg_performed_procedure_validate_bi
BEFORE INSERT ON performed_procedure
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM performed_procedure pp
        WHERE pp.room_id = NEW.room_id
          AND NEW.start_datetime < pp.end_datetime
          AND NEW.end_datetime > pp.start_datetime
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid performed procedure: room has an overlapping procedure';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM performed_procedure pp
        WHERE pp.main_surgeon_id = NEW.main_surgeon_id
          AND NEW.start_datetime < pp.end_datetime
          AND NEW.end_datetime > pp.start_datetime
    ) OR EXISTS (
        SELECT 1
        FROM procedure_participant part
        JOIN performed_procedure pp
            ON pp.performed_id = part.performed_id
        JOIN staff st
            ON st.staff_id = part.staff_id
        WHERE part.staff_id = NEW.main_surgeon_id
          AND st.staff_type = 'DOCTOR'
          AND NEW.start_datetime < pp.end_datetime
          AND NEW.end_datetime > pp.start_datetime
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid performed procedure: doctor has an overlapping procedure';
    END IF;
END$$

CREATE TRIGGER trg_performed_procedure_validate_bu
BEFORE UPDATE ON performed_procedure
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM performed_procedure pp
        WHERE pp.performed_id <> OLD.performed_id
          AND pp.room_id = NEW.room_id
          AND NEW.start_datetime < pp.end_datetime
          AND NEW.end_datetime > pp.start_datetime
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid performed procedure: room has an overlapping procedure';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM performed_procedure pp
        WHERE pp.performed_id <> OLD.performed_id
          AND pp.main_surgeon_id = NEW.main_surgeon_id
          AND NEW.start_datetime < pp.end_datetime
          AND NEW.end_datetime > pp.start_datetime
    ) OR EXISTS (
        SELECT 1
        FROM procedure_participant part
        JOIN performed_procedure pp
            ON pp.performed_id = part.performed_id
        JOIN staff st
            ON st.staff_id = part.staff_id
        WHERE pp.performed_id <> OLD.performed_id
          AND part.staff_id = NEW.main_surgeon_id
          AND st.staff_type = 'DOCTOR'
          AND NEW.start_datetime < pp.end_datetime
          AND NEW.end_datetime > pp.start_datetime
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid performed procedure: doctor has an overlapping procedure';
    END IF;
END$$

-- -----------------------------------------------------
-- 6. Procedure participant rules
-- - only doctors and nurses can participate in procedures
-- - main surgeon cannot also be inserted as participant
-- - doctors cannot participate in overlapping procedures
-- -----------------------------------------------------
CREATE TRIGGER trg_procedure_participant_rules_bi
BEFORE INSERT ON procedure_participant
FOR EACH ROW
BEGIN
    DECLARE v_staff_type VARCHAR(20);
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;
    DECLARE v_main_surgeon INT;

    SELECT staff_type
    INTO v_staff_type
    FROM staff
    WHERE staff_id = NEW.staff_id;

    IF v_staff_type NOT IN ('DOCTOR', 'NURSE') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid procedure participant: only doctors and nurses may participate';
    END IF;

    SELECT start_datetime, end_datetime, main_surgeon_id
    INTO v_start, v_end, v_main_surgeon
    FROM performed_procedure
    WHERE performed_id = NEW.performed_id;

    IF NEW.staff_id = v_main_surgeon THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid procedure participant: main surgeon cannot also be participant';
    END IF;

    IF v_staff_type = 'DOCTOR' AND (
        EXISTS (
            SELECT 1
            FROM performed_procedure pp
            WHERE pp.performed_id <> NEW.performed_id
              AND pp.main_surgeon_id = NEW.staff_id
              AND v_start < pp.end_datetime
              AND v_end > pp.start_datetime
        ) OR EXISTS (
            SELECT 1
            FROM procedure_participant part
            JOIN performed_procedure pp
                ON pp.performed_id = part.performed_id
            WHERE pp.performed_id <> NEW.performed_id
              AND part.staff_id = NEW.staff_id
              AND v_start < pp.end_datetime
              AND v_end > pp.start_datetime
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid procedure participant: doctor has an overlapping procedure';
    END IF;
END$$

CREATE TRIGGER trg_procedure_participant_rules_bu
BEFORE UPDATE ON procedure_participant
FOR EACH ROW
BEGIN
    DECLARE v_staff_type VARCHAR(20);
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;
    DECLARE v_main_surgeon INT;

    SELECT staff_type
    INTO v_staff_type
    FROM staff
    WHERE staff_id = NEW.staff_id;

    IF v_staff_type NOT IN ('DOCTOR', 'NURSE') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid procedure participant: only doctors and nurses may participate';
    END IF;

    SELECT start_datetime, end_datetime, main_surgeon_id
    INTO v_start, v_end, v_main_surgeon
    FROM performed_procedure
    WHERE performed_id = NEW.performed_id;

    IF NEW.staff_id = v_main_surgeon THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid procedure participant: main surgeon cannot also be participant';
    END IF;

    IF v_staff_type = 'DOCTOR' AND (
        EXISTS (
            SELECT 1
            FROM performed_procedure pp
            WHERE pp.performed_id <> NEW.performed_id
              AND pp.main_surgeon_id = NEW.staff_id
              AND v_start < pp.end_datetime
              AND v_end > pp.start_datetime
        ) OR EXISTS (
            SELECT 1
            FROM procedure_participant part
            JOIN performed_procedure pp
                ON pp.performed_id = part.performed_id
            WHERE pp.performed_id <> NEW.performed_id
              AND part.staff_id = NEW.staff_id
              AND v_start < pp.end_datetime
              AND v_end > pp.start_datetime
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid procedure participant: doctor has an overlapping procedure';
    END IF;
END$$

-- -----------------------------------------------------
-- 7. Shift assignment rules
-- - no overlapping shifts / less than 8 hours rest for the same staff member
-- - maximum monthly shifts: doctor 15, nurse 20, admin 25
-- - no more than 3 consecutive night shifts
-- -----------------------------------------------------
CREATE TRIGGER trg_shift_assignment_validate_bi
BEFORE INSERT ON shift_assignment
FOR EACH ROW
BEGIN
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;
    DECLARE v_shift_date DATE;
    DECLARE v_shift_type VARCHAR(20);
    DECLARE v_staff_type VARCHAR(20);
    DECLARE v_monthly_count INT;
    DECLARE v_max_monthly INT;

    SELECT start_datetime, end_datetime, shift_date, shift_type
    INTO v_start, v_end, v_shift_date, v_shift_type
    FROM shift
    WHERE shift_id = NEW.shift_id;

    SELECT staff_type
    INTO v_staff_type
    FROM staff
    WHERE staff_id = NEW.staff_id;

    SET v_max_monthly = CASE v_staff_type
        WHEN 'DOCTOR' THEN 15
        WHEN 'NURSE' THEN 20
        WHEN 'ADMIN' THEN 25
        ELSE 0
    END;

    IF EXISTS (
        SELECT 1
        FROM shift_assignment sa
        JOIN shift sh ON sh.shift_id = sa.shift_id
        WHERE sa.staff_id = NEW.staff_id
          AND NOT (
              sh.end_datetime <= DATE_SUB(v_start, INTERVAL 8 HOUR)
              OR sh.start_datetime >= DATE_ADD(v_end, INTERVAL 8 HOUR)
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid shift assignment: staff member must have at least 8 hours rest between shifts';
    END IF;

    SELECT COUNT(*)
    INTO v_monthly_count
    FROM shift_assignment sa
    JOIN shift sh ON sh.shift_id = sa.shift_id
    WHERE sa.staff_id = NEW.staff_id
      AND YEAR(sh.shift_date) = YEAR(v_shift_date)
      AND MONTH(sh.shift_date) = MONTH(v_shift_date);

    IF v_monthly_count >= v_max_monthly THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid shift assignment: maximum monthly shifts exceeded';
    END IF;

    IF v_shift_type = 'νυχτερινή' THEN
        IF EXISTS (
            SELECT 1
            FROM (
                SELECT DATE_SUB(v_shift_date, INTERVAL 3 DAY) AS window_start
                UNION ALL SELECT DATE_SUB(v_shift_date, INTERVAL 2 DAY)
                UNION ALL SELECT DATE_SUB(v_shift_date, INTERVAL 1 DAY)
                UNION ALL SELECT v_shift_date
            ) w
            WHERE (
                SELECT COUNT(DISTINCT nd.shift_date)
                FROM (
                    SELECT sh.shift_date
                    FROM shift_assignment sa
                    JOIN shift sh ON sh.shift_id = sa.shift_id
                    WHERE sa.staff_id = NEW.staff_id
                      AND sh.shift_type = 'νυχτερινή'
                    UNION ALL
                    SELECT v_shift_date
                ) nd
                WHERE nd.shift_date BETWEEN w.window_start AND DATE_ADD(w.window_start, INTERVAL 3 DAY)
            ) >= 4
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid shift assignment: more than 3 consecutive night shifts are not allowed';
        END IF;
    END IF;
END$$

-- -----------------------------------------------------
-- 8. Validation procedure for aggregate shift requirements.
-- This should be called after loading/generating shift assignments.
-- It checks minimum staffing per shift and senior doctor coverage
-- when a trainee doctor is assigned.
-- -----------------------------------------------------
CREATE PROCEDURE validate_shift_requirements()
BEGIN
    IF EXISTS (
        SELECT 1
        FROM shift sh
        LEFT JOIN shift_assignment sa ON sa.shift_id = sh.shift_id
        LEFT JOIN staff st ON st.staff_id = sa.staff_id
        GROUP BY sh.shift_id
        HAVING SUM(CASE WHEN st.staff_type = 'DOCTOR' THEN 1 ELSE 0 END) < 3
            OR SUM(CASE WHEN st.staff_type = 'NURSE' THEN 1 ELSE 0 END) < 6
            OR SUM(CASE WHEN st.staff_type = 'ADMIN' THEN 1 ELSE 0 END) < 2
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid shift schedule: minimum staffing requirement is not satisfied';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM shift sh
        JOIN shift_assignment sa ON sa.shift_id = sh.shift_id
        JOIN doctor d ON d.staff_id = sa.staff_id
        GROUP BY sh.shift_id
        HAVING SUM(CASE WHEN d.doctor_rank = 'Ειδικευόμενος' THEN 1 ELSE 0 END) > 0
           AND SUM(CASE WHEN d.doctor_rank IN ('Επιμελητής Α', 'Διευθυντής') THEN 1 ELSE 0 END) = 0
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid shift schedule: trainee doctor requires Επιμελητής Α or Διευθυντής in the same shift';
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- 9. Hybrid hardening additions
-- - finalized shifts enforce aggregate staffing automatically
-- - finalized shifts cannot be made understaffed by deletes
-- - allergies cannot be added after the fact if they conflict
--   with existing prescriptions
-- -----------------------------------------------------
DELIMITER $$

CREATE TRIGGER trg_shift_staffing_finalize_bu
BEFORE UPDATE ON shift
FOR EACH ROW
BEGIN
    DECLARE v_doctors INT DEFAULT 0;
    DECLARE v_nurses INT DEFAULT 0;
    DECLARE v_admins INT DEFAULT 0;
    DECLARE v_residents INT DEFAULT 0;
    DECLARE v_seniors INT DEFAULT 0;

    IF NEW.is_finalized = TRUE THEN
        SELECT
            SUM(CASE WHEN st.staff_type = 'DOCTOR' THEN 1 ELSE 0 END),
            SUM(CASE WHEN st.staff_type = 'NURSE' THEN 1 ELSE 0 END),
            SUM(CASE WHEN st.staff_type = 'ADMIN' THEN 1 ELSE 0 END),
            SUM(CASE WHEN d.doctor_rank = 'Ειδικευόμενος' THEN 1 ELSE 0 END),
            SUM(CASE WHEN d.doctor_rank IN ('Επιμελητής Α', 'Διευθυντής') THEN 1 ELSE 0 END)
        INTO v_doctors, v_nurses, v_admins, v_residents, v_seniors
        FROM shift_assignment sa
        JOIN staff st ON st.staff_id = sa.staff_id
        LEFT JOIN doctor d ON d.staff_id = st.staff_id
        WHERE sa.shift_id = NEW.shift_id;

        IF COALESCE(v_doctors, 0) < 3 OR COALESCE(v_nurses, 0) < 6 OR COALESCE(v_admins, 0) < 2 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid finalized shift: minimum staffing requirement is not satisfied';
        END IF;

        IF COALESCE(v_residents, 0) > 0 AND COALESCE(v_seniors, 0) = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid finalized shift: resident doctor requires senior doctor coverage';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_shift_assignment_no_understaff_delete_bd
BEFORE DELETE ON shift_assignment
FOR EACH ROW
BEGIN
    DECLARE v_finalized BOOLEAN DEFAULT FALSE;
    DECLARE v_staff_type VARCHAR(20);
    DECLARE v_doctor_rank VARCHAR(50);
    DECLARE v_count_after INT DEFAULT 0;
    DECLARE v_residents_after INT DEFAULT 0;
    DECLARE v_seniors_after INT DEFAULT 0;

    SELECT is_finalized INTO v_finalized
    FROM shift
    WHERE shift_id = OLD.shift_id;

    IF v_finalized THEN
        SELECT staff_type INTO v_staff_type
        FROM staff
        WHERE staff_id = OLD.staff_id;

        SELECT COUNT(*) INTO v_count_after
        FROM shift_assignment sa
        JOIN staff st ON st.staff_id = sa.staff_id
        WHERE sa.shift_id = OLD.shift_id
          AND sa.staff_id <> OLD.staff_id
          AND st.staff_type = v_staff_type;

        IF (v_staff_type = 'DOCTOR' AND v_count_after < 3)
           OR (v_staff_type = 'NURSE' AND v_count_after < 6)
           OR (v_staff_type = 'ADMIN' AND v_count_after < 2) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid delete: finalized shift would become understaffed';
        END IF;

        IF v_staff_type = 'DOCTOR' THEN
            SELECT doctor_rank INTO v_doctor_rank
            FROM doctor
            WHERE staff_id = OLD.staff_id;

            IF v_doctor_rank IN ('Επιμελητής Α', 'Διευθυντής') THEN
                SELECT
                    SUM(CASE WHEN d.doctor_rank = 'Ειδικευόμενος' THEN 1 ELSE 0 END),
                    SUM(CASE WHEN d.doctor_rank IN ('Επιμελητής Α', 'Διευθυντής') THEN 1 ELSE 0 END)
                INTO v_residents_after, v_seniors_after
                FROM shift_assignment sa
                JOIN doctor d ON d.staff_id = sa.staff_id
                WHERE sa.shift_id = OLD.shift_id
                  AND sa.staff_id <> OLD.staff_id;

                IF COALESCE(v_residents_after, 0) > 0 AND COALESCE(v_seniors_after, 0) = 0 THEN
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Invalid delete: resident doctor would remain without senior coverage';
                END IF;
            END IF;
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_patient_allergy_no_existing_prescription_bi
BEFORE INSERT ON patient_allergy
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM prescription p
        JOIN medication_substance ms
            ON ms.medication_id = p.medication_id
        WHERE p.patient_id = NEW.patient_id
          AND ms.substance_id = NEW.substance_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid allergy: patient already has prescription with this active substance';
    END IF;
END$$

CREATE TRIGGER trg_patient_allergy_no_existing_prescription_bu
BEFORE UPDATE ON patient_allergy
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM prescription p
        JOIN medication_substance ms
            ON ms.medication_id = p.medication_id
        WHERE p.patient_id = NEW.patient_id
          AND ms.substance_id = NEW.substance_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid allergy: patient already has prescription with this active substance';
    END IF;
END$$

DELIMITER ;

