# File: DataCenterAdmin.ps1

<#
.SYNOPSIS
    Herramienta de administración para Data Centers en PowerShell.

.DESCRIPTION
    Este script proporciona un menú interactivo con varias opciones para ayudar
    en las tareas de administración de un Data Center. Las opciones incluyen
    mostrar los procesos que más CPU consumen, los filesystems conectados,
    el archivo más grande en un directorio especificado, información de memoria,
    y conexiones de red activas.

#>

<#
.SYNOPSIS
    Muestra el menú principal con las opciones disponibles.
.EXAMPLE
    ShowMenu
#>
function ShowMenu {
    Write-Host "1. Desplegar los cinco procesos que más CPU estén consumiendo en ese momento."
    Write-Host "2. Desplegar los filesystems o discos conectados a la máquina."
    Write-Host "3. Desplegar el nombre y el tamaño del archivo más grande almacenado en un disco o filesystem."
    Write-Host "4. Cantidad de memoria libre y cantidad del espacio de swap en uso."
    Write-Host "5. Número de conexiones de red activas actualmente."
    Write-Host "0. Salir."
}

<#
.SYNOPSIS
    Muestra los cinco procesos que más CPU están consumiendo en ese momento.
.EXAMPLE
    ShowTopProcesses
#>
function ShowTopProcesses {
    Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5
}

<#
.SYNOPSIS
    Muestra los filesystems conectados, incluyendo espacio usado y libre en bytes.
.EXAMPLE
    ShowFilesystems
#>
function ShowFilesystems {
    Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name="Used(Bytes)";Expression={$_.Used}}, @{Name="Free(Bytes)";Expression={$_.Free}}
}

<#
.SYNOPSIS
    Muestra el archivo más grande en un directorio especificado por el usuario.
.PARAMETER path
    Ruta del disco o filesystem donde buscar el archivo más grande.
.EXAMPLE
    ShowLargestFile -path "C:\Users\Windows 10\Downloads"
#>
function ShowLargestFile {
    param (
        [string]$path
    )
    Get-ChildItem -Path $path -Recurse | Sort-Object -Property Length -Descending | Select-Object -First 1 | Select-Object FullName, @{Name="Size(Bytes)";Expression={$_.Length}}
}

<#
.SYNOPSIS
    Muestra la cantidad de memoria libre y la cantidad de espacio de swap en uso.
.DESCRIPTION
    Incluye validaciones para asegurar que los datos obtenidos no sean nulos antes de crear y mostrar el objeto personalizado con los resultados de la memoria y el swap.
.EXAMPLE
    ShowMemoryUsage
#>
function ShowMemoryUsage {
    $memory = Get-CimInstance Win32_OperatingSystem

    # Verificar si la información del sistema operativo se pudo obtener
    if ($memory -eq $null) {
        Write-Host "Error: No se pudo obtener la información del sistema operativo."
        return
    }

    # Calcular los valores de memoria y swap en bytes
    $freePhysicalMemory = $memory.FreePhysicalMemory * 1KB
    $totalVirtualMemory = $memory.TotalVirtualMemorySize * 1KB
    $freeVirtualMemory = $memory.FreeVirtualMemory * 1KB
    $usedSwap = ($memory.TotalVirtualMemorySize - $memory.FreeVirtualMemory) * 1KB
    $swapUsagePercentage = [math]::round((($memory.TotalVirtualMemorySize - $memory.FreeVirtualMemory) / $memory.TotalVirtualMemorySize) * 100, 2)

    # Verificar si los valores calculados no son nulos
    if ($freePhysicalMemory -eq $null -or $totalVirtualMemory -eq $null -or $freeVirtualMemory -eq $null -or $usedSwap -eq $null -or $swapUsagePercentage -eq $null) {
        Write-Host "Error: No se pudieron calcular todos los valores de memoria."
        return
    }

    # Crear y mostrar un objeto personalizado con los valores de memoria y swap
    [pscustomobject]@{
        FreePhysicalMemory = $freePhysicalMemory
        UsedSwap = $usedSwap
        SwapUsagePercentage = $swapUsagePercentage
    }
}

<#
.SYNOPSIS
    Muestra el número de conexiones de red activas actualmente en estado ESTABLISHED.
.EXAMPLE
    ShowNetworkConnections
#>
function ShowNetworkConnections {
    Get-NetTCPConnection -State Established | Measure-Object | Select-Object -Property Count
}

# Bucle principal para mostrar el menú y ejecutar las opciones seleccionadas
do {
    ShowMenu
    $choice = Read-Host "Seleccione una opción"
    switch ($choice) {
        1 { ShowTopProcesses }
        2 { ShowFilesystems }
        3 { 
            $path = Read-Host "Ingrese el path del disco o filesystem"
            ShowLargestFile -path $path 
        }
        4 { ShowMemoryUsage }
        5 { ShowNetworkConnections }
        0 { break }
        default { Write-Host "Opción no válida, intente de nuevo." }
    }
} while ($choice -ne 0)
