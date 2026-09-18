<#
.SYNOPSIS
    Coleta informações básicas de hardware e sistema e salva em um relatório de texto.
.DESCRIPTION
    Script de suporte Nível 1 para diagnóstico rápido de uma máquina:
    hostname, IP, memória RAM, versão do Windows e espaço em disco.
    Útil para anexar em chamados ou levar como primeiro diagnóstico remoto.
.EXAMPLE
    .\system_report.ps1
    Gera um arquivo "relatorio_<hostname>_<data>.txt" na pasta atual.
#>

$ErrorActionPreference = "Stop"

$hostname   = $env:COMPUTERNAME
$dataHora   = Get-Date -Format "yyyy-MM-dd_HH-mm"
$nomeArquivo = "relatorio_${hostname}_${dataHora}.txt"

Write-Host "Coletando informações do sistema..." -ForegroundColor Cyan

# --- Sistema Operacional ---
$os = Get-CimInstance Win32_OperatingSystem
$osNome    = $os.Caption
$osVersao  = $os.Version
$osArquit  = $os.OSArchitecture

# --- Memória RAM ---
$ramTotalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$ramLivreGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$ramUsoPerc = [math]::Round((($ramTotalGB - $ramLivreGB) / $ramTotalGB) * 100, 1)

# --- Rede ---
$adaptadores = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" }

# --- Disco ---
$discos = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

# --- Monta o relatório ---
$linhas = @()
$linhas += "========================================"
$linhas += " RELATÓRIO DE SISTEMA - SUPORTE TÉCNICO"
$linhas += "========================================"
$linhas += "Data/Hora coleta : $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
$linhas += "Hostname         : $hostname"
$linhas += ""
$linhas += "--- Sistema Operacional ---"
$linhas += "Nome             : $osNome"
$linhas += "Versão           : $osVersao"
$linhas += "Arquitetura      : $osArquit"
$linhas += ""
$linhas += "--- Memória RAM ---"
$linhas += "Total            : $ramTotalGB GB"
$linhas += "Livre            : $ramLivreGB GB"
$linhas += "Uso atual        : $ramUsoPerc%"
$linhas += ""
$linhas += "--- Rede ---"
foreach ($ad in $adaptadores) {
    $linhas += "Interface: $($ad.InterfaceAlias)  |  IP: $($ad.IPAddress)"
}
$linhas += ""
$linhas += "--- Discos ---"
foreach ($d in $discos) {
    $totalGB = [math]::Round($d.Size / 1GB, 1)
    $livreGB = [math]::Round($d.FreeSpace / 1GB, 1)
    $linhas += "Unidade $($d.DeviceID)  |  Total: $totalGB GB  |  Livre: $livreGB GB"
}
$linhas += ""
$linhas += "========================================"

$linhas | Out-File -FilePath $nomeArquivo -Encoding UTF8

Write-Host "Relatório salvo em: $nomeArquivo" -ForegroundColor Green
Get-Content $nomeArquivo
