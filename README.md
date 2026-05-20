# Hospital Database Project

## Περιγραφή

Το repository υλοποιεί μια σχεσιακή βάση δεδομένων για πληροφοριακό σύστημα νοσοκομείου. Η βάση καλύπτει προσωπικό, ασθενείς, τμήματα, κλίνες, νοσηλείες, ICD-10 διαγνώσεις, ΚΕΝ, φάρμακα, δραστικές ουσίες, αλλεργίες, συνταγογραφήσεις, ιατρικές πράξεις, βάρδιες/εφημερίες, triage, εργαστηριακές εξετάσεις, αξιολογήσεις και εικόνες οντοτήτων.

Η τελική έκδοση περιλαμβάνει:

- κανονικοποιημένο ER και relational schema,
- εγκατάσταση μέσω `sql/install.sql`,
- φόρτωση δεδομένων μέσω `sql/load.sql`,
- 15 SQL ερωτήματα `Q01.sql` έως `Q15.sql`,
- output αρχεία για κάθε ερώτημα,
- ειδικά αρχεία `EXPLAIN`, `FORCE INDEX` και profiling για Q04 και Q06,
- triggers και procedures για σύνθετους περιορισμούς,
- τεκμηρίωση σε `docs/report.pdf`,
- προαιρετική web διεπαφή χρήστη σε PHP/PDO για επίδειξη των queries.

Η προαιρετική web εφαρμογή δεν αντικαθιστά τα υποχρεωτικά παραδοτέα. Χρησιμοποιείται μόνο ως βοηθητικό εργαλείο παρουσίασης.

---

## Δομή repository

```text
README.md

data/
  active_substance.csv
  icd10_diagnosis.csv
  ken_code.csv
  medical_procedure.csv
  medication.csv
  medication_substance.csv

diagrams/
  er.pdf
  relational.pdf

docs/
  report.pdf
  report.docx

sql/
  install.sql
  load.sql

  Q01.sql ... Q15.sql
  Q01_out.txt ... Q15_out.txt

  Q04_explain.sql
  Q04_force_index.sql
  Q04_force_index_explain.sql
  Q04_profile.sql
  Q04_analysis.txt
  Q04_explain_out.txt
  Q04_force_index_out.txt
  Q04_force_index_explain_out.txt
  Q04_profile_out.txt

  Q06_explain.sql
  Q06_force_index.sql
  Q06_force_index_explain.sql
  Q06_profile.sql
  Q06_analysis.txt
  Q06_explain_out.txt
  Q06_force_index_out.txt
  Q06_force_index_explain_out.txt
  Q06_profile_out.txt

code/
  hospital_db_web_ui/
    README_WEB_UI.md
    config.php
    index.php
    lib.php
    assets/
      style.css
    images/
      ...
    sql/
      Q01.sql ... Q15.sql
      load_department_images.sql
```

---

## Εκτέλεση σε Windows/XAMPP

Πριν την εκτέλεση ανοίγουμε το XAMPP Control Panel και ξεκινάμε:

```text
Apache
MySQL
```

Από Command Prompt στο root του project:

```cmd
cd /d "C:\Users\panzo\SEMESTER PROJECT\hospital_db_project"
```

Για σωστή εμφάνιση ελληνικών στο terminal:

```cmd
chcp 65001
```

---

## 1. Εγκατάσταση schema

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root < sql\install.sql
```

Το `install.sql` δημιουργεί τη βάση `hospital_db`, τους πίνακες, τα primary keys, foreign keys, unique constraints, check constraints, indexes, triggers και stored procedures.

---

## 2. Φόρτωση δεδομένων

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 --local-infile=1 -u root hospital_db < sql\load.sql
```

Το `load.sql` φορτώνει πρώτα τα reference CSV δεδομένα και στη συνέχεια δημιουργεί synthetic operational data για προσωπικό, ασθενείς, νοσηλείες, συνταγές, βάρδιες, triage, επεμβάσεις, εργαστηριακές εξετάσεις και αξιολογήσεις.

Στο τέλος εμφανίζει counts βασικών πινάκων, ώστε να επιβεβαιωθεί ότι η φόρτωση ολοκληρώθηκε σωστά.

---

## 3. Εκτέλεση Q01-Q15

```cmd
for %q in (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15) do @(echo ===== Running Q%q ===== & C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q%q.sql > sql\Q%q_out.txt || echo ERROR στο Q%q)
```

Έλεγχος output αρχείων:

```cmd
powershell -NoProfile -Command "1..15 | ForEach-Object { $q='Q{0:D2}' -f $_; $p='sql\' + $q + '_out.txt'; if(Test-Path $p){ $lines=(Get-Content $p | Measure-Object -Line).Lines; $bytes=(Get-Item $p).Length; $status=if($lines -gt 1){'OK'}else{'CHECK/EMPTY'}; '{0}: {1} lines, {2} bytes -> {3}' -f $q,$lines,$bytes,$status } else { '{0}: MISSING' -f $q } }"
```

---

## 4. Ειδικά αρχεία Q04 και Q06

Για τα Q04 και Q06 υπάρχουν επιπλέον αρχεία, επειδή ζητείται έλεγχος απόδοσης με:

- `EXPLAIN`,
- εναλλακτική έκδοση με `FORCE INDEX`,
- `EXPLAIN` της forced έκδοσης,
- πραγματικοί χρόνοι εκτέλεσης μέσω profiling.

### Q04

Κανονικό query:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q04.sql > sql\Q04_out.txt
```

EXPLAIN κανονικής έκδοσης:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q04_explain.sql > sql\Q04_explain_out.txt
```

Έκδοση με FORCE INDEX:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q04_force_index.sql > sql\Q04_force_index_out.txt
```

EXPLAIN έκδοσης με FORCE INDEX:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q04_force_index_explain.sql > sql\Q04_force_index_explain_out.txt
```

Profiling / πραγματικοί χρόνοι εκτέλεσης:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q04_profile.sql > sql\Q04_profile_out.txt
```

Τα output αρχεία του Q04 είναι:

```text
sql/Q04_out.txt
sql/Q04_explain_out.txt
sql/Q04_force_index_out.txt
sql/Q04_force_index_explain_out.txt
sql/Q04_profile_out.txt
```

### Q06

Κανονικό query:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q06.sql > sql\Q06_out.txt
```

EXPLAIN κανονικής έκδοσης:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q06_explain.sql > sql\Q06_explain_out.txt
```

Έκδοση με FORCE INDEX:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q06_force_index.sql > sql\Q06_force_index_out.txt
```

EXPLAIN έκδοσης με FORCE INDEX:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q06_force_index_explain.sql > sql\Q06_force_index_explain_out.txt
```

Profiling / πραγματικοί χρόνοι εκτέλεσης:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < sql\Q06_profile.sql > sql\Q06_profile_out.txt
```

Τα output αρχεία του Q06 είναι:

```text
sql/Q06_out.txt
sql/Q06_explain_out.txt
sql/Q06_force_index_out.txt
sql/Q06_force_index_explain_out.txt
sql/Q06_profile_out.txt
```

### Έλεγχος ειδικών outputs Q04/Q06

```cmd
powershell -NoProfile -Command "@('Q04_out.txt','Q04_explain_out.txt','Q04_force_index_out.txt','Q04_force_index_explain_out.txt','Q04_profile_out.txt','Q06_out.txt','Q06_explain_out.txt','Q06_force_index_out.txt','Q06_force_index_explain_out.txt','Q06_profile_out.txt') | ForEach-Object { $p='sql\' + $_; if(Test-Path $p){ $lines=(Get-Content $p | Measure-Object -Line).Lines; $bytes=(Get-Item $p).Length; $status=if($lines -gt 1){'OK'}else{'CHECK/EMPTY'}; '{0}: {1} lines, {2} bytes -> {3}' -f $_,$lines,$bytes,$status } else { '{0}: MISSING' -f $_ } }"
```

---

## Βασικό schema

### Προσωπικό

Η οντότητα `staff` κρατά τα κοινά στοιχεία προσωπικού. Οι πίνακες `doctor`, `nurse` και `administrative_staff` είναι εξειδικεύσεις του `staff` με σχέση ISA. Η υλοποίηση γίνεται με το `staff_id` ως primary key στους υποπίνακες και ταυτόχρονα foreign key προς `staff.staff_id`.

Ο πίνακας `doctor` περιλαμβάνει επίσης το `supervisor_id`, το οποίο είναι self-referencing foreign key προς `doctor.staff_id`. Με αυτόν τον τρόπο υλοποιείται η σχέση εποπτείας μεταξύ γιατρών.

### Ασθενείς και νοσηλείες

Οι ασθενείς αποθηκεύονται στον `patient`, οι ασφαλιστικοί φορείς στον `insurance_provider`, οι επαφές έκτακτης ανάγκης στον `emergency_contact`, και οι νοσηλείες στον `hospitalization`.

Η νοσηλεία συνδέεται με ασθενή, τμήμα, κλίνη, ICD-10 διάγνωση εισαγωγής, ICD-10 διάγνωση εξόδου, ΚΕΝ και κόστος νοσηλείας.

### ΚΕΝ, ICD-10, πράξεις και φάρμακα

Οι πίνακες `icd10_diagnosis`, `ken_code`, `medical_procedure`, `medication`, `active_substance` και `medication_substance` φορτώνονται από CSV reference data.

Η σχέση `medication_substance` είναι many-to-many, επειδή ένα φάρμακο μπορεί να έχει πολλές δραστικές ουσίες και μία δραστική ουσία μπορεί να εμφανίζεται σε πολλά φάρμακα.

### Βάρδιες / εφημερίες

Οι πίνακες `shift` και `shift_assignment` οργανώνουν τις βάρδιες/εφημερίες. Ο πίνακας `shift_assignment` είναι ενδιάμεσος πίνακας many-to-many ανάμεσα σε `shift` και `staff`.

Για τις ανάγκες της εργασίας, ο όρος `shift` χρησιμοποιείται ως γενικό μοντέλο για βάρδιες και εφημερίες. Κάθε βάρδια συνδέεται με τμήμα, ημερομηνία και τύπο βάρδιας.

Κάθε βάρδια πρέπει να έχει τουλάχιστον:

- 3 γιατρούς,
- 6 νοσηλευτές,
- 2 διοικητικούς υπαλλήλους.

Επιπλέον, όταν υπάρχει ειδικευόμενος σε βάρδια, πρέπει να υπάρχει και γιατρός βαθμίδας `Επιμελητής Α` ή `Διευθυντής`.

### Αξιολογήσεις

Ο πίνακας `hospitalization_review` κρατά τη γενική αξιολόγηση νοσηλείας με τα κριτήρια Likert της εκφώνησης:

- `medical_care`,
- `nursing_care`,
- `cleanliness`,
- `food`,
- `overall_experience`.

Ο πίνακας `doctor_review` κρατά αξιολόγηση συγκεκριμένου γιατρού για συγκεκριμένη νοσηλεία. Η σχεδίαση αυτή επιτρέπει να διακρίνουμε τη γενική εμπειρία νοσηλείας από την αξιολόγηση συγκεκριμένου γιατρού.

### Εικόνες

Ο πίνακας `entity_image` είναι polymorphic association. Το ζεύγος `entity_type` και `entity_id` μπορεί να αναφέρεται σε διαφορετικούς τύπους οντοτήτων, όπως department, doctor, patient, procedure_room και medication.

Για τον λόγο αυτό δεν υπάρχει απλό foreign key προς έναν μόνο πίνακα. Η επιλογή αυτή τεκμηριώνεται ως συνειδητή σχεδιαστική απόφαση.

---

## Σύνθετοι περιορισμοί

Το `install.sql` περιέχει triggers και procedures για περιορισμούς που δεν μπορούν να εκφραστούν πλήρως με απλά `CHECK` constraints:

- υπολογισμός `total_cost = base_cost + extra_charge` στη νοσηλεία,
- έλεγχος ότι η κλίνη της νοσηλείας ανήκει στο σωστό τμήμα,
- αποτροπή επικαλυπτόμενων ενεργών νοσηλειών στην ίδια κλίνη,
- ενημέρωση κατάστασης κλίνης μετά από εισαγωγή/ενημέρωση νοσηλείας,
- απαγόρευση συνταγογράφησης φαρμάκου όταν ο ασθενής έχει αλλεργία σε δραστική ουσία του,
- απαγόρευση προσθήκης αλλεργίας που συγκρούεται με υπάρχουσα συνταγή,
- αξιολόγηση νοσηλείας μόνο μετά την ολοκλήρωσή της,
- αξιολόγηση γιατρού μόνο αν ο γιατρός σχετίζεται με τη συγκεκριμένη νοσηλεία,
- απαγόρευση ταυτόχρονης χρήσης ίδιου procedure room από δύο επεμβάσεις,
- απαγόρευση ταυτόχρονης συμμετοχής ίδιου γιατρού σε δύο επεμβάσεις,
- έλεγχος ιεραρχίας και κυκλικής εποπτείας γιατρών,
- τουλάχιστον 8 ώρες ανάπαυση μεταξύ βαρδιών,
- μέγιστος αριθμός βαρδιών ανά μήνα,
- όχι πάνω από 3 συνεχόμενες νυχτερινές βάρδιες,
- έλεγχος minimum staffing ανά βάρδια,
- έλεγχος ύπαρξης senior doctor όταν υπάρχει ειδικευόμενος.

---

## Load data

Το `load.sql` φορτώνει πρώτα reference δεδομένα από CSV:

- ICD-10,
- ΚΕΝ,
- ιατρικές πράξεις,
- φάρμακα EMA,
- δραστικές ουσίες,
- συσχετίσεις φαρμάκων-δραστικών ουσιών.

Στη συνέχεια δημιουργεί synthetic operational data:

- 330 staff,
- 90 doctors,
- 180 nurses,
- 60 administrative staff,
- 15 departments,
- 300 beds,
- 200 patients,
- 500 hospitalizations,
- 350 triage cases,
- 315 shifts,
- 300 prescriptions,
- 150 performed procedures,
- 200 lab tests,
- 350 hospitalization reviews,
- περίπου 300 doctor reviews,
- 80 patient allergies.

Στο τέλος του `load.sql` υπάρχουν guarantee blocks ώστε ορισμένα queries να έχουν ελεγχόμενο μη κενό αποτέλεσμα.

---

## Περιγραφή Q01-Q15

| Query | Περιγραφή |
|---|---|
| Q01 | Οικονομική ανάλυση νοσηλειών ανά τμήμα, έτος, ΚΕΝ και ασφαλιστικό φορέα. |
| Q02 | Γιατροί ανά επιλεγμένη ειδικότητα, με ένδειξη εφημεριών/βαρδιών στο τρέχον έτος και αριθμό επεμβάσεων ως κύριοι χειρουργοί. |
| Q03 | Ασθενείς με πάνω από 3 νοσηλείες στο ίδιο τμήμα. |
| Q04 | Για συγκεκριμένο γιατρό: doctor medical care, hospitalization medical care και overall hospitalization experience. |
| Q05 | Νέοι γιατροί κάτω των 35 με τις περισσότερες χειρουργικές επεμβάσεις. |
| Q06 | Ιστορικό νοσηλειών συγκεκριμένου ασθενή με διαγνώσεις, κόστος και reviews. |
| Q07 | Για κάθε δραστική ουσία: αλλεργικοί ασθενείς και φάρμακα που την περιέχουν. |
| Q08 | Διαθεσιμότητα προσωπικού για συγκεκριμένο τμήμα και ημερομηνία. |
| Q09 | Ασθενείς με ίδιο συνολικό αριθμό ημερών νοσηλείας στο ίδιο έτος και συνολική διάρκεια άνω των 15 ημερών. |
| Q10 | Συχνότερα ζεύγη δραστικών ουσιών που χορηγούνται ταυτόχρονα, με έλεγχο χρονικής επικάλυψης συνταγογραφήσεων. |
| Q11 | Γιατροί με τουλάχιστον 5 λιγότερες επεμβάσεις από τον top doctor στο τρέχον έτος. |
| Q12 | Required vs assigned προσωπικό ανά τμήμα, βάρδια και εβδομάδα, με ανάλυση ανά υποκλάση χωρίς `GROUP_CONCAT`. |
| Q13 | Αναδρομική ιεραρχία εποπτείας γιατρών. |
| Q14 | ICD-10 categories με τουλάχιστον 5 εισαγωγές σε δύο συνεχόμενα έτη με ίδιο πλήθος. |
| Q15 | Triage analytics: urgency level, χρόνος αναμονής, ποσοστό νοσηλείας και παραπομπές ανά τμήμα. |

---

## Q04/Q06 optimization

Για τα Q04 και Q06 υπάρχουν normal query, `EXPLAIN`, `FORCE INDEX`, `FORCE INDEX EXPLAIN`, profile query και analysis text.

Η σύγκριση εκτιμώμενου κόστους γίνεται από τα πεδία του `EXPLAIN`, κυρίως `type`, `key`, `rows` και `Extra`. Η σύγκριση πραγματικού χρόνου γίνεται με `SHOW PROFILES`.

Μετρημένοι χρόνοι τελευταίας εκτέλεσης:

| Query | Normal execution | FORCE INDEX execution |
|---|---:|---:|
| Q04 | 0.00175340 sec | 0.00121880 sec |
| Q06 | 0.00317570 sec | 0.00176980 sec |

Η χρήση `FORCE INDEX` λειτουργεί κυρίως ως τεκμηρίωση/σύγκριση. Στο συγκεκριμένο dataset η force-index έκδοση βγήκε ελαφρώς ταχύτερη, επειδή πιέζει τη χρήση indexes που ταιριάζουν στα βασικά φίλτρα και joins των queries.

---

## Προαιρετική Web διεπαφή χρήστη

Στο repository περιλαμβάνεται προαιρετική web διεπαφή χρήστη στον φάκελο:

```text
code/hospital_db_web_ui
```

Η εφαρμογή υλοποιήθηκε με απλή PHP/PDO, χωρίς ORM ή framework. Δεν αντικαθιστά τα υποχρεωτικά SQL scripts, αλλά λειτουργεί ως βοηθητικό εργαλείο επίδειξης.

Παρέχει:

- dashboard με βασικά στατιστικά της βάσης,
- εκτέλεση των Q01-Q15 μέσα από browser,
- παραμετρικά φίλτρα για επιλεγμένα queries,
- CSV export,
- προβολή τμημάτων νοσοκομείου με εικόνες μέσω του πίνακα `entity_image`.

### Εκτέλεση UI τοπικά

Αντιγραφή του UI στο XAMPP:

```cmd
xcopy "code\hospital_db_web_ui" "C:\xampp\htdocs\hospital_db_web_ui" /E /I /H /Y
```

Άνοιγμα στον browser:

```text
http://localhost/hospital_db_web_ui/
```

Για τη φόρτωση των εικόνων των τμημάτων:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < C:\xampp\htdocs\hospital_db_web_ui\sql\load_department_images.sql
```

Οι εικόνες πρέπει να βρίσκονται στον φάκελο:

```text
C:\xampp\htdocs\hospital_db_web_ui\images\
```

Περισσότερες οδηγίες υπάρχουν στο:

```text
code/hospital_db_web_ui/README_WEB_UI.md
```

---

## Παραδοχές

- Τα δεδομένα ασθενών και προσωπικού είναι synthetic και όχι πραγματικά προσωπικά δεδομένα.
- Τα reference data προέρχονται από CSV αρχεία της εργασίας/επίσημες πηγές.
- Το `hospitalization_review` εκφράζει γενική αξιολόγηση νοσηλείας.
- Το `doctor_review` εκφράζει αξιολόγηση συγκεκριμένου γιατρού που σχετίζεται με συγκεκριμένη νοσηλεία.
- Τα `NULL` review fields στο Q06 είναι αναμενόμενα, επειδή χρησιμοποιείται `LEFT JOIN` ώστε να εμφανίζονται όλες οι νοσηλείες, ακόμη και όσες δεν έχουν review.
- Το Q09 εξετάζει ολοκληρωμένες νοσηλείες, άρα εξαιρεί εγγραφές με `discharge_date IS NULL`.
- Το Q15 μετρά όλα τα triage cases, αλλά ο μέσος χρόνος αναμονής υπολογίζεται μόνο για όσα έχουν `service_time`.
- Το `entity_image` είναι polymorphic association και τεκμηριώνεται ως συνειδητή σχεδιαστική επιλογή.
- Το web UI είναι προαιρετική επέκταση και όχι αντικατάσταση των SQL παραδοτέων.

---

## Χρήση AI εργαλείων

Χρησιμοποιήθηκαν AI εργαλεία ως βοηθητικό μέσο για έλεγχο, αναδιατύπωση, debugging, βελτίωση τεκμηρίωσης και αρχική υποστήριξη στην προαιρετική web διεπαφή. Η τελική ευθύνη ελέγχου, εκτέλεσης, διόρθωσης SQL, παραγωγής outputs και συμφωνίας με την εκφώνηση ανήκει στην ομάδα.

---

