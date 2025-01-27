Write-Host '---------------------------------------------' -ForegroundColor Cyan
Write-Host '        # Folderizer #                       ' -ForegroundColor Yellow
Write-Host ' * Developed by: Neama Kazemi               ' -ForegroundColor White
Write-Host ' * Github: @neamax                          ' -ForegroundColor White
Write-Host ' * Website: luckygene.net                   ' -ForegroundColor White
Write-Host ' * Email: neama@luckygene.net               ' -ForegroundColor White
Write-Host '---------------------------------------------' -ForegroundColor Cyan
Write-Host '_____________________________________________' -ForegroundColor Cyan
Write-Host ' This script organizes files in the current ' -ForegroundColor White
Write-Host ' directory by their date (EXIF or modified) ' -ForegroundColor White
Write-Host ' and moves them into an 'Organized' folder, ' -ForegroundColor White
Write-Host ' where each folder is named after the date. ' -ForegroundColor White
Write-Host '_____________________________________________' -ForegroundColor Cyan
Write-Host ''

Write-Host 'Press 'S' to start the script or any other key to quit:' -ForegroundColor Green
$key = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').Character

if ($key -ne 'S' -and $key -ne 's') {
    Write-Host 'Script aborted by the user.' -ForegroundColor Red
    return
}

$source = $PSScriptRoot
$destination = Join-Path $PSScriptRoot 'Organized'

if (-not (Test-Path $destination)) {
    New-Item -ItemType Directory -Path $destination
}

Add-Type -AssemblyName 'System.Drawing'

Get-ChildItem $source -File | Where-Object { $_.DirectoryName -ne $destination } | ForEach-Object {
    $file = $_.FullName
    $dateTaken = $null
    
    try {
        if ($_.Extension -match '\.(jpg|jpeg|png|bmp|gif|tiff)$') {
            $image = [System.Drawing.Image]::FromFile($file)
            $propertyItem = $image.PropertyItems | Where-Object { $_.Id -eq 0x9003 }
            if ($propertyItem) {
                $dateTaken = ([System.Text.Encoding]::ASCII.GetString($propertyItem.Value)).Trim().Split(' ')[0] -replace ':', ''
            }
            $image.Dispose()
        }
    } catch {
        Write-Host '! Error processing file: $file' -ForegroundColor Red
    }
    
    if ($dateTaken) {
        $folderName = $dateTaken.Substring(2)
    } else {
        $folderName = $_.LastWriteTime.ToString('yyMMdd')
    }
    
    $folder = Join-Path $destination $folderName
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder
    }
    
    try {
        Move-Item $file -Destination $folder
    } catch {
        Write-Host '! Error moving file: $file' -ForegroundColor Red
    }
}

Write-Host '=============================================' -ForegroundColor Cyan
Write-Host 'Script execution completed!                  ' -ForegroundColor Yellow
Write-Host 'Your files are now neatly organized!         ' -ForegroundColor Yellow
Write-Host '=============================================' -ForegroundColor Cyan

Write-Host ''
Write-Host 'Press any key to exit...' -ForegroundColor White
$null = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
