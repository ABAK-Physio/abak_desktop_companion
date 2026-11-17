# PowerShell 5.1. Reuse CdaCheck with synthetic schemas/profiles, never patient data.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Bundle,
    [Parameter(Mandatory=$true)][string]$References
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$repo = Split-Path -Parent $PSScriptRoot
$java = Join-Path $Bundle 'java\bin\java.exe'
$helper = Join-Path $repo 'assets\document_controls\CdaCheck.java'
$engine = Join-Path $References 'schematrons\moteur'
foreach ($file in @($java,$helper,(Join-Path $engine 'saxon9he.jar'))) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Ressource de test CDA absente : $file" }
}
$temp = Join-Path $env:TEMP ('abak-cda-java-test-' + [guid]::NewGuid().ToString('N'))
$refs = Join-Path $temp 'references'
$utf8 = [Text.UTF8Encoding]::new($false)
function Write-TestFile([string]$Path,[string]$Content) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    [IO.File]::WriteAllText($Path,$Content,$utf8)
}
function Run-TestJava([string]$Job) {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $java
    $info.WorkingDirectory = $Job
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $arguments = @('-Xms32m','-Xmx512m','-Dfile.encoding=UTF-8',
        '--class-path',(Join-Path $refs 'schematrons\moteur\saxon9he.jar'),$helper,$refs,$Job)
    $quoted = foreach ($value in $arguments) {
        if ($value.Contains('"') -or $value.Contains([char]0) -or $value.EndsWith('\')) {
            throw 'Argument de test CDA invalide.'
        }
        '"' + $value + '"'
    }
    $info.Arguments = $quoted -join ' '
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    try {
        if (-not $process.Start()) { throw 'Java de test non demarre.' }
        $output = $process.StandardOutput.ReadToEndAsync()
        $errorOutput = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit(60000)) {
            $process.Kill()
            $process.WaitForExit()
            throw 'Delai du test Java CDA depasse.'
        }
        return @{ Code=$process.ExitCode; Output=$output.Result; Error=$errorOutput.Result }
    } finally { $process.Dispose() }
}
try {
    New-Item -ItemType Directory -Path (Join-Path $refs 'schematrons\moteur') -Force | Out-Null
    # The engine's top-level files include the Saxon JAR and its XSL imports.
    Get-ChildItem -LiteralPath $engine -File | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $refs 'schematrons\moteur')
    }
    Write-TestFile (Join-Path $refs 'infrastructure\cda\CDA_extended.xsd') @'
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"><xs:element name="ClinicalDocument"><xs:complexType><xs:attribute name="marker" type="xs:string" use="required"/></xs:complexType></xs:element></xs:schema>
'@
    $profiles = @('structurationMinimale/ASIP-STRUCT-MIN-StrucMin','IHE',
        'CI-SIS_ModelesDeContenusCDA','CI-SIS_Modeles_ANS','terminologies/schematron/terminologie')
    foreach ($profile in $profiles) {
        Write-TestFile (Join-Path $refs ('schematrons/profils/' + $profile + '.sch')) @'
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"><pattern id="synthetic"><rule context="ClinicalDocument"><assert test="@marker = 'ok'">Synthetic profile rejection</assert></rule></pattern></schema>
'@
    }
    $cases = @(
        @{ Name='positive'; Xml='<ClinicalDocument marker="ok"/>'; Complete=$true; Xsd='true'; Failures=0 },
        @{ Name='xsd-negative'; Xml='<ClinicalDocument/>'; Complete=$true; Xsd='false'; Failures=1 },
        @{ Name='profile-negative'; Xml='<ClinicalDocument marker="bad"/>'; Complete=$true; Xsd='true'; Failures=1 },
        @{ Name='doctype-rejected'; Xml='<!DOCTYPE ClinicalDocument [<!ENTITY x "synthetic">]><ClinicalDocument marker="ok"/>'; Complete=$false },
        @{ Name='profile-missing'; Xml='<ClinicalDocument marker="ok"/>'; Complete=$false }
    )
    foreach ($case in $cases) {
        $job = Join-Path $temp $case.Name
        Write-TestFile (Join-Path $job 'document.xml') $case.Xml
        if ($case.Name -eq 'profile-missing') { Remove-Item -LiteralPath (Join-Path $refs 'schematrons/profils/IHE.sch') }
        $result = Run-TestJava $job
        $completed = Join-Path $job 'completed.txt'
        if (-not $case.Complete) {
            if ($result.Code -eq 0 -or (Test-Path -LiteralPath $completed)) {
                throw "Execution incomplete acceptee : $($case.Name)"
            }
        } else {
            if ($result.Code -ne 0 -or -not (Test-Path -LiteralPath $completed) -or
                [IO.File]::ReadAllText($completed) -ne 'ABAK-CDA-1') {
                throw "Test CDA non termine : $($case.Name). $($result.Output) $($result.Error)"
            }
            [xml]$xsd = Get-Content -LiteralPath (Join-Path $job 'xsd.xml') -Raw
            if ($xsd.xsd.completed -ne 'true' -or $xsd.xsd.valid -ne $case.Xsd) {
                throw "Verdict XSD inattendu : $($case.Name)"
            }
            for ($index=0; $index -lt 5; $index++) {
                [xml]$report = Get-Content -LiteralPath (Join-Path $job "profile-$index.xml") -Raw
                $namespaces = [Xml.XmlNamespaceManager]::new($report.NameTable)
                $namespaces.AddNamespace('s','http://purl.oclc.org/dsdl/svrl')
                if ($report.DocumentElement.LocalName -ne 'schematron-output' -or
                    $report.SelectNodes('//s:active-pattern',$namespaces).Count -eq 0 -or
                    $report.SelectNodes('//s:failed-assert',$namespaces).Count -ne $case.Failures) {
                    throw "Rapport synthetique inattendu : $($case.Name), profil $index"
                }
            }
        }
        Write-Host "TEST CDA JAVA : $($case.Name) : OK"
    }
    Write-Host 'TESTS JAVA CDA REUSSIS : 5/5. Profils synthetiques uniquement, aucune preuve de conformite clinique.'
} finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
