write-host "Install Visual Studio 2019 Enterprise..."

# Add support for building applications that target the .net 4.7.2 framework.
#choco install -y netfx-4.7.2-devpack

# Add support for building applications that target the .net 4.7.1 framework.
#choco install -y netfx-4.7.1-devpack

# Add support for building applications that target the .net 4.6.2 framework.
#choco install -y netfx-4.6.2-devpack

# Install Visual Studio Enterprise 2019
$archiveUrl = 'https://download.visualstudio.microsoft.com/download/pr/df6c2f11-eae3-4d3c-a0a8-9aec3421235b/d3eadeef65bb8ddbfdd6987cb13126d1a7836dc55faa0bd794c0df99f80d6946/vs_Enterprise.exe'
$archiveHash = 'd3eadeef65bb8ddbfdd6987cb13126d1a7836dc55faa0bd794c0df99f80d6946'
$archiveName = Split-Path $archiveUrl -Leaf
$archivePath = "$env:TEMP\$archiveName"

Write-Host '$archiveUrl ' $archiveUrl
Write-Host '$archiveName ' $archiveName
Write-Host '$archivePath ' $archivePath

Write-Host 'Downloading the Visual Studio Setup Bootstrapper...'
(New-Object System.Net.WebClient).DownloadFile($archiveUrl, $archivePath)
$archiveActualHash = (Get-FileHash $archivePath -Algorithm SHA256).Hash
if ($archiveHash -ne $archiveActualHash) {
    throw "$archiveName downloaded from $archiveUrl to $archivePath has $archiveActualHash hash which does not match the expected $archiveHash"
}
Write-Host 'Installing Visual Studio...'
for ($try = 1; ; ++$try) {
    &$archivePath `
        --includeRecommended `
        --add Microsoft.VisualStudio.Workload.ManagedDesktop `
        --add Microsoft.VisualStudio.Workload.NetWeb `
        --add Microsoft.VisualStudio.Workload.Node `
        --add Microsoft.VisualStudio.Workload.Office `
        --add Microsoft.VisualStudio.Workload.Azure `
        --add Microsoft.VisualStudio.Workload.Data `
        --add Microsoft.VisualStudio.Workload.NetCoreTools `
        --add Microsoft.VisualStudio.Component.TestTools.WebLoadTest `
        --add Microsoft.VisualStudio.Component.Git `
        --add Component.GitHub.VisualStudio `
        --add Microsoft.Net.Component.4.7.SDK `
        --add Microsoft.Net.Component.4.7.1.SDK `
        --add Microsoft.Net.Component.4.7.2.SDK   `
        --norestart `
        --quiet `
        --wait `
        | Out-String -Stream
    if ($LASTEXITCODE) {
        if ($try -le 5) {
            Write-Host "Failed to install Visual Studio with Exit Code $LASTEXITCODE. Trying again (hopefully the error was transient)..."
            Start-Sleep -Seconds 10
            continue
        }
        throw "Failed to install Visual Studio with Exit Code $LASTEXITCODE"
    }
    break
}
