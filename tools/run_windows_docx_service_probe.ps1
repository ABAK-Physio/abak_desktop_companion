# PowerShell 5.1. Temporary service experiment with synthetic data only.
# No production Companion service or historical ABAKDocumentControlsProbe change.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$principal = [Security.Principal.WindowsPrincipal]::new(
    [Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Ouvrez PowerShell en tant qu administrateur pour creer le service temporaire.'
}
# Read-only guard: never start a new test through leftover IFEO tracing.
function Assert-NoLoaderDebugSettings {
    $root = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
        [Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
    try {
        $base = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
        foreach ($image in @('soffice.exe', 'soffice.com', 'soffice.bin')) {
            $key = $root.OpenSubKey(($base + '\' + $image), $false)
            if ($null -eq $key) { continue }
            try {
                foreach ($name in @('Debugger', 'GlobalFlag')) {
                    if ($name -in @($key.GetValueNames())) {
                        throw "Reglage de diagnostic encore present : $image / $name. Aucun nouvel essai lance."
                    }
                }
            } finally { $key.Dispose() }
        }
    } finally { $root.Dispose() }
}
Assert-NoLoaderDebugSettings
foreach ($name in @('soffice.exe', 'soffice.com', 'soffice.bin')) {
    $path = Join-Path 'C:\Program Files\LibreOffice\program' $name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Fichier LibreOffice absent : $path. Aucun nouvel essai lance."
    }
}
Write-Host 'PROBE_DIAGNOSTIC=v12 ; aucun Debugger/GlobalFlag LibreOffice configure.'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
public static class AbakDocxProbeScm {
    const string Name = "ABAKDocxConversionProbe";
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern IntPtr OpenSCManager(string machine, string database, uint access);
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern IntPtr CreateService(IntPtr scm, string name, string display,
        uint access, uint type, uint start, uint error, string binary,
        string group, IntPtr tag, string dependencies, string account, string password);
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern IntPtr OpenService(IntPtr scm, string name, uint access);
    [DllImport("advapi32.dll", SetLastError=true)]
    static extern bool DeleteService(IntPtr service);
    [DllImport("advapi32.dll", EntryPoint="ChangeServiceConfig2W", SetLastError=true)]
    static extern bool ChangeServiceConfig2(IntPtr service, uint level, ref uint sidType);
    [DllImport("advapi32.dll")] static extern bool CloseServiceHandle(IntPtr handle);
    public static void Create(string binary) {
        IntPtr scm = OpenSCManager(null, null, 3);
        if (scm == IntPtr.Zero) throw new Win32Exception();
        IntPtr service = IntPtr.Zero;
        try {
            service = CreateService(scm, Name, "ABAK synthetic DOCX conversion probe",
                0xF01FF, 0x10, 3, 1, binary, null, IntPtr.Zero, null,
                @"NT AUTHORITY\LocalService", null);
            if (service == IntPtr.Zero) throw new Win32Exception();
            // Preparation only; worker primary tokens are restricted explicitly.
            uint serviceSidType = 1;
            if (!ChangeServiceConfig2(service, 5, ref serviceSidType)) {
                int error = Marshal.GetLastWin32Error();
                DeleteService(service);
                throw new Win32Exception(error);
            }
        } finally {
            if (service != IntPtr.Zero) CloseServiceHandle(service);
            CloseServiceHandle(scm);
        }
    }
    public static void Remove() {
        IntPtr scm = OpenSCManager(null, null, 1);
        if (scm == IntPtr.Zero) throw new Win32Exception();
        IntPtr service = IntPtr.Zero;
        try {
            service = OpenService(scm, Name, 0x10000);
            if (service == IntPtr.Zero) throw new Win32Exception();
            if (!DeleteService(service)) throw new Win32Exception();
        } finally {
            if (service != IntPtr.Zero) CloseServiceHandle(service);
            CloseServiceHandle(scm);
        }
    }
}
'@

$repo = Split-Path -Parent $PSScriptRoot
$binaries = Join-Path $repo 'build\docx_service_probe_file_access_v12\Release'
$serviceName = 'ABAKDocxConversionProbe'
$programRoot = 'C:\Program Files\ABAK\DocxConversionProbe'
$dataRoot = 'C:\ProgramData\ABAK\DocxConversionProbe'
$work = Join-Path $dataRoot 'work'
$marker = 'ABAK_DOCX_SYNTHETIC_PROBE_V1'
$serviceExe = Join-Path $programRoot 'abak_docx_probe_service.exe'
$controllerExe = Join-Path $programRoot 'abak_docx_probe_controller.exe'
$createdService = $false
$controller = $null
$controllerStarted = $false
$failure = $null
$cleanupFailure = $null
$evidence = Join-Path ([Environment]::GetFolderPath('Desktop')) (
    'ABAK_DOCX_Service_Test_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '_' +
    [guid]::NewGuid().ToString('N').Substring(0, 8))

function Assert-NoRedirection([string]$Path) {
    $current = $Path
    while (-not [string]::IsNullOrEmpty($current)) {
        if (Test-Path -LiteralPath $current) {
            $item = Get-Item -LiteralPath $current -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw "Dossier redirige refuse : $current"
            }
        }
        $parent = Split-Path -Parent $current
        if ($parent -eq $current) { break }
        $current = $parent
    }
}
function Assert-TestRoot([string]$Path) {
    Assert-NoRedirection $Path
    if (Test-Path -LiteralPath $Path) {
        $file = Join-Path $Path 'probe-owner.txt'
        if (-not (Test-Path -LiteralPath $file -PathType Leaf) -or
            [IO.File]::ReadAllText($file) -ne $marker) {
            throw "Dossier existant non reconnu comme essai synthetique : $Path"
        }
    }
}
function Set-TestDirectory([string]$Path, [string]$ServiceRights) {
    $acl = [Security.AccessControl.DirectorySecurity]::new()
    $acl.SetAccessRuleProtection($true, $false)
    $admin = [Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')
    $system = [Security.Principal.SecurityIdentifier]::new('S-1-5-18')
    $acl.SetOwner($admin)
    foreach ($sid in @($admin, $system)) {
        $rule = [Security.AccessControl.FileSystemAccessRule]::new(
            $sid, [Security.AccessControl.FileSystemRights]::FullControl,
            [Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit',
            [Security.AccessControl.PropagationFlags]::None,
            [Security.AccessControl.AccessControlType]::Allow)
        $acl.AddAccessRule($rule)
    }
    $rule = [Security.AccessControl.FileSystemAccessRule]::new(
        $script:serviceSid, [Security.AccessControl.FileSystemRights]$ServiceRights,
        [Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit',
        [Security.AccessControl.PropagationFlags]::None,
        [Security.AccessControl.AccessControlType]::Allow)
    $acl.AddAccessRule($rule)
    if (Test-Path -LiteralPath $Path) {
        Set-Acl -LiteralPath $Path -AclObject $acl
    } else {
        [IO.Directory]::CreateDirectory($Path, $acl) | Out-Null
    }
}
function Write-Utf8([string]$Path, [string]$Text) {
    [IO.File]::WriteAllText($Path, $Text, ([Text.UTF8Encoding]::new($false)))
}
function Set-TestFile([string]$Path) {
    Assert-NoRedirection $Path
    $acl = [Security.AccessControl.FileSecurity]::new()
    $acl.SetAccessRuleProtection($true, $false)
    $admin = [Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')
    $system = [Security.Principal.SecurityIdentifier]::new('S-1-5-18')
    $acl.SetOwner($admin)
    foreach ($sid in @($admin, $system)) {
        $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
            $sid, [Security.AccessControl.FileSystemRights]::FullControl,
            [Security.AccessControl.AccessControlType]::Allow))
    }
    $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
        $script:serviceSid, [Security.AccessControl.FileSystemRights]::ReadAndExecute,
        [Security.AccessControl.AccessControlType]::Allow))
    Set-Acl -LiteralPath $Path -AclObject $acl
}
# All fixtures belong to Administrators, have protected DACLs and stay in
# the dedicated prototype root. No real user or application file is tested.
function New-SyntheticAccessFixtures {
    $folder = Join-Path $programRoot 'access-fixtures'
    Assert-NoRedirection $folder
    Set-TestDirectory $folder 'ReadAndExecute'
    $admin = [Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')
    $system = [Security.Principal.SecurityIdentifier]::new('S-1-5-18')
    $local = [Security.Principal.SecurityIdentifier]::new('S-1-5-19')
    $everyone = [Security.Principal.SecurityIdentifier]::new('S-1-1-0')
    $cases = @(
        @{ Name = 'service.txt'; Sid = $script:serviceSid; Rights = 'Read,Write,Synchronize' }
        @{ Name = 'localservice.txt'; Sid = $local; Rights = 'Read,Write,Synchronize' }
        @{ Name = 'everyone.txt'; Sid = $everyone; Rights = 'Read,Write,Synchronize' }
        @{ Name = 'admin.txt'; Sid = $null; Rights = $null }
        @{ Name = 'readonly.txt'; Sid = $script:serviceSid; Rights = 'Read,Synchronize' }
    )
    $script:accessFixtureHashes = @{}
    $descriptions = @()
    foreach ($case in $cases) {
        $path = Join-Path $folder $case.Name
        Assert-NoRedirection $path
        Write-Utf8 $path 'ABAK_SYNTHETIC_ACCESS_V12'
        $acl = [Security.AccessControl.FileSecurity]::new()
        $acl.SetAccessRuleProtection($true, $false)
        $acl.SetOwner($admin)
        foreach ($sid in @($admin, $system)) {
            $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
                $sid, [Security.AccessControl.FileSystemRights]::FullControl,
                [Security.AccessControl.AccessControlType]::Allow))
        }
        if ($null -ne $case.Sid) {
            $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
                $case.Sid, [Security.AccessControl.FileSystemRights]$case.Rights,
                [Security.AccessControl.AccessControlType]::Allow))
        }
        Set-Acl -LiteralPath $path -AclObject $acl
        $script:accessFixtureHashes[$path] = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
        $actual = Get-Acl -LiteralPath $path
        if ($actual.GetOwner([Security.Principal.SecurityIdentifier]).Value -ne $admin.Value -or
            -not $actual.AreAccessRulesProtected) {
            throw "Proprietaire ou protection du fichier factice inattendu : $path"
        }
        $descriptions += [PSCustomObject]@{
            Name = $case.Name
            Owner = $actual.GetOwner([Security.Principal.SecurityIdentifier]).Value
            Sddl = $actual.GetSecurityDescriptorSddlForm([Security.AccessControl.AccessControlSections]::All)
            SHA256 = $script:accessFixtureHashes[$path]
        }
    }
    Write-Utf8 (Join-Path $evidence 'file-access-fixtures.json') ($descriptions | ConvertTo-Json -Depth 4)
}
function Assert-SyntheticAccessFixturesUnchanged {
    foreach ($path in $script:accessFixtureHashes.Keys) {
        Assert-NoRedirection $path
        if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $script:accessFixtureHashes[$path]) {
            throw "Contenu d un fichier factice modifie : $path"
        }
    }
}

function Create-SyntheticDocx([string]$Path) {
    $parts = [ordered]@{
        '[Content_Types].xml' = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>
'@
        '_rels/.rels' = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>
'@
        'word/document.xml' = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:r><w:t>ABAK - Test synthetique de conversion sous service Windows</w:t></w:r></w:p><w:p><w:r><w:t>Aucune donnee patient. Kin&#233;sith&#233;rapie et &#233;valuation.</w:t></w:r></w:p><w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/></w:sectPr></w:body></w:document>
'@
    }
    $archive = [IO.Compression.ZipFile]::Open($Path, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($name in $parts.Keys) {
            $entry = $archive.CreateEntry($name)
            $stream = $entry.Open()
            try {
                $bytes = [Text.Encoding]::UTF8.GetBytes($parts[$name])
                $stream.Write($bytes, 0, $bytes.Length)
            } finally { $stream.Dispose() }
        }
    } finally { $archive.Dispose() }
}

foreach ($name in @('abak_docx_probe_service.exe', 'abak_docx_probe_controller.exe')) {
    if (-not (Test-Path -LiteralPath (Join-Path $binaries $name) -PathType Leaf)) {
        throw "Binaire non compile : $name"
    }
}
if ($null -ne (Get-Service -Name $serviceName -ErrorAction SilentlyContinue)) {
    throw 'Le service d essai existe deja. Aucune modification effectuee ; transmettre ce message.'
}
Assert-TestRoot $programRoot
Assert-TestRoot $dataRoot
foreach ($path in @((Split-Path -Parent $programRoot), (Split-Path -Parent $dataRoot))) {
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        throw "Dossier parent attendu absent : $path"
    }
}
New-Item -ItemType Directory -Path $evidence | Out-Null
Write-Host "Preuves de l essai : $evidence"
try {
    [AbakDocxProbeScm]::Create(('"' + $serviceExe + '"'))
    $createdService = $true
    $account = [Security.Principal.NTAccount]::new(('NT SERVICE\' + $serviceName))
    $script:serviceSid = $account.Translate([Security.Principal.SecurityIdentifier])
    Set-TestDirectory $programRoot 'ReadAndExecute'
    Set-TestDirectory $dataRoot 'ReadAndExecute'
    Write-Utf8 (Join-Path $programRoot 'probe-owner.txt') $marker
    Write-Utf8 (Join-Path $dataRoot 'probe-owner.txt') $marker
    Set-TestFile (Join-Path $programRoot 'probe-owner.txt')
    Set-TestFile (Join-Path $dataRoot 'probe-owner.txt')
    Assert-NoRedirection $work
    Set-TestDirectory $work 'Modify'
    New-SyntheticAccessFixtures
    foreach ($name in @('abak_docx_probe_service.exe', 'abak_docx_probe_controller.exe')) {
        $source = Join-Path $binaries $name
        $target = Join-Path $programRoot $name
        Assert-NoRedirection $target
        Copy-Item -LiteralPath $source -Destination $target -Force
        Set-TestFile $target
        if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -ne
            (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash) {
            throw "Copie differente du binaire compile : $name"
        }
    }
    $synthetic = Join-Path $evidence 'source.docx'
    Create-SyntheticDocx $synthetic
    $installedSource = Join-Path $programRoot 'source.docx'
    Assert-NoRedirection $installedSource
    Copy-Item -LiteralPath $synthetic -Destination $installedSource -Force
    Set-TestFile $installedSource
    if ((Get-FileHash -LiteralPath $synthetic -Algorithm SHA256).Hash -ne
        (Get-FileHash -LiteralPath $installedSource -Algorithm SHA256).Hash) {
        throw 'Copie du DOCX synthetique differente.'
    }
    $resultPath = Join-Path $work 'result.txt'
    foreach ($name in @('file-access-probe.txt', 'result.txt', 'execution-stage.txt', 'office-engine-diagnostic.txt', 'network-probes.txt', 'office-startup-diagnostic.txt', 'office-diagnostic.txt', 'restricted-launch-diagnostic.txt', 'restricted-worker-diagnostic.txt')) {
        $previous = Join-Path $work $name
        Assert-NoRedirection $previous
        if (Test-Path -LiteralPath $previous) { Remove-Item -LiteralPath $previous }
    }
    $existingJobs = @(Get-ChildItem -LiteralPath $work -Directory -Force | Select-Object -ExpandProperty Name)
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $controllerExe
    $info.Arguments = 'run'
    $info.WorkingDirectory = $programRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $controller = [Diagnostics.Process]::new()
    $controller.StartInfo = $info
    if (-not $controller.Start()) { throw 'Coordinateur non demarre.' }
    $controllerStarted = $true
    $stdout = $controller.StandardOutput.ReadToEndAsync()
    $stderr = $controller.StandardError.ReadToEndAsync()
    if (-not $controller.WaitForExit(300000)) { throw 'Delai du coordinateur depasse.' }
    if (-not $stdout.Wait(5000) -or -not $stderr.Wait(5000)) {
        throw 'Sorties du coordinateur incompletes.'
    }
    Write-Utf8 (Join-Path $evidence 'controller-stdout.txt') $stdout.Result
    Write-Utf8 (Join-Path $evidence 'controller-stderr.txt') $stderr.Result
    Write-Host $stdout.Result
    Write-Host $stderr.Result
    foreach ($name in @('file-access-probe.txt', 'result.txt', 'execution-stage.txt', 'office-engine-diagnostic.txt', 'network-probes.txt', 'office-startup-diagnostic.txt', 'office-diagnostic.txt', 'restricted-launch-diagnostic.txt', 'restricted-worker-diagnostic.txt')) {
        $trace = Join-Path $work $name
        if (Test-Path -LiteralPath $trace -PathType Leaf) {
            Assert-NoRedirection $trace
            Copy-Item -LiteralPath $trace -Destination (Join-Path $evidence $name)
            Write-Host ('--- ' + $name + ' ---')
            Write-Host ([IO.File]::ReadAllText($trace))
        }
    }
    foreach ($job in @(Get-ChildItem -LiteralPath $work -Directory -Force)) {
        if ($job.Name -in $existingJobs) { continue }
        if ($job.Name -notlike 'job-*') { continue }
        $entries = @($job) + @(Get-ChildItem -LiteralPath $job.FullName -Recurse -Force)
        if (@($entries | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }).Count -ne 0) {
            throw 'Lien inattendu dans les traces : collecte interrompue.'
        }
        Copy-Item -LiteralPath $job.FullName -Destination $evidence -Recurse
        foreach ($captureName in @('restricted-worker-output.txt', 'office-startup-output.txt', 'office-output.txt')) {
            $capturePath = Join-Path $job.FullName $captureName
            if (Test-Path -LiteralPath $capturePath -PathType Leaf) {
                Write-Host ('--- ' + $captureName + ' ---')
                $captureText = [IO.File]::ReadAllText($capturePath)
                if ($captureText.Length -gt 16000) {
                    Write-Host $captureText.Substring(0, 16000)
                    Write-Host 'Affichage limite ; journal complet conserve dans les preuves.'
                } else { Write-Host $captureText }
            }
        }
    }
    Assert-SyntheticAccessFixturesUnchanged
    if ($controller.ExitCode -ne 0) { throw "Essai sous service en echec : code $($controller.ExitCode)." }
    $accessTrace = Join-Path $evidence 'file-access-probe.txt'
    if (-not (Test-Path -LiteralPath $accessTrace -PathType Leaf) -or
        [IO.File]::ReadAllText($accessTrace) -notmatch '(?m)^FILE_ACCESS_MATRIX=EXPECTED_RESULTS\r?$') {
        throw 'Matrice des acces factices non confirmee.'
    }
    if (-not (Test-Path -LiteralPath (Join-Path $evidence 'result.txt')) -or
        [IO.File]::ReadAllText((Join-Path $evidence 'result.txt')) -notmatch '(?m)^SYNTHETIC_SERVICE_CONVERSION=PASS\r?$') {
        throw 'Resultat prive de conversion non confirme.'
    }
} catch {
    $failure = $_.Exception.Message
    Write-Utf8 (Join-Path $evidence 'script-error.txt') $failure
} finally {
    if ($createdService) {
        try {
            $service = Get-Service -Name $serviceName -ErrorAction Stop
            try {
                if ($service.Status -ne 'Stopped') {
                    $service.Stop()
                    $service.WaitForStatus([ServiceProcess.ServiceControllerStatus]::Stopped, [TimeSpan]::FromSeconds(15))
                }
            } finally { $service.Dispose() }
            [AbakDocxProbeScm]::Remove()
            Write-Host 'Service temporaire supprime.'
        } catch {
            $cleanupFailure = $_.Exception.Message
            Write-Utf8 (Join-Path $evidence 'cleanup-error.txt') $cleanupFailure
        }
    }
    if ($null -ne $controller) {
        try {
            if ($controllerStarted -and -not $controller.HasExited) { $controller.Kill(); $controller.WaitForExit(5000) | Out-Null }
        } finally { $controller.Dispose() }
    }
    Write-Host "Traces conservees : $evidence"
    Write-Host 'Les dossiers prives de cet essai sont conserves. Le prototype historique reste inchange.'
}
if ($null -ne $cleanupFailure) { throw "Nettoyage du service incomplet : $cleanupFailure" }
if ($null -ne $failure) { throw $failure }
Write-Host 'CONTROLES DES ACCES FACTICES ET CONVERSION REUSSIS. Isolation complete non qualifiee.' -ForegroundColor Green
