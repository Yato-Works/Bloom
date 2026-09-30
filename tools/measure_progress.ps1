# measure_progress.ps1 — arm the shell, open the Media tab, then sample the
# progress-bar strip repeatedly and report the fill width / rightmost lit pixel.
# A smoothly interpolated bar shows many distinct widths; a bar driven by raw
# 0.5 s SMTC polls shows a handful of plateaus.
param(
    [string]$Out = "$PSScriptRoot\..\_prog_samples.txt",
    [int]$Samples = 10,
    [int]$IntervalMs = 90,
    [string]$Strip = "700,470,560,10"    # "left,top,width,height" across the bar
)

function Parse-Nums([string]$text) {
    return @($text -split '[,\s]+' | Where-Object { $_ -ne '' } | ForEach-Object { [int]$_ })
}
$stripNums = Parse-Nums $Strip

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Shell is armed + Media tab opened by ui_probe.ps1 beforehand (KeepArmed).
$bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
$rows = @()

for ($i = 0; $i -lt $Samples; $i++) {
    $full = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $gfx = [System.Drawing.Graphics]::FromImage($full)
    $gfx.CopyFromScreen($bounds.Left, $bounds.Top, 0, 0, $full.Size)
    $gfx.Dispose()

    # Scan the strip for the rightmost pixel that is clearly not the dark track.
    $rightmost = -1
    for ($x = $stripNums[0]; $x -lt ($stripNums[0] + $stripNums[2]); $x++) {
        $px = $full.GetPixel($x, $stripNums[1] + [int]($stripNums[3] / 2))
        if ($px.R -gt 150 -or $px.G -gt 150 -or $px.B -gt 150) { $rightmost = $x }
    }
    $full.Dispose()

    $rows += ("{0} fill={1}" -f $i, $rightmost)
    Start-Sleep -Milliseconds $IntervalMs
}

$rows | Set-Content -Path $Out
$rows | ForEach-Object { Write-Output $_ }
Write-Output ("SAVED=" + $Out)