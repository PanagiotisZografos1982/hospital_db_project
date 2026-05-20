# Hospital DB Web UI

## Περιγραφή

Το `hospital_db_web_ui` είναι μια προαιρετική web διεπαφή χρήστη για την εργασία **Hospital Database Project**. Η εφαρμογή χρησιμοποιείται για πιο εύκολη παρουσίαση της βάσης δεδομένων και των SQL ερωτημάτων `Q01` έως `Q15` μέσα από browser.

Το UI δεν αντικαθιστά τα βασικά παραδοτέα της εργασίας, δηλαδή τα `install.sql`, `load.sql`, `Q01-Q15.sql`, τα output αρχεία, τα διαγράμματα και το report. Αποτελεί βοηθητικό εργαλείο επίδειξης.

Η εφαρμογή υλοποιήθηκε με απλή **PHP/PDO** σύνδεση στη MySQL/MariaDB μέσω XAMPP. Δεν χρησιμοποιείται ORM ή framework, ώστε η εκτέλεση των SQL ερωτημάτων να παραμένει άμεση και διαφανής.

---

## Δομή φακέλου

```text
hospital_db_web_ui/
  config.php
  index.php
  lib.php

  assets/
    style.css

  images/
    kardiologia.png
    xeirourgiki.png
    pathologia.png
    meth.png
    epeigonta.png
    orthopaidiki.png
    pneymologia.png
    neurologiki.png
    ourologia.png
    gastrenterologia.png
    ofthalmologik.png
    orl.png
    nefrolog.png
    endokrinolog.png
    paidiatriki.png

  sql/
    Q01.sql
    Q02.sql
    ...
    Q15.sql
    load_department_images.sql
```

---

## Βασικά αρχεία

### `config.php`

Το αρχείο `config.php` περιέχει τις ρυθμίσεις σύνδεσης με τη βάση δεδομένων:

```php
return [
    'db_host' => '127.0.0.1',
    'db_port' => 3306,
    'db_name' => 'hospital_db',
    'db_user' => 'root',
    'db_pass' => '',
    'charset' => 'utf8mb4',
];
```

Για χρήση με XAMPP, ο χρήστης είναι συνήθως `root` και ο κωδικός είναι κενός.

### `lib.php`

Το αρχείο `lib.php` περιέχει τη βασική λογική της εφαρμογής:

- σύνδεση με τη βάση μέσω PDO,
- προστασία output με `htmlspecialchars`,
- κατάλογο των queries `Q01-Q15`,
- ανάγνωση των SQL αρχείων από τον φάκελο `sql/`,
- αντικατάσταση παραμέτρων για selected queries,
- εκτέλεση των queries,
- εξαγωγή αποτελεσμάτων σε CSV,
- φόρτωση στοιχείων dashboard και εικόνων τμημάτων.

Στη σύνδεση χρησιμοποιείται:

```php
$pdo->exec("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");
```

ώστε να εμφανίζονται σωστά τα ελληνικά και να αποφεύγονται collation conflicts.

### `index.php`

Το αρχείο `index.php` είναι η κεντρική σελίδα του UI. Εμφανίζει:

- sidebar με τα ερωτήματα `Q01-Q15`,
- dashboard με βασικά στατιστικά της βάσης,
- κάρτες με εικόνες των τμημάτων,
- φόρμα παραμέτρων για επιλεγμένα queries,
- πίνακα αποτελεσμάτων,
- δυνατότητα προβολής του SQL query,
- δυνατότητα εξαγωγής σε CSV.

---

## Προϋποθέσεις

Για να λειτουργήσει το UI χρειάζονται:

- εγκατεστημένο XAMPP,
- ενεργό Apache,
- ενεργό MySQL,
- φορτωμένη βάση `hospital_db`,
- τα SQL scripts της εργασίας να έχουν τρέξει σωστά.

Στο XAMPP Control Panel πρέπει να είναι πράσινα:

```text
Apache
MySQL
```

---

## Εγκατάσταση στο XAMPP

Αν το project βρίσκεται στον φάκελο:

```text
C:\Users\panzo\SEMESTER PROJECT\hospital_db_project
```

τότε αντιγράφουμε το UI στο `htdocs` με:

```cmd
xcopy "C:\Users\panzo\SEMESTER PROJECT\hospital_db_project\code\hospital_db_web_ui" "C:\xampp\htdocs\hospital_db_web_ui" /E /I /H /Y
```

Μετά ανοίγουμε στον browser:

```text
http://localhost/hospital_db_web_ui/
```

Αν η σύνδεση είναι σωστή, στην πάνω δεξιά πλευρά εμφανίζεται:

```text
Connected
```

---

## Δημιουργία και φόρτωση βάσης

Πριν ανοίξει σωστά το UI, πρέπει να έχει δημιουργηθεί και φορτωθεί η βάση.

Από το root του project:

```cmd
cd /d "C:\Users\panzo\SEMESTER PROJECT\hospital_db_project"
```

Εγκατάσταση schema:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root < sql\install.sql
```

Φόρτωση δεδομένων:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 --local-infile=1 -u root hospital_db < sql\load.sql
```

Φόρτωση εικόνων τμημάτων:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < C:\xampp\htdocs\hospital_db_web_ui\sql\load_department_images.sql
```

---

## Φόρτωση εικόνων τμημάτων

Οι εικόνες των τμημάτων πρέπει να βρίσκονται στον φάκελο:

```text
C:\xampp\htdocs\hospital_db_web_ui\images\
```

Τα paths τους αποθηκεύονται στον πίνακα `entity_image`.

Παράδειγμα εγγραφών:

```text
entity_type = department
entity_id   = 1
image_url   = images/kardiologia.png
```

Το script που περνάει τις εικόνες στη βάση είναι:

```text
sql/load_department_images.sql
```

Για να το ξανατρέξουμε:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db < C:\xampp\htdocs\hospital_db_web_ui\sql\load_department_images.sql
```

Έλεγχος ότι μπήκαν οι εικόνες:

```cmd
C:\xampp\mysql\bin\mysql --default-character-set=utf8mb4 -u root hospital_db -e "SELECT entity_id, image_url FROM entity_image WHERE entity_type='department' ORDER BY entity_id;"
```

---

## Παραμετρικά queries

Το UI επιτρέπει αλλαγή παραμέτρων για ορισμένα queries χωρίς χειροκίνητη αλλαγή στα SQL αρχεία.

| Query | Παράμετρος | Περιγραφή |
|---|---|---|
| Q02 | `target_specialty` | Επιλογή ειδικότητας γιατρού |
| Q04 | `target_doctor_id` | Επιλογή συγκεκριμένου γιατρού |
| Q06 | `target_patient_id` | Επιλογή συγκεκριμένου ασθενή |
| Q08 | `target_date`, `target_department_id` | Ημερομηνία και τμήμα |
| Q12 | `week_start` | Έναρξη εβδομάδας |

Παράδειγμα URL για Q02:

```text
http://localhost/hospital_db_web_ui/?q=Q02&target_specialty=Καρδιολογία
```

Παράδειγμα URL για Q04:

```text
http://localhost/hospital_db_web_ui/?q=Q04&target_doctor_id=11
```

Παράδειγμα URL για Q06:

```text
http://localhost/hospital_db_web_ui/?q=Q06&target_patient_id=1
```

---

## CSV export

Για κάθε query υπάρχει δυνατότητα εξαγωγής αποτελεσμάτων σε CSV μέσω του κουμπιού `CSV`.

Το CSV εξάγεται με UTF-8 BOM ώστε να ανοίγει σωστά σε Excel με ελληνικούς χαρακτήρες.

---


---

## Ρόλος του UI στην εργασία

Το Web UI είναι προαιρετική επέκταση για την παρουσίαση της εργασίας. Δείχνει ότι το σχεσιακό schema και τα SQL queries μπορούν να αξιοποιηθούν σε ένα απλό περιβάλλον εφαρμογής.

Δεν αλλάζει:

- τη δομή της βάσης,
- τα υποχρεωτικά SQL scripts,
- τα παραδοτέα outputs,
- τα ER/relational diagrams,
- το report.

Λειτουργεί ως επιπλέον εργαλείο επίδειξης για το dashboard, τα queries και τις εικόνες των τμημάτων.
