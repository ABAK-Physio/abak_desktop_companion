# PowerShell 5.1. Called by the existing installer, with administrator rights.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$ApplicationDirectory,
    [ValidateSet('Install','Remove')][string]$Mode = 'Install'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'L installation des controles documentaires exige les droits administrateur.'
}
$app = [IO.Path]::GetFullPath($ApplicationDirectory).TrimEnd('\')
$name = 'ABAKDocumentControls'
$serviceExe = Join-Path $app 'ABAKDocumentControls.exe'
$policyExe = Join-Path $app 'ABAKDocumentControlsPolicy.exe'
$manifestPath = Join-Path $app 'document_controls_installation.json'
$data = Join-Path ([Environment]::GetFolderPath('CommonApplicationData')) 'ABAK\DocumentControls'
$work = Join-Path $data 'work'
$marker = 'ABAK_DOCUMENT_CONTROLS_1'
$admin = [Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')
$system = [Security.Principal.SecurityIdentifier]::new('S-1-5-18')
$users = [Security.Principal.SecurityIdentifier]::new('S-1-5-32-545')

function Assert-NoRedirection([string]$Path) {
    $current = $Path
    while (-not [string]::IsNullOrEmpty($current)) {
        if (Test-Path -LiteralPath $current) {
            if ((Get-Item -LiteralPath $current -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw "Lien de dossier ou fichier refuse : $current"
            }
        }
        $parent = Split-Path -Parent $current
        if ($parent -eq $current) { break }
        $current = $parent
    }
}
function Set-DirectoryAcl([string]$Path, [Security.Principal.SecurityIdentifier]$Sid, [string]$Rights) {
    $acl = [Security.AccessControl.DirectorySecurity]::new()
    $acl.SetAccessRuleProtection($true, $false)
    $acl.SetOwner($admin)
    foreach ($owner in @($admin, $system)) {
        $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
            $owner, [Security.AccessControl.FileSystemRights]::FullControl,
            [Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit',
            [Security.AccessControl.PropagationFlags]::None,
            [Security.AccessControl.AccessControlType]::Allow))
    }
    if ($null -ne $Sid) {
        $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
            $Sid, [Security.AccessControl.FileSystemRights]$Rights,
            [Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit',
            [Security.AccessControl.PropagationFlags]::None,
            [Security.AccessControl.AccessControlType]::Allow))
    }
    if (Test-Path -LiteralPath $Path) { Set-Acl -LiteralPath $Path -AclObject $acl }
    else { [IO.Directory]::CreateDirectory($Path, $acl) | Out-Null }
}
function Protect-Installation {
    Assert-NoRedirection $app
    Set-DirectoryAcl $app $users 'ReadAndExecute'
    # Software files are public read/execute; only administrators may replace
    # them. Patient documents are stored elsewhere and are never visited here.
    foreach ($item in @(Get-ChildItem -LiteralPath $app -Recurse -Force)) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "Lien inattendu dans l installation : $($item.FullName)"
        }
        $acl = Get-Acl -LiteralPath $item.FullName
        $acl.SetOwner($admin)
        Set-Acl -LiteralPath $item.FullName -AclObject $acl
    }
}
function Invoke-Policy([string]$Action) {
    & $policyExe $Action
    if ($LASTEXITCODE -ne 0) { throw "Configuration des controles en echec : $Action ($LASTEXITCODE)" }
}
foreach ($path in @($app, $serviceExe, $policyExe)) { Assert-NoRedirection $path }
if (-not (Test-Path -LiteralPath $policyExe -PathType Leaf)) { throw 'Composant des controles absent de l installation.' }

Start-Transcript -Path (Join-Path $app 'document-controls-installation.log') -Append | Out-Null
try {
# Query, create and delete the one fixed service. No command shell or service
# name, executable or account supplied by an application request is accepted.
Add-Type @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
public static class AbakInstalledControlsScm {
    const string Name = "ABAKDocumentControls";
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern IntPtr OpenSCManager(string machine, string database, uint access);
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern IntPtr CreateService(IntPtr scm, string name, string display,
        uint access, uint type, uint start, uint error, string binary,
        string group, IntPtr tag, string dependencies, string account, string password);
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern IntPtr OpenService(IntPtr scm, string name, uint access);
    [DllImport("advapi32.dll", SetLastError=true)] static extern bool DeleteService(IntPtr service);
    [DllImport("advapi32.dll", EntryPoint="ChangeServiceConfig2W", SetLastError=true)]
    static extern bool ChangeServiceConfig2(IntPtr service, uint level, ref uint sidType);
    [DllImport("advapi32.dll")] static extern bool CloseServiceHandle(IntPtr handle);
    public static void Configure(string executable) {
        IntPtr scm = OpenSCManager(null, null, 3);
        if (scm == IntPtr.Zero) throw new Win32Exception();
        IntPtr service = IntPtr.Zero;
        try {
            service = OpenService(scm, Name, 2);
            if (service == IntPtr.Zero) {
                int code = Marshal.GetLastWin32Error();
                if (code != 1060) throw new Win32Exception(code);
                service = CreateService(scm, Name, "ABAK - Controles documentaires locaux",
                    0xF01FF, 0x10, 2, 1, "\"" + executable + "\"", null, IntPtr.Zero,
                    "BFE\0", @"NT AUTHORITY\LocalService", null);
                if (service == IntPtr.Zero) throw new Win32Exception();
            }
            uint sidType = 1;
            if (!ChangeServiceConfig2(service, 5, ref sidType)) throw new Win32Exception();
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
            if (service == IntPtr.Zero) {
                int code = Marshal.GetLastWin32Error();
                if (code == 1060) return;
                throw new Win32Exception(code);
            }
            if (!DeleteService(service)) throw new Win32Exception();
        } finally {
            if (service != IntPtr.Zero) CloseServiceHandle(service);
            CloseServiceHandle(scm);
        }
    }
}
'@

$existing = Get-CimInstance Win32_Service -Filter "Name='ABAKDocumentControls'"
if ($null -ne $existing) {
    if ($existing.PathName.Trim() -ne ('"' + $serviceExe + '"') -or
        $existing.StartName -notin @('NT AUTHORITY\LocalService', 'NT AUTHORITY\LOCAL SERVICE')) {
        throw 'Un service du meme nom utilise une autre installation. Aucune modification effectuee.'
    }
}
Invoke-Policy 'stop'
if ($Mode -eq 'Remove') {
    Invoke-Policy 'remove'
    [AbakInstalledControlsScm]::Remove()
    # Disposable jobs only. Reports committed with patient documents are kept.
    if (Test-Path -LiteralPath $data) {
        Assert-NoRedirection $data
        $owner = Join-Path $data 'owner-marker.txt'
        if ((Test-Path -LiteralPath $owner -PathType Leaf) -and [IO.File]::ReadAllText($owner) -eq $marker) {
            $links = @(Get-ChildItem -LiteralPath $data -Recurse -Force |
                Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint })
            if ($links.Count -eq 0) { Remove-Item -LiteralPath $data -Recurse -Force }
        }
    }
    return
}

$allowed = @($identity.User.Value)
$consoleAccount = (Get-CimInstance Win32_ComputerSystem).UserName
if (-not [string]::IsNullOrEmpty($consoleAccount)) {
    $consoleSid = ([Security.Principal.NTAccount]::new($consoleAccount)).Translate(
        [Security.Principal.SecurityIdentifier]).Value
    if ($consoleSid -match '^S-1-(5-21|12-1)-') { $allowed += $consoleSid }
}
$allowed = @($allowed | Select-Object -Unique)
if ($allowed[0] -notmatch '^S-1-(5-21|12-1)-') { throw 'Compte utilisateur du cabinet non identifie.' }
if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
    Assert-NoRedirection $manifestPath
    $old = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $allowed = @($allowed + @($old.allowedUsers) | Select-Object -Unique)
}
if ($allowed.Count -gt 16) { throw 'Liste des comptes de cette installation trop longue.' }
Protect-Installation
[AbakInstalledControlsScm]::Configure($serviceExe)
$serviceSid = ([Security.Principal.NTAccount]::new('NT SERVICE\ABAKDocumentControls')).Translate(
    [Security.Principal.SecurityIdentifier])
Assert-NoRedirection $data
if (Test-Path -LiteralPath $data) {
    $owner = Join-Path $data 'owner-marker.txt'
    if (-not (Test-Path -LiteralPath $owner -PathType Leaf) -or [IO.File]::ReadAllText($owner) -ne $marker) {
        throw 'Dossier de controle existant non reconnu.'
    }
}
$parent = Split-Path -Parent $data
Assert-NoRedirection $parent
if (-not (Test-Path -LiteralPath $parent)) { Set-DirectoryAcl $parent $users 'ReadAndExecute' }
Set-DirectoryAcl $data $serviceSid 'ReadAndExecute'
[IO.File]::WriteAllText((Join-Path $data 'owner-marker.txt'), $marker)
Assert-NoRedirection $work
Set-DirectoryAcl $work $serviceSid 'Modify'
$manifest = [ordered]@{
    manifestVersion = 1; protocol = 1; contract = 'ABAK-WINDOWS-CONTROLS-1'
    companionSha256 = (Get-FileHash -LiteralPath (Join-Path $app 'abak_desktop_companion.exe') -Algorithm SHA256).Hash.ToLowerInvariant()
    serviceSha256 = (Get-FileHash -LiteralPath $serviceExe -Algorithm SHA256).Hash.ToLowerInvariant()
    allowedUsers = @($allowed)
}
[IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 4), [Text.UTF8Encoding]::new($false))
$acl = Get-Acl -LiteralPath $manifestPath
$acl.SetOwner($admin)
Set-Acl -LiteralPath $manifestPath -AclObject $acl
Invoke-Policy 'remove'
Invoke-Policy 'install'
Invoke-Policy 'verify'
Start-Service -Name $name
$service = Get-Service -Name $name
try { $service.WaitForStatus([ServiceProcess.ServiceControllerStatus]::Running, [TimeSpan]::FromSeconds(20)) }
finally { $service.Dispose() }
Write-Host 'Controles documentaires Windows installes et demarres.'

} catch {
    Write-Host ('ERREUR : ' + $_.Exception.Message)
    throw
} finally {
    Stop-Transcript | Out-Null
}
