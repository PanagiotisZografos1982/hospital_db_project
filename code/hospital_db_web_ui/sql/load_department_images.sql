USE hospital_db;

DELETE FROM entity_image
WHERE entity_type = 'department';

INSERT INTO entity_image (entity_type, entity_id, image_url, description)
VALUES
('department', 1, 'images/kardiologia.png', 'Φωτογραφία τμήματος: Καρδιολογία'),
('department', 2, 'images/xeirourgiki.png', 'Φωτογραφία τμήματος: Χειρουργική'),
('department', 3, 'images/pathologia.png', 'Φωτογραφία τμήματος: Παθολογία'),
('department', 4, 'images/meth.png', 'Φωτογραφία τμήματος: ΜΕΘ'),
('department', 5, 'images/epeigonta.png', 'Φωτογραφία τμήματος: Επείγοντα'),
('department', 6, 'images/orthopaidiki.png', 'Φωτογραφία τμήματος: Ορθοπαιδική'),
('department', 7, 'images/pneymologia.png', 'Φωτογραφία τμήματος: Πνευμονολογική'),
('department', 8, 'images/neurologiki.png', 'Φωτογραφία τμήματος: Νευρολογική'),
('department', 9, 'images/ourologia.png', 'Φωτογραφία τμήματος: Ουρολογική'),
('department', 10, 'images/gastrenterologia.png', 'Φωτογραφία τμήματος: Γαστρεντερολογική'),
('department', 11, 'images/ofthalmologik.png', 'Φωτογραφία τμήματος: Οφθαλμολογική'),
('department', 12, 'images/orl.png', 'Φωτογραφία τμήματος: ΩΡΛ'),
('department', 13, 'images/nefrolog.png', 'Φωτογραφία τμήματος: Νεφρολογική'),
('department', 14, 'images/endokrinolog.png', 'Φωτογραφία τμήματος: Ενδοκρινολογική'),
('department', 15, 'images/paidiatriki.png', 'Φωτογραφία τμήματος: Παιδιατρική');