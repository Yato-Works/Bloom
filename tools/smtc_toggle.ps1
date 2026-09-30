# Toggle play/pause on the current GSMTC session — Windows PowerShell 5.1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Runtime.WindowsRuntime | Out-Null
[Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime] | Out-Null

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
$cur = $mgr.GetCurrentSession()
if ($null -eq $cur) { Write-Output 'NO_SESSION'; exit 1 }

$info = $cur.GetPlaybackInfo()
Write-Output ('before=' + $info.PlaybackStatus)
$null = Await ($cur.TryTogglePlayPauseAsync()) ([bool])
Start-Sleep -Milliseconds 800
$info2 = $cur.GetPlaybackInfo()
Write-Output ('after=' + $info2.PlaybackStatus)
