param (
   [switch]$quiet = $false,
   [switch]$version = $false
)

if ($version) {
    Write-Host "Version 0.199"
    exit
}

$Error.Clear()

Configuration CFWindows {
  Node "localhost" {

    Script EnableDiskQuota
    {
      SetScript = {
        fsutil quota enforce C:
      }
      GetScript = {
        fsutil quota query C:
      }
      TestScript = {
        $query = "select * from Win32_QuotaSetting where VolumePath='C:\\'"
        return @(Get-WmiObject -query $query).State -eq 2
      }
    }

    Registry IncreaseDesktopHeapForServices
    {
        Ensure = "Present"
        Key = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems"
        ValueName = "Windows"
        ValueType = "ExpandString"
        ValueData = "%SystemRoot%\system32\csrss.exe ObjectDirectory=\Windows SharedSection=1024,20480,20480 Windows=On SubSystemType=Windows ServerDll=basesrv,1 ServerDll=winsrv:UserServerDllInitialization,3 ServerDll=sxssrv,4 ProfileControl=Off MaxRequestThreads=16"
    }

    Script SetupFirewall
    {
      TestScript = {
        $anyFirewallsDisabled = !!(Get-NetFirewallProfile -All | Where-Object { $_.Enabled -eq "False" })
        $adminRuleMissing = !(Get-NetFirewallRule -Name CFAllowAdmins -ErrorAction Ignore)
        Write-Verbose "anyFirewallsDisabled: $anyFirewallsDisabled"
        Write-Verbose "adminRuleMissing: $adminRuleMissing"
        if ($anyFirewallsDisabled -or $adminRuleMissing)
        {
          return $false
        }
        else {
          return $true
        }
      }
      SetScript = {
        $admins = New-Object System.Security.Principal.NTAccount("Administrators")
        $adminsSid = $admins.Translate([System.Security.Principal.SecurityIdentifier])

        $LocalUser = "D:(A;;CC;;;$adminsSid)"
        $otherAdmins = Get-WmiObject win32_groupuser |
          Where-Object { $_.GroupComponent -match 'administrators' } |
          ForEach-Object { [wmi]$_.PartComponent }

        foreach($admin in $otherAdmins)
        {
          $ntAccount = New-Object System.Security.Principal.NTAccount($admin.Name)
          $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
          $LocalUser = $LocalUser + "(A;;CC;;;$sid)"
        }
        New-NetFirewallRule -Name CFAllowAdmins -DisplayName "Allow admins" `
          -Description "Allow admin users" -RemotePort Any `
          -LocalPort Any -LocalAddress Any -RemoteAddress Any `
          -Enabled True -Profile Any -Action Allow -Direction Outbound `
          -LocalUser $LocalUser

        Set-NetFirewallProfile -All -DefaultInboundAction Allow -DefaultOutboundAction Block -Enabled True
      }
      GetScript = { Get-NetFirewallProfile }
    }
  }
}

if($PSVersionTable.PSVersion.Major -lt 4) {
  $shell = New-Object -ComObject Wscript.Shell
  $shell.Popup("You must be running Powershell version 4 or greater", 5, "Invalid Powershell version", 0x30)
  echo "You must be running Powershell version 4 or greater"
  exit(-1)
}

if (![bool](Test-WSMan -ErrorAction SilentlyContinue)) {
  Enable-PSRemoting -Force
}

CFWindows
Start-DscConfiguration -Wait -Path .\CFWindows -Force -Verbose

if ($Error) {
    Write-Host "Error summary:"
    foreach($ErrorMessage in $Error)
    {
    Write-Host $ErrorMessage
    }
    if (!$quiet) {
        Read-Host -Prompt "Setup failed. The above errors occurred. Press Enter to exit"
    }
} else {
    if (!$quiet) {
        Read-Host -Prompt "Setup completed successfully. Press Enter to exit"
    }
}
