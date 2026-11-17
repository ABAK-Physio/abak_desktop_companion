# PowerShell 5.1. Synthetic conversion test only; no patient document is read.
# This test does not qualify Windows process/network isolation for Companion.
[CmdletBinding()]
param(
    [string]$OfficeDirectory = 'C:\Program Files\LibreOffice\program',
    [string]$ApplicationDirectory = 'C:\Program Files\ABAK Desktop Companion'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Quote a single argv element according to the Windows CRT rules. No shell.
function Quote-NativeArgument([string]$Value) {
    if ($Value.IndexOf([char]0) -ge 0) { throw 'Argument contenant NUL.' }
    $escaped = [regex]::Replace($Value, '(\\*)"', '$1$1\"')
    $escaped = [regex]::Replace($escaped, '(\\+)$', '$1$1')
    return '"' + $escaped + '"'
}

function Invoke-TestProcess {
    param([string]$Executable, [string[]]$Arguments,
          [string]$WorkingDirectory, [int]$TimeoutMs,
          [hashtable]$EnvironmentValues)
    $info = New-Object System.Diagnostics.ProcessStartInfo
    $info.FileName = $Executable
    $info.Arguments = (($Arguments | ForEach-Object { Quote-NativeArgument $_ }) -join ' ')
    $info.WorkingDirectory = $WorkingDirectory
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    # Keep the synthetic test independent of user Java/Office options.
    foreach ($name in @('JAVA_TOOL_OPTIONS', 'JDK_JAVA_OPTIONS', '_JAVA_OPTIONS',
                        'CLASSPATH', 'PYTHONPATH', 'PYTHONHOME')) {
        $info.EnvironmentVariables.Remove($name)
    }
    foreach ($name in $EnvironmentValues.Keys) {
        $info.EnvironmentVariables[$name] = $EnvironmentValues[$name]
    }
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $info
    try {
        if (-not $process.Start()) { throw 'Processus non demarre.' }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutMs)) {
            # Only terminate this test's process tree, never all Office processes.
            & "$env:SystemRoot\System32\taskkill.exe" /PID $process.Id /T /F | Out-Null
            throw "Delai depasse : $Executable"
        }
        if (-not $stdoutTask.Wait(10000) -or -not $stderrTask.Wait(10000)) {
            throw 'Sorties du processus non terminees.'
        }
        return [PSCustomObject]@{
            ExitCode = $process.ExitCode
            Stdout = $stdoutTask.Result
            Stderr = $stderrTask.Result
        }
    }
    finally { $process.Dispose() }
}

function Write-Utf8([string]$Path, [string]$Value) {
    [System.IO.File]::WriteAllText($Path, $Value, (New-Object System.Text.UTF8Encoding($false)))
}

$office = Join-Path $OfficeDirectory 'soffice.exe'
$binary = Join-Path $OfficeDirectory 'soffice.bin'
foreach ($path in @($office, $binary)) {
    $signature = Get-AuthenticodeSignature -LiteralPath $path
    if ($signature.Status -ne 'Valid' -or
        $signature.SignerCertificate.GetNameInfo(
            [System.Security.Cryptography.X509Certificates.X509NameType]::SimpleName,
            $false) -ne 'The Document Foundation') {
        throw "Signature LibreOffice non valide ou editeur inattendu : $path"
    }
}

$tools = Join-Path $ApplicationDirectory 'data\DmpTools\x64'
$manifestPath = Join-Path $tools 'manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($manifest.protocol -ne 1 -or $manifest.profile -ne 'PDF/A-1b') {
    throw 'Manifeste DMP non pris en charge.'
}
$toolsRoot = [System.IO.Path]::GetFullPath($tools).TrimEnd('\') + '\'
foreach ($entry in $manifest.files.PSObject.Properties) {
    $path = [System.IO.Path]::GetFullPath((Join-Path $tools $entry.Name))
    if (-not $path.StartsWith($toolsRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Chemin hors du paquet DMP.'
    }
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $entry.Value) {
        throw "Outil DMP modifie : $($entry.Name)"
    }
}
foreach ($name in @('java/bin/java.exe', 'vera/cli.jar')) {
    if ($null -eq $manifest.files.PSObject.Properties[$name]) {
        throw "Composant DMP absent du manifeste : $name"
    }
}

$job = Join-Path $env:TEMP ('ABAK-WindowsDocxProbe-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $job | Out-Null
Write-Host "Dossier des preuves : $job"
$package = Join-Path $job 'ooxml'
$rels = Join-Path $package '_rels'
$word = Join-Path $package 'word'
New-Item -ItemType Directory -Path $rels, $word | Out-Null
Write-Utf8 (Join-Path $package '[Content_Types].xml') @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>
'@
Write-Utf8 (Join-Path $rels '.rels') @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>
'@
Write-Utf8 (Join-Path $word 'document.xml') @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:r><w:t>ABAK - Test synthetique de conversion Windows</w:t></w:r></w:p><w:p><w:r><w:t>Aucune donnee patient. Accents : kin&#233;sith&#233;rapie, &#233;valuation. PDF/A-1b.</w:t></w:r></w:p><w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/></w:sectPr></w:body></w:document>
'@
$docx = Join-Path $job 'source.docx'
# Windows PowerShell / .NET Framework can generate ZIP names with backslashes.
# OOXML part names must use forward slashes, regardless of the host platform.
$parts = [ordered]@{
    '[Content_Types].xml' = (Join-Path $package '[Content_Types].xml')
    '_rels/.rels' = (Join-Path $rels '.rels')
    'word/document.xml' = (Join-Path $word 'document.xml')
}
$archive = [System.IO.Compression.ZipFile]::Open(
    $docx, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($name in $parts.Keys) {
        $entry = $archive.CreateEntry(
            $name, [System.IO.Compression.CompressionLevel]::Optimal)
        $outputStream = $entry.Open()
        try {
            $inputStream = [System.IO.File]::OpenRead($parts[$name])
            try { $inputStream.CopyTo($outputStream) }
            finally { $inputStream.Dispose() }
        }
        finally { $outputStream.Dispose() }
    }
}
finally { $archive.Dispose() }

# Refuse malformed test documents before invoking Office.
$archive = [System.IO.Compression.ZipFile]::OpenRead($docx)
try {
    if ($archive.Entries.Count -ne $parts.Count) {
        throw 'DOCX synthetique incomplet.'
    }
    foreach ($name in $parts.Keys) {
        $entry = $archive.GetEntry($name)
        if ($null -eq $entry -or $entry.Length -le 0 -or
            $entry.FullName.Contains('\')) {
            throw "Entree DOCX absente ou invalide : $name"
        }
    }
}
finally { $archive.Dispose() }
Write-Host 'Structure DOCX verifiee : 3 parties, chemins OOXML avec /.'
$sourceHash = (Get-FileHash -LiteralPath $docx -Algorithm SHA256).Hash
$profile = Join-Path $job 'office'
$profileUser = Join-Path $profile 'user'
New-Item -ItemType Directory -Path $profileUser | Out-Null
Write-Utf8 (Join-Path $profileUser 'registrymodifications.xcu') @'
<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry">
<item oor:path="/org.openoffice.Office.Common/Security/Scripting"><prop oor:name="DisableMacrosExecution" oor:op="fuse"><value>true</value></prop><prop oor:name="MacroSecurityLevel" oor:op="fuse"><value>3</value></prop></item>
<item oor:path="/org.openoffice.Office.Writer/Content/Update"><prop oor:name="Link" oor:op="fuse"><value>2</value></prop></item>
</oor:items>
'@
# The filter and profile settings match the current macOS converter.
$filter = 'pdf:writer_pdf_Export:{"SelectPdfVersion":{"type":"long","value":"1"},"UseTaggedPDF":{"type":"boolean","value":"true"},"ExportFormFields":{"type":"boolean","value":"false"},"ExportNotes":{"type":"boolean","value":"false"}}'
$profileUri = ([System.Uri]::new($profile + '\')).AbsoluteUri
$officeArgs = @(('-env:UserInstallation=' + $profileUri),
    '--headless', '--nologo', '--nodefault', '--norestore', '--nolockcheck',
    '--convert-to', $filter, '--outdir', $job, $docx)
$officeResult = Invoke-TestProcess -Executable $office -Arguments $officeArgs `
    -WorkingDirectory $job -TimeoutMs 120000 -EnvironmentValues @{
        TEMP = $job; TMP = $job; PYTHONDONTWRITEBYTECODE = '1'
    }
Write-Utf8 (Join-Path $job 'libreoffice-stdout.txt') $officeResult.Stdout
Write-Utf8 (Join-Path $job 'libreoffice-stderr.txt') $officeResult.Stderr
if ($officeResult.ExitCode -ne 0) {
    throw "Conversion LibreOffice en echec ($($officeResult.ExitCode)). Voir $job"
}
$pdf = Join-Path $job 'source.pdf'
if (-not (Test-Path -LiteralPath $pdf -PathType Leaf)) {
    throw "PDF non produit. Voir $job"
}
if ((Get-FileHash -LiteralPath $docx -Algorithm SHA256).Hash -ne $sourceHash) {
    throw 'DOCX synthetique modifie pendant la conversion.'
}
$java = Join-Path $tools 'java\bin\java.exe'
$jar = Join-Path $tools 'vera\cli.jar'
$javaArgs = @(('-Duser.home=' + $job), ('-Djava.io.tmpdir=' + $job),
    '-cp', $jar, 'org.verapdf.apps.GreenfieldCliWrapper',
    '--format', 'xml', '--flavour', '1b', $pdf)
$validation = Invoke-TestProcess -Executable $java -Arguments $javaArgs `
    -WorkingDirectory $job -TimeoutMs 240000 -EnvironmentValues @{
        JAVA_HOME = (Join-Path $tools 'java'); TEMP = $job; TMP = $job
    }
Write-Utf8 (Join-Path $job 'verapdf.xml') $validation.Stdout
Write-Utf8 (Join-Path $job 'verapdf-stderr.txt') $validation.Stderr
$settings = New-Object System.Xml.XmlReaderSettings
$settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
$settings.XmlResolver = $null
$reader = [System.Xml.XmlReader]::Create((Join-Path $job 'verapdf.xml'), $settings)
try {
    $report = New-Object System.Xml.XmlDocument
    $report.XmlResolver = $null
    $report.Load($reader)
} finally { $reader.Dispose() }
$verdicts = @($report.SelectNodes('/report/jobs/job/validationReport'))
$summary = $report.SelectSingleNode('/report/batchSummary')
$item = $report.SelectSingleNode('/report/jobs/job/item')
$nameMatches = $false
if ($null -ne $item) {
    $nameNode = $item.SelectSingleNode('name')
    $nameMatches = $null -ne $nameNode -and $nameNode.InnerText -eq $pdf
}
if ($validation.ExitCode -ne 0 -or $verdicts.Count -ne 1 -or
    $null -eq $summary -or $summary.GetAttribute('totalJobs') -ne '1' -or
    $null -eq $item -or -not $nameMatches -or
    $item.GetAttribute('size') -ne [string](Get-Item -LiteralPath $pdf).Length -or
    $verdicts[0].GetAttribute('isCompliant') -ne 'true' -or
    $verdicts[0].GetAttribute('jobEndStatus') -ne 'normal' -or
    $verdicts[0].GetAttribute('profileName') -ne 'PDF/A-1b validation profile') {
    throw "Conformite PDF/A-1b non etablie. Voir les rapports dans $job"
}
$result = [ordered]@{
    synthetic = $true
    applicationIntegrated = $false
    isolationQualified = $false
    officeVersion = (Get-Item -LiteralPath $office).VersionInfo.ProductVersion
    sourceSha256 = $sourceHash
    pdfSha256 = (Get-FileHash -LiteralPath $pdf -Algorithm SHA256).Hash
    pdfa = 'conforme'
    createdAt = [DateTime]::UtcNow.ToString('o')
}
Write-Utf8 (Join-Path $job 'result.json') ($result | ConvertTo-Json)
Write-Host 'TEST SYNTHETIQUE REUSSI : DOCX converti, PDF/A-1b valide par veraPDF.' -ForegroundColor Green
Write-Host "Preuves conservees : $job"
Write-Host 'Ce test ne valide ni le portage dans Companion ni son isolation Windows.'
