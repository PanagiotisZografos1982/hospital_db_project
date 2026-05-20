<?php
declare(strict_types=1);

function db(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $config = require __DIR__ . '/config.php';
    $dsn = sprintf(
        'mysql:host=%s;port=%d;dbname=%s;charset=%s',
        $config['db_host'],
        $config['db_port'],
        $config['db_name'],
        $config['charset']
    );

    $pdo = new PDO($dsn, $config['db_user'], $config['db_pass'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::MYSQL_ATTR_MULTI_STATEMENTS => false,
    ]);

    /*
     * Important for Greek text and for avoiding collation conflicts
     * between PHP string variables and MySQL table columns.
     */
    $pdo->exec("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");

    return $pdo;
}

function h(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function first_letter(mixed $value): string
{
    $text = trim((string) $value);
    if ($text === '') {
        return 'H';
    }
    if (function_exists('mb_substr')) {
        return mb_substr($text, 0, 1, 'UTF-8');
    }
    return substr($text, 0, 1);
}

function query_catalog(): array
{
    return [
        'Q01' => ['title' => 'Έσοδα ανά τμήμα/έτος', 'params' => []],
        'Q02' => ['title' => 'Ιατροί ανά ειδικότητα', 'params' => ['target_specialty' => ['label' => 'Ειδικότητα', 'type' => 'text', 'default' => 'Χειρουργική']]],
        'Q03' => ['title' => 'Ασθενείς με >3 νοσηλείες', 'params' => []],
        'Q04' => ['title' => 'Αξιολόγηση συγκεκριμένου ιατρού', 'params' => ['target_doctor_id' => ['label' => 'Doctor ID', 'type' => 'number', 'default' => '11']]],
        'Q05' => ['title' => 'Νέοι ιατροί με τις περισσότερες επεμβάσεις', 'params' => []],
        'Q06' => ['title' => 'Ιστορικό συγκεκριμένου ασθενή', 'params' => ['target_patient_id' => ['label' => 'Patient ID', 'type' => 'number', 'default' => '1']]],
        'Q07' => ['title' => 'Αλλεργίες ανά δραστική ουσία', 'params' => []],
        'Q08' => ['title' => 'Προσωπικό χωρίς εφημερία', 'params' => [
            'target_date' => ['label' => 'Ημερομηνία', 'type' => 'date', 'default' => '2026-05-01'],
            'target_department_id' => ['label' => 'Department ID', 'type' => 'number', 'default' => '1'],
        ]],
        'Q09' => ['title' => 'Ίδιες ημέρες νοσηλείας ανά έτος', 'params' => []],
        'Q10' => ['title' => 'Top ζεύγη δραστικών ουσιών', 'params' => []],
        'Q11' => ['title' => 'Ιατροί κάτω από τον κορυφαίο', 'params' => []],
        'Q12' => ['title' => 'Staffing βαρδιών εβδομάδας', 'params' => ['week_start' => ['label' => 'Έναρξη εβδομάδας', 'type' => 'date', 'default' => '2026-05-01']]],
        'Q13' => ['title' => 'Ιεραρχία εποπτείας ιατρών', 'params' => []],
        'Q14' => ['title' => 'ICD-10 ίδιες εισαγωγές σε συνεχόμενα έτη', 'params' => []],
        'Q15' => ['title' => 'Triage κατανομή και χρόνοι', 'params' => []],
    ];
}

function dashboard_counts(PDO $pdo): array
{
    $tables = [
        'Ασθενείς' => 'patient',
        'Προσωπικό' => 'staff',
        'Τμήματα' => 'department',
        'Νοσηλείες' => 'hospitalization',
        'Συνταγές' => 'prescription',
        'Βάρδιες' => 'shift',
    ];

    $counts = [];
    foreach ($tables as $label => $table) {
        $counts[$label] = (int) $pdo->query("SELECT COUNT(*) FROM `$table`")->fetchColumn();
    }

    $counts['Συνολικό κόστος'] = (float) $pdo->query("SELECT COALESCE(SUM(total_cost), 0) FROM hospitalization")->fetchColumn();

    return $counts;
}

function overview_rows(PDO $pdo): array
{
    return [
        'departments' => $pdo->query("
            SELECT department_id, name, bed_count, floor_building
            FROM department
            ORDER BY department_id
            LIMIT 10
        ")->fetchAll(),

        'department_images' => $pdo->query("
            SELECT
                d.department_id,
                d.name,
                d.bed_count,
                d.floor_building,
                ei.image_url,
                ei.description
            FROM department d
            LEFT JOIN entity_image ei
                ON ei.entity_type = 'department'
               AND ei.entity_id = d.department_id
            ORDER BY d.department_id
        ")->fetchAll(),

        'recent_hospitalizations' => $pdo->query("
            SELECT h.hospitalization_id, p.first_name, p.last_name, d.name AS department_name,
                   h.admission_date, h.discharge_date, h.total_cost
            FROM hospitalization h
            JOIN patient p ON p.patient_id = h.patient_id
            JOIN department d ON d.department_id = h.department_id
            ORDER BY h.admission_date DESC, h.hospitalization_id DESC
            LIMIT 8
        ")->fetchAll(),
    ];
}

function sql_literal(string $value, string $type): string
{
    if ($type === 'number') {
        return (string) (int) $value;
    }
    return "'" . str_replace("'", "''", $value) . "'";
}

function query_input_values(array $meta): array
{
    $values = [];
    foreach ($meta['params'] as $name => $info) {
        $raw = $_GET[$name] ?? $info['default'];
        $values[$name] = is_array($raw) ? $info['default'] : trim((string) $raw);
        if ($values[$name] === '') {
            $values[$name] = $info['default'];
        }
    }
    return $values;
}

function load_sql_script(string $queryId, array $values, array $meta): string
{
    $path = __DIR__ . '/sql/' . $queryId . '.sql';
    if (!is_file($path)) {
        throw new RuntimeException("Δεν βρέθηκε το αρχείο {$queryId}.sql");
    }

    $sql = file_get_contents($path);
    if ($sql === false) {
        throw new RuntimeException("Δεν μπορεί να διαβαστεί το αρχείο {$queryId}.sql");
    }

    // Δεν χρειάζεται USE hospital_db μέσα από το UI, γιατί η PDO σύνδεση γίνεται ήδη στη βάση.
    $sql = preg_replace('/^\s*USE\s+hospital_db\s*;\s*/im', '', $sql) ?? $sql;

    /*
     * Διόρθωση για Q02:
     * Το Q02.sql μπορεί να έχει hardcoded ειδικότητα, π.χ.
     * WHERE d.specialty = 'Χειρουργική'
     *
     * Εδώ προσθέτουμε/ενημερώνουμε τη μεταβλητή @target_specialty
     * και αντικαθιστούμε το hardcoded φίλτρο με:
     * WHERE d.specialty COLLATE utf8mb4_unicode_ci =
     *       @target_specialty COLLATE utf8mb4_unicode_ci
     *
     * Έτσι:
     * 1. το input του UI αλλάζει πραγματικά την ειδικότητα,
     * 2. αποφεύγεται το error "Illegal mix of collations".
     */
    if ($queryId === 'Q02') {
        $targetSpecialty = $values['target_specialty'] ?? 'Χειρουργική';
        $literal = sql_literal($targetSpecialty, 'text');

        $setPattern = '/SET\s+@target_specialty\s*:=\s*[^;]+;/i';

        if (preg_match($setPattern, $sql)) {
            $sql = preg_replace(
                $setPattern,
                "SET @target_specialty := {$literal};",
                $sql,
                1
            ) ?? $sql;
        } else {
            $sql = "SET @target_specialty := {$literal};\n" . $sql;
        }

        // Αντικαθιστά φίλτρα τύπου: d.specialty = 'Χειρουργική'
        $sql = preg_replace(
            "/d\.specialty\s*=\s*'[^']*'/iu",
            "d.specialty COLLATE utf8mb4_unicode_ci = @target_specialty COLLATE utf8mb4_unicode_ci",
            $sql
        ) ?? $sql;

        // Αντικαθιστά φίλτρα τύπου: doctor.specialty = 'Χειρουργική'
        $sql = preg_replace(
            "/doctor\.specialty\s*=\s*'[^']*'/iu",
            "doctor.specialty COLLATE utf8mb4_unicode_ci = @target_specialty COLLATE utf8mb4_unicode_ci",
            $sql
        ) ?? $sql;
    }

    // Γενική αντικατάσταση SET @parameter για Q04, Q06, Q08, Q12 κ.λπ.
    foreach ($values as $name => $value) {
        $type = $meta['params'][$name]['type'] ?? 'text';
        $literal = sql_literal($value, $type);
        $pattern = '/SET\s+@' . preg_quote($name, '/') . '\s*:=\s*[^;]+;/i';
        $replacement = "SET @{$name} := {$literal};";

        if (preg_match($pattern, $sql)) {
            $sql = preg_replace($pattern, $replacement, $sql, 1) ?? $sql;
        }
    }

    return $sql;
}

function split_sql_statements(string $sql): array
{
    $statements = [];
    $buffer = '';
    $quote = null;
    $length = strlen($sql);

    for ($i = 0; $i < $length; $i++) {
        $char = $sql[$i];
        $next = $i + 1 < $length ? $sql[$i + 1] : '';

        if ($quote !== null) {
            $buffer .= $char;
            if ($char === '\\' && $next !== '') {
                $buffer .= $next;
                $i++;
                continue;
            }
            if ($char === $quote) {
                $quote = null;
            }
            continue;
        }

        if ($char === "'" || $char === '"') {
            $quote = $char;
            $buffer .= $char;
            continue;
        }

        if ($char === '-' && $next === '-') {
            while ($i < $length && $sql[$i] !== "\n") {
                $buffer .= $sql[$i];
                $i++;
            }
            continue;
        }

        if ($char === ';') {
            $trimmed = trim($buffer);
            if ($trimmed !== '') {
                $statements[] = $trimmed;
            }
            $buffer = '';
            continue;
        }

        $buffer .= $char;
    }

    $trimmed = trim($buffer);
    if ($trimmed !== '') {
        $statements[] = $trimmed;
    }

    return $statements;
}

function run_query_file(PDO $pdo, string $queryId, array $values, array $meta): array
{
    $sql = load_sql_script($queryId, $values, $meta);
    $statements = split_sql_statements($sql);
    $lastRows = [];
    $lastColumns = [];

    foreach ($statements as $statement) {
        $stmt = $pdo->query($statement);
        if ($stmt !== false && $stmt->columnCount() > 0) {
            $lastRows = $stmt->fetchAll();
            $lastColumns = $lastRows === []
                ? array_map(fn($i) => $stmt->getColumnMeta($i)['name'] ?? "col_{$i}", range(0, $stmt->columnCount() - 1))
                : array_keys($lastRows[0]);
        }
    }

    return ['rows' => $lastRows, 'columns' => $lastColumns, 'sql' => $sql];
}

function csv_download(array $columns, array $rows, string $filename): void
{
    header('Content-Type: text/csv; charset=UTF-8');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    echo "\xEF\xBB\xBF";
    $out = fopen('php://output', 'wb');
    fputcsv($out, $columns);
    foreach ($rows as $row) {
        fputcsv($out, array_map(fn($col) => $row[$col] ?? '', $columns));
    }
    fclose($out);
    exit;
}
