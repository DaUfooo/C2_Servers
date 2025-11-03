############################################
#     DaUfooo´s GitHub CriminalIP Mercher  #
#                                          #
############################################


# Zielordner, in dem die CSV-Dateien gespeichert sind
$targetFolder = "C:\IPs\"

# Der Name der neuen zusammengeführten CSV-Datei
$outputCsv = "C:\IPs\merged_ips.csv"

# Hole alle CSV-Dateien im Zielordner
$csvFiles = Get-ChildItem -Path $targetFolder -Filter "*.csv"

# Überprüfe, ob es CSV-Dateien gibt
if ($csvFiles.Count -eq 0) {
    Write-Host "Keine CSV-Dateien im Zielordner gefunden!" -ForegroundColor Red
    return
}

# Initialisiere eine Variable für das erste CSV
$firstFile = $csvFiles[0]
$csvContent = Import-Csv -Path $firstFile.FullName

# Schreibe den Header (die Spaltennamen) in die neue Datei
$csvContent | Export-Csv -Path $outputCsv -NoTypeInformation -Force

Write-Host "Beginne mit dem Zusammenführen der CSV-Dateien..." -ForegroundColor Cyan
Write-Host "Erste CSV eingelesen..." -ForegroundColor Cyan

# Durchlaufe alle CSV-Dateien ab der zweiten Datei (erste ist bereits geschrieben)
foreach ($csvFile in $csvFiles) {
    # Vermeide die erste Datei, da sie bereits exportiert wurde
    if ($csvFile.FullName -eq $firstFile.FullName) {
        continue
    }

    # Lese den Inhalt der aktuellen CSV-Datei
    $csvContent = Import-Csv -Path $csvFile.FullName

    # Hänge die Daten an die Zieldatei an
    $csvContent | Export-Csv -Path $outputCsv -NoTypeInformation -Append -Force

    Write-Host "Fertig mit Datei: $($csvFile.Name)" -ForegroundColor Green
}

Write-Host "Alle CSV-Dateien wurden erfolgreich zusammengeführt!" -ForegroundColor Cyan
Write-Host "Die zusammengeführte CSV-Datei befindet sich unter: $outputCsv" -ForegroundColor Cyan

# Warten auf Benutzeraktion bevor das Fenster geschlossen wird
Write-Host "Klicken Sie auf [Enter], um das Fenster zu schließen..."
Read-Host
