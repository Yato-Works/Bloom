# SMTC (Global System Media Transport Controls) probe — Windows PowerShell 5.1
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Runtime.WindowsRuntime | Out-Null
[Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime] | Out-Null
[Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties, Windows.Media.Control, ContentType = WindowsRuntime] | Out-Null

$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
    $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and
    $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
})[0]

function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    [void]$netTask.Wait(-1)
    $netTask.Result
}

$mgrType = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]
$mgr = Await ($mgrType::RequestAsync()) $mgrType

Write-Output ("SESSIONS=" + $mgr.GetSessions().Count)
foreach ($s in $mgr.GetSessions()) {
    Write-Output ("  APP=" + $s.SourceAppUserModelId)
}

$cur = $mgr.GetCurrentSession()
if ($null -eq $cur) {
    Write-Output 'NO_CURRENT_SESSION'
} else {
    $info = $cur.GetPlaybackInfo()
    $props = Await ($cur.TryGetMediaPropertiesAsync()) ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties])
    Write-Output ("APP=" + $cur.SourceAppUserModelId)
    Write-Output ("STATUS=" + $info.PlaybackStatus)
    Write-Output ("TITLE=" + $props.Title)
    Write-Output ("ARTIST=" + $props.Artist)
    Write-Output ("ALBUM=" + $props.AlbumTitle)
    Write-Output ("HAS_THUMB=" + ($null -ne $props.Thumbnail))
}
