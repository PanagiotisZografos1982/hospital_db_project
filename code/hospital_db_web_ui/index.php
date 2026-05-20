<?php
declare(strict_types=1);

require __DIR__ . '/lib.php';

$catalog = query_catalog();
$selected = strtoupper((string) ($_GET['q'] ?? 'Q01'));
if (!isset($catalog[$selected])) {
    $selected = 'Q01';
}

$meta = $catalog[$selected];
$values = query_input_values($meta);
$error = null;
$result = ['rows' => [], 'columns' => [], 'sql' => ''];
$counts = [];
$overview = ['departments' => [], 'department_images' => [], 'recent_hospitalizations' => []];

try {
    $pdo = db();
    $counts = dashboard_counts($pdo);
    $overview = overview_rows($pdo);
    $result = run_query_file($pdo, $selected, $values, $meta);

    if (($_GET['download'] ?? '') === 'csv') {
        csv_download($result['columns'], $result['rows'], $selected . '.csv');
    }
} catch (Throwable $e) {
    $error = $e->getMessage();
}

?>
<!doctype html>
<html lang="el">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hospital DB</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div class="app-shell">
    <aside class="sidebar">
        <div class="brand">
            <div class="brand-mark">H</div>
            <div>
                <h1>Hospital DB</h1>
                <p>Βάσεις Δεδομένων</p>
            </div>
        </div>

        <nav class="query-nav" aria-label="Queries">
            <?php foreach ($catalog as $id => $item): ?>
                <a class="<?= $id === $selected ? 'active' : '' ?>" href="?q=<?= h($id) ?>">
                    <span><?= h($id) ?></span>
                    <small><?= h($item['title']) ?></small>
                </a>
            <?php endforeach; ?>
        </nav>
    </aside>

    <main class="content">
        <section class="topbar">
            <div>
                <p class="eyebrow">Γενικό Νοσοκομείο Υγειόπολης</p>
                <h2>Πίνακας ελέγχου και ερωτήματα SQL</h2>
            </div>
            <div class="status-pill <?= $error ? 'danger' : 'ok' ?>">
                <?= $error ? 'DB error' : 'Connected' ?>
            </div>
        </section>

        <?php if ($error): ?>
            <section class="alert">
                <strong>Δεν μπόρεσε να εκτελεστεί η εφαρμογή.</strong>
                <p><?= h($error) ?></p>
                <p>Έλεγξε ότι έχει φορτωθεί η βάση `hospital_db` και ότι το XAMPP MySQL τρέχει.</p>
            </section>
        <?php endif; ?>

        <?php if (!$error): ?>
            <section class="metrics">
                <?php foreach ($counts as $label => $value): ?>
                    <div class="metric">
                        <span><?= h($label) ?></span>
                        <strong>
                            <?php if ($label === 'Συνολικό κόστος'): ?>
                                <?= number_format((float) $value, 2, ',', '.') ?> €
                            <?php else: ?>
                                <?= number_format((int) $value, 0, ',', '.') ?>
                            <?php endif; ?>
                        </strong>
                    </div>
                <?php endforeach; ?>
            </section>

            <section class="panel departments-showcase">
                <div class="panel-header">
                    <div>
                        <p class="eyebrow">Our Hospital Departments</p>
                        <h3>Τμήματα του νοσοκομείου</h3>
                    </div>
                </div>

                <div class="department-grid">
                    <?php foreach ($overview['department_images'] as $department): ?>
                        <article class="department-card">
                            <div class="department-image">
                                <?php if (!empty($department['image_url'])): ?>
                                    <img
                                        src="<?= h($department['image_url']) ?>"
                                        alt="<?= h($department['description'] ?: $department['name']) ?>"
                                        loading="lazy"
                                    >
                                <?php else: ?>
                                    <div class="department-placeholder">
                                        <?= h(first_letter($department['name'])) ?>
                                    </div>
                                <?php endif; ?>
                            </div>

                            <div class="department-body">
                                <h4><?= h($department['name']) ?></h4>
                                <p><?= h($department['description'] ?: 'Νοσοκομειακό τμήμα') ?></p>

                                <div class="department-meta">
                                    <span><?= h($department['bed_count']) ?> κλίνες</span>
                                    <span><?= h($department['floor_building']) ?></span>
                                </div>
                            </div>
                        </article>
                    <?php endforeach; ?>
                </div>
            </section>

            <section class="panel query-panel">
                <div class="panel-header">
                    <div>
                        <p class="eyebrow"><?= h($selected) ?></p>
                        <h3><?= h($meta['title']) ?></h3>
                    </div>
                    <a class="button" href="?<?= h(http_build_query(array_merge($_GET, ['download' => 'csv']))) ?>">CSV</a>
                </div>

                <?php if ($meta['params']): ?>
                    <form class="filters" method="get">
                        <input type="hidden" name="q" value="<?= h($selected) ?>">
                        <?php foreach ($meta['params'] as $name => $info): ?>
                            <label>
                                <span><?= h($info['label']) ?></span>
                                <input
                                    type="<?= h($info['type']) ?>"
                                    name="<?= h($name) ?>"
                                    value="<?= h($values[$name] ?? $info['default']) ?>"
                                >
                            </label>
                        <?php endforeach; ?>
                        <button type="submit">Εκτέλεση</button>
                    </form>
                <?php endif; ?>

                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <?php foreach ($result['columns'] as $column): ?>
                                <th><?= h($column) ?></th>
                            <?php endforeach; ?>
                        </tr>
                        </thead>
                        <tbody>
                        <?php if (!$result['rows']): ?>
                            <tr>
                                <td colspan="<?= max(1, count($result['columns'])) ?>" class="empty">Δεν επέστρεψε γραμμές.</td>
                            </tr>
                        <?php else: ?>
                            <?php foreach ($result['rows'] as $row): ?>
                                <tr>
                                    <?php foreach ($result['columns'] as $column): ?>
                                        <td><?= h($row[$column] ?? '') ?></td>
                                    <?php endforeach; ?>
                                </tr>
                            <?php endforeach; ?>
                        <?php endif; ?>
                        </tbody>
                    </table>
                </div>

                <details class="sql-preview">
                    <summary>SQL</summary>
                    <pre><?= h($result['sql']) ?></pre>
                </details>
            </section>

            <section class="grid-two">
                <div class="panel">
                    <div class="panel-header compact">
                        <h3>Τμήματα</h3>
                    </div>
                    <div class="table-wrap small">
                        <table>
                            <thead>
                            <tr><th>ID</th><th>Όνομα</th><th>Κλίνες</th><th>Τοποθεσία</th></tr>
                            </thead>
                            <tbody>
                            <?php foreach ($overview['departments'] as $row): ?>
                                <tr>
                                    <td><?= h($row['department_id']) ?></td>
                                    <td><?= h($row['name']) ?></td>
                                    <td><?= h($row['bed_count']) ?></td>
                                    <td><?= h($row['floor_building']) ?></td>
                                </tr>
                            <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-header compact">
                        <h3>Πρόσφατες νοσηλείες</h3>
                    </div>
                    <div class="table-wrap small">
                        <table>
                            <thead>
                            <tr><th>ID</th><th>Ασθενής</th><th>Τμήμα</th><th>Εισαγωγή</th><th>Κόστος</th></tr>
                            </thead>
                            <tbody>
                            <?php foreach ($overview['recent_hospitalizations'] as $row): ?>
                                <tr>
                                    <td><?= h($row['hospitalization_id']) ?></td>
                                    <td><?= h($row['first_name'] . ' ' . $row['last_name']) ?></td>
                                    <td><?= h($row['department_name']) ?></td>
                                    <td><?= h($row['admission_date']) ?></td>
                                    <td><?= h(number_format((float) $row['total_cost'], 2, ',', '.')) ?> €</td>
                                </tr>
                            <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        <?php endif; ?>
    </main>
</div>
</body>
</html>
