# 检查是否具有管理员权限
function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 以管理员身份运行当前脚本
if (-not (Test-IsAdmin)) {
    $arguments = "-NoProfile -ExecutionPolicy Bypass -Command & { $($ExecutionContext.InvokeCommand.ExpandString($MyInvocation.MyCommand.Definition)) }"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    exit
}

# 下载并解压文件
$Url = "https://itefix.net/dl/free-software/cwrsync_6.2.8_x64_free.zip"
$ZipFile = "$env:TEMP\cwrsync.zip"
$RsyncFolder = "C:\Program Files\rsync"

Invoke-WebRequest $Url -OutFile $ZipFile
Expand-Archive $ZipFile -DestinationPath $RsyncFolder

# 添加到系统环境变量 Path
$systemPathKey = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
if (-not ($systemPathKey.Contains("$RsyncFolder\bin"))) {
    $newSystemPathKey = $systemPathKey + ";$RsyncFolder\bin"
    [Environment]::SetEnvironmentVariable("Path", $newSystemPathKey, [EnvironmentVariableTarget]::Machine)
}

# 更新当前 PowerShell 会话的环境变量
$env:Path += ";$RsyncFolder\bin"

# 验证安装成功
$rsyncVersion = & rsync --version
if ($LASTEXITCODE -eq 0) {
    Write-Host "Rsync installation successful!"
    # Write-Host $rsyncVersion
} else {
    Write-Host "Rsync installation failed."
}

# 暂停等待按键
Write-Host "Press any key to exit..."
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
