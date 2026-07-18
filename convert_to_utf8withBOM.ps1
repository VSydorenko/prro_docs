# Функція для рекурсивного перетворення файлів в UTF-8 з BOM з обмеженням за розширенням
function ConvertXmlFiles($folderPath) {
    # Перебір усіх файлів та підпапок в переданій папці
    Get-ChildItem -Path $folderPath -Recurse | ForEach-Object {
        # Якщо це файл і його розширення .xml або .xsd, то конвертуємо його в UTF-8 з BOM
        if (-not $_.PSIsContainer -and ($_.Extension -eq '.xml' -or $_.Extension -eq '.xsd')) {
            # Перевірка, чи файл вже має BOM
            $hasBOM = $false
            try {
                $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
                if ($bytes.Length -ge 3) {
                    $hasBOM = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
                }
            } catch {
                Write-Host "Помилка при зчитуванні файлу $($_.FullName): $_"
            }

            if (-not $hasBOM) {
                # Конвертуємо файл з windows-1251 в UTF-8 з BOM
                $filePath = $_.FullName
                $win1251 = [System.Text.Encoding]::GetEncoding('windows-1251')
                $fileContent = [System.IO.File]::ReadAllText($filePath, $win1251)
                $utf8BOM = New-Object System.Text.UTF8Encoding $true
                [System.IO.File]::WriteAllText($filePath, $fileContent, $utf8BOM)
                Write-Host "Файл $filePath було успішно перетворено в UTF-8 з BOM"
            } else {
                Write-Host "Файл $($_.FullName) вже має BOM, пропускаємо конвертацію"
            }
        }
    }
}

# Отримання абсолютного шляху до папки з файлами (відносний шлях в межах проекту)
$inputFolder = Join-Path $PSScriptRoot "Єдине вікно подання електронної звітності"

# Перевірка чи існує папка
if (-not (Test-Path $inputFolder -PathType Container)) {
    Write-Host "Папка не існує"
    exit 1
}

# Зміна робочого каталогу на папку з файлами
Set-Location -Path $inputFolder

# Рекурсивне перетворення файлів в UTF-8 з BOM тільки для файлів з розширенням .xml або .xsd
ConvertXmlFiles $inputFolder

# Повернення в домашній каталог проекту
Set-Location $PSScriptRoot

Write-Host "Конвертація в UTF-8 з BOM виконана успішно"
