
# ABAK Desktop Companion - Windows veraPDF functional tests
# PowerShell 5.1
# Synthetic fixtures only. No DMP, CPS, installation or network access.

param(
    [Parameter(Mandatory = $true)]
    [string]$Bundle
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repo = Split-Path -Parent $PSScriptRoot
$bundlePath = [IO.Path]::GetFullPath($Bundle)

$java = Join-Path $bundlePath 'java\bin\java.exe'
$vera = Join-Path $bundlePath 'vera\cli.jar'
$fixtures = Join-Path $repo 'assets\dmp_local\pdf_cda_native'

foreach ($path in @($java, $vera)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Outil absent : $path"
    }
}

$tests = @(
    @{
        Name = 'positif_pdf.pdf'
        Expected = 'PASS'
        ExitCode = 0
    },
    @{
        Name = 'sans_xmp_pdf.pdf'
        Expected = 'FAIL'
        ExitCode = 1
    }
)

$passed = 0

foreach ($test in $tests) {
    $pdf = Join-Path $fixtures $test.Name

    if (-not (Test-Path -LiteralPath $pdf -PathType Leaf)) {
        throw "PDF synthetique absent : $pdf"
    }

    Write-Host ""
    Write-Host "Test PDF/A-1b : $($test.Name)" -ForegroundColor Cyan

    # Capture output and exit code without interpreting a
    # nonzero veraPDF exit code as a PowerShell exception.
    $stdout = Join-Path $env:TEMP (
        'abak-verapdf-out-' + [guid]::NewGuid().ToString('N') + '.txt'
    )
    $stderr = Join-Path $env:TEMP (
        'abak-verapdf-err-' + [guid]::NewGuid().ToString('N') + '.txt'
    )

    try {
        $arguments = @(
            '-cp',
            ('"' + $vera + '"'),
            'org.verapdf.apps.GreenfieldCliWrapper',
            '--flavour',
            '1b',
            '--format',
            'text',
            ('"' + $pdf + '"')
        ) -join ' '

        $process = Start-Process `
            -FilePath $java `
            -ArgumentList $arguments `
            -RedirectStandardOutput $stdout `
            -RedirectStandardError $stderr `
            -Wait `
            -PassThru `
            -NoNewWindow

        $output = Get-Content -LiteralPath $stdout -Raw
        $exitCode = $process.ExitCode

        $actual = if ($output -match '(?m)^PASS\s') {
            'PASS'
        }
        elseif ($output -match '(?m)^FAIL\s') {
            'FAIL'
        }
        else {
            'UNKNOWN'
        }

        if ($actual -ne $test.Expected -or
            $exitCode -ne $test.ExitCode) {
            $errorOutput = Get-Content -LiteralPath $stderr -Raw

            throw (
                "Verdict inattendu pour $($test.Name). " +
                "Attendu : $($test.Expected)/$($test.ExitCode). " +
                "Obtenu : $actual/$exitCode. " +
                "stderr : $errorOutput"
            )
        }

        Write-Host "Verdict : $actual"
        Write-Host "Code de sortie : $exitCode"
        Write-Host "Test reussi." -ForegroundColor Green

        $passed++
    }
    finally {
        Remove-Item -LiteralPath $stdout -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $stderr -ErrorAction SilentlyContinue
    }
}

if ($passed -ne $tests.Count) {
    throw "Tests incomplets."
}

Write-Host ""
Write-Host "Validation PDF/A-1b reussie : $passed/$($tests.Count) tests." `
    -ForegroundColor Green
