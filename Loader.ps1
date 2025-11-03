############################################
#     DaUfooo´s GitHub CriminalIP Loader   #
#                                          #
############################################

# Definiere die Basis-URL des GitHub-Repositories
$baseUrl = "https://raw.githubusercontent.com/criminalip/C2-Daily-Feed/main"

# Zielordner, in dem die CSV-Dateien gespeichert werden
$targetFolder = "C:\IPs\"

# Erstelle den Zielordner, wenn er noch nicht existiert
if (-not (Test-Path -Path $targetFolder)) {
    New-Item -ItemType Directory -Path $targetFolder | Out-Null
    Write-Host "Zielordner erstellt: $targetFolder" -ForegroundColor Cyan
} else {
    Write-Host "Zielordner existiert: $targetFolder" -ForegroundColor Cyan
}

# Array der Monate und Jahre von Juli 2024 bis November 2025
$months = @(
    "2024-07", "2024-08", "2024-09", "2024-10", "2024-11", "2024-12",
    "2025-01", "2025-02", "2025-03", "2025-04", "2025-05", "2025-06",
    "2025-07", "2025-08", "2025-09", "2025-10", "2025-11"
)

# Berechne die Gesamtanzahl der Dateien (für Fortschrittsanzeige)
$totalFiles = 0
foreach ($m in $months) {
    $parts = $m -split '-'
    $y = [int]$parts[0]    
    $mo = [int]$parts[1]
    $totalFiles += [datetime]::DaysInMonth($y, $mo)
}

if ($totalFiles -eq 0) {
    Write-Host "Keine Dateien zu verarbeiten." -ForegroundColor Yellow
    return
}

$currentIndex = 0

# Durchlaufe alle Monate und lade die CSV-Dateien herunter
foreach ($month in $months) {
    $parts = $month -split '-'
    $year = [int]$parts[0]
    $monthNum = [int]$parts[1]
    $daysInMonth = [datetime]::DaysInMonth($year, $monthNum)

    for ($day = 1; $day -le $daysInMonth; $day++) {
        $date = "{0:D2}" -f $day
        $url = "$baseUrl/$month/$month-$date.csv"
        $fileName = "ipliste_$month-$date.csv"
        $filePath = Join-Path -Path $targetFolder -ChildPath $fileName

        $currentIndex++
        $percent = [math]::Round(($currentIndex / $totalFiles) * 100, 1)
        $statusText = "Herunterlade $fileName ($currentIndex von $totalFiles) - $percent%"

        # Fortschrittsbalken
        Write-Progress -Id 1 -Activity "CriminalIP CSV Download" -Status $statusText -PercentComplete $percent

        try {
            # Wenn die Datei schon existiert, überspringen (optional)
            if (Test-Path -Path $filePath) {
                Write-Host "Übersprungen (bereits vorhanden): $fileName" -ForegroundColor Yellow
                continue
            }

            Write-Host "Versuche: $url" -ForegroundColor DarkGray

            Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop

            Write-Host "Erfolgreich: $fileName" -ForegroundColor Green
        }
        catch {
            # Unterscheide 404/nicht gefunden von anderen Fehlern wenn möglich
            $exception = $_.Exception
            $isNotFound = $false

            if ($exception -and $exception.Response) {
                try {
                    # Manche Exceptions haben Response mit StatusCode-Eigenschaft
                    if ($exception.Response.StatusCode -eq 404) {
                        $isNotFound = $true
                    }
                } catch {
                    # ignore
                }
            }

            if ($isNotFound) {
                Write-Host "Datei nicht gefunden (404): $month-$date - Übersprungen." -ForegroundColor Red
            }
            else {
                Write-Host ("Fehler beim Herunterladen " + $month + "-" + $date + ": " + $_.Exception.Message) -ForegroundColor Red
                # Falls gewünscht, entferne die fehlerhafte (teilweise) heruntergeladene Datei
                if (Test-Path -Path $filePath) {
                    Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}

Write-Progress -Id 1 -Activity "CriminalIP CSV Download" -Status "Fertig" -PercentComplete 100
Write-Host "Alle verfügbaren CSV-Dateien wurden versucht herunterzuladen." -ForegroundColor Cyan

# Warten auf Benutzeraktion bevor das Fenster geschlossen wird
Write-Host "Klicken Sie auf [Enter], um das Fenster zu schließen..."
Read-Host
