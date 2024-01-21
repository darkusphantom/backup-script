Import-Module CimCmdlets

# Function to select disk
function Select-Disk {
    # Display a list of connected external disks with their name, path, size, and model
    Write-Host "Discos externos conectados:"
    Write-Host "Nombre | Ruta | Tamaño | Modelo"
    Get-WmiObject -Query "SELECT * FROM Win32_DiskDrive" | Select-Object DeviceID, MediaType, Model, Size
    Write-Host ""

    # Prompt the user to input the name of the disk they want to select (e.g., Disk 1)
    $disk = Read-Host "Por favor, introduce el nombre del dispositivo que deseas seleccionar (por ejemplo, Disk 1):"
}

# Function to verify if the selected disk exists
function Verify-If-DiskExists {
    if ([string]::IsNullOrEmpty($disk)) {
        Write-Host "No has ingresado ningún nombre de dispositivo. Por favor, intenta nuevamente."
        Select-Disk
    }

    # Check if the device exists
    $selectedDisk = Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='$disk'} WHERE AssocClass=Win32_DiskDriveToDiskPartition"
    if ($selectedDisk) {
        Write-Host "Has seleccionado el dispositivo $disk"
    } else {
        Write-Host "El dispositivo seleccionado no existe. Por favor, verifica tu selección e intenta de nuevo."
        Select-Disk
    }
}

# Function to show items on the selected disk
function Show-Items-Disk {
    Write-Host "Carpetas del disco seleccionado: $disk"
    Get-ChildItem -Path "E:\"
}

# Function to select folders
function Select-Folders {
    Write-Host "Seleccione una o varias carpetas para hacer una copia de respaldo:"
    $folders = Read-Host "Ingrese la ruta de la carpeta (separadas por espacios):"

    # Verify if the folders exist
    foreach ($folder in $folders.Split(' ')) {
        if (-not (Test-Path "E:\$folder")) {
            Write-Host "La carpeta $folder no existe. Por favor, verifique la ruta e intente de nuevo."
            exit 1
        }
    }

    Write-Host "Copia de respaldo de las siguientes carpetas:"
    $folders
}

# Function to save the backup in a local folder
function Save-Backup-Local {
    Write-Host "Ha seleccionado guardar la copia de seguridad en una carpeta local."
    $localFolder = Read-Host "Por favor, ingrese el nombre de la carpeta:"

    if (Test-Path "C:\backup\$localFolder") {
        $i = 1
        while (Test-Path "C:\backup\$localFolder ($i)") {
            $i++
        }
        New-Item -ItemType Directory -Path "C:\backup" -Name "$localFolder ($i)"
        Write-Host "Se está haciendo la copia de seguridad. Por favor espere un momento..."

        # Copy folders to the backup location
        foreach ($folder in $folders.Split(' ')) {
            Copy-Item -Path "E:\$folder" -Destination "C:\backup\$localFolder ($i)" -Recurse
            if (-not (Test-Path "E:\$folder")) {
                Write-Host "La carpeta $folder no existe. Por favor, verifique la ruta e intente de nuevo."
                exit 1
            }
        }
    } else {
        New-Item -ItemType Directory -Path "C:\backup" -Name $localFolder
        Write-Host "Se está haciendo la copia de seguridad. Por favor espere un momento..."

        # Copy folders to the backup location
        foreach ($folder in $folders.Split(' ')) {
            Copy-Item -Path "E:\$folder" -Destination "C:\backup\$localFolder" -Recurse
            if (-not (Test-Path "E:\$folder")) {
                Write-Host "La carpeta $folder no existe. Por favor, verifique la ruta e intente de nuevo."
                exit 1
            }
        }
    }
}

function select_backup_destination {
    Write-Host "Seleccione dónde desea guardar la copia de seguridad:"
    Write-Host "1. Disco externo (No disponible)"
    Write-Host "2. Carpeta local"
    $choice = Read-Host "Ingrese el número correspondiente a su elección"
    Write-Host ""

    switch ($choice) {
        1 {
            Write-Host "La opción de guardar la copia de seguridad en un disco externo no está disponible en Windows."
            # Agregue aquí el código para guardar la copia de seguridad en el disco externo
        }
        2 {
            save_backup_local
        }
        default {
            Write-Host "Selección inválida. Por favor, intente de nuevo."
            select_backup_destination
        }
    }

    Write-Host "Se ha completado la copia de seguridad"
}

function main {
    Select-Disk
    Verify-If-DiskExists
    Write-Host ""
    mount_device
    Show-Items-Disk
    Write-Host ""

    Select-Folders
    Write-Host ""
    select_backup_destination

    unmount_device
    Write-Host ""
    Write-Host "Gracias por usar el programa <3"
    Write-Host "No olvides seguirme en mis redes sociales como @darkusphantom"
    Write-Host "Puedes ver algunos de mis proyectos en https://github.com/darkusphantom"
    Write-Host "y visitar mi website: https://darkusphantom.com"
    Start-Sleep -Seconds 2
}

main