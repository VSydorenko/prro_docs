# Функція для рекурсивного перетворення файлів в UTF-8 з BOM з обмеженням за розширенням
function ConvertXmlFiles($folderPath) {
    # Перебір усіх файлів та підпапок в переданій папці
    Get-ChildItem -Path $folderPath -Recurse | ForEach-Object {
        # Якщо це файл і його розширення .xml або .xsd, то конвертуємо його в UTF-8 з BOM
        if (-not $_.PSIsContainer -and ($_.Extension -eq '.xml' -or $_.Extension -eq '.xsd')) {
            # Конвертуємо файл
            $filePath = $_.FullName
            $fileContent = Get-Content $filePath
            $fileStreamWriter = New-Object System.IO.StreamWriter($filePath, $false, (New-Object System.Text.UTF8Encoding $true))
            foreach ($line in $fileContent) {
                $fileStreamWriter.WriteLine($line)
            }
            $fileStreamWriter.Close()
            Write-Host "Файл $filePath було успішно перетворено в UTF-8 з BOM"
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
