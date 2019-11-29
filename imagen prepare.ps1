param([switch]$Elevated) 

function Test-Admin { 
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent()) 
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)          } 
    if ((Test-Admin) -eq $false) {
         if ($elevated) 
            { 
                                 } 
         else { 
            Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
              } 
    exit } 

$checkScrip = Test-Path "C:\valutech\StartRecovery.ps1"
if (Test-Path $checkScrip){ 
    Remove-Item $checkScrip
}

##########################################################################################################
#                 Instalacion de programas para la creacion de imagen de Windows 10 Pro N                #
##########################################################################################################

if(Test-Path c:\temp){
    Remove-Item c:\temp -Recurse
}
clear-host 
write-host "
    *********************************************
    *              Copiando Programas...        *
    *********************************************
    " -Foreground yellow

##########################################################################################################
#                         Copiar los programas desde el servidor de archivos                             #
##########################################################################################################

mkdir $env:HOMEDRIVE\temp\programas
Copy-Item -Path "\\b1fs\Shared\ITSupport\Software\Apple Apps\iTunes\*(64-bit)\" c:\temp\programas -recurse -passthru
Copy-Item -Path "\\b1fs\Shared\ITSupport\Software\Adobe\Acrobat Reader\AcroRdrDC1801120055_en_US.exe" c:\temp\programas -recurse -passthru

#7Zip
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\Software\7-Zip\x64\7z938-x64.msi" -ArgumentList "/q" -PassThru

##########################################################################################################
#                  Decomprimir programas que lo requieren para ser instalador                            #
##########################################################################################################
$Source = $env:HOMEDRIVE + "\temp\programas\iTunes*(64-bit)\iTunes*.exe"

if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  
sz x -y $Source 

$Source = "C:\temp\programas\AcroRdrDC1801120055_en_US.exe"
sz x -y $Source 

##########################################################################################################
#                                    Instalacion de programas                                            #
##########################################################################################################
write-host "
    *********************************************
    *              Instalando Programas...      *
    *********************************************
    " -Foreground yellow

#java
$URL=(Invoke-WebRequest -UseBasicParsing https://www.java.com/en/download/manual.jsp).Content | %{[regex]::matches($_, '(?:<a title="Download Java software for Windows Online" href=")(.*)(?:">)').Groups[1].Value}
Invoke-WebRequest -UseBasicParsing -OutFile jre8.exe $URL
Start-Process .\jre8.exe '/s REBOOT=0 SPONSORS=0 AUTO_UPDATE=0' -wait

#itunes
Start-Process -Wait -FilePath ".\AppleApplicationSupport.msi" -ArgumentList "/q" -PassThru
Start-Process -Wait -FilePath ".\AppleApplicationSupport64.msi" -ArgumentList "/q" -PassThru
Start-Process -Wait -FilePath ".\AppleMobileDeviceSupport64.msi" -ArgumentList "/q" -PassThru
Start-Process -Wait -FilePath ".\AppleSoftwareUpdate.msi" -ArgumentList "/q" -PassThru
Start-Process -Wait -FilePath ".\Bonjour64.msi" -ArgumentList "/q" -PassThru

#Acrobat reader
Start-Process -Wait -FilePath ".\AcroRead.msi" -ArgumentList "/q" -PassThru
Start-Process -Wait -FilePath ".\AcroRdrDCUpd1801120055.msp" -ArgumentList "/q" -PassThru

#adb Android
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\Software\AndroidDrivers\UniversalAdbDriverSetup6.msi" -ArgumentList "/q" -PassThru

#Ccleaner
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\Software\Ccleaner\ccsetup*" -ArgumentList "/S" -PassThru

#crystal reports
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\Software\Cristal\Crystal Reports 2010 Runtime\CRforVS_redist_install_32bit_13_0_1\CRRuntime_32bit_13_0_1.msi" -ArgumentList "/q" -PassThru

#ID Fonts
Copy-Item -Path "\\b1fs\Shared\ITSupport\Software\Idautomation Complete\idfonts\*.*" C:\windows\Fonts -recurse -passthru

#OpenOffice
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\Software\Open Source\OpenOffice\Apache_OpenOffice_4.1.3_Win_x86_install_en-US.exe" -ArgumentList "/S" -PassThru

#camara c920
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\Drivers\Webcams\Logitech C920 HD Pro Web\Driverwebcam.exe" -ArgumentList "/s" -PassThru

#USB card 3.0
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\Drivers\USB Card\7 Ports PCI Express (StarTech.com)\USB3.0 Host\NEC\RENESAS-USB3-Host-Driver-30230-setup.exe" -ArgumentList "/s" -PassThru

#driver audio usb
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\Drivers\Sound Card 7.1 Startech\[CMedia CM6206] Windows USB 7.1 Audio Adapter\Setup.exe" -ArgumentList "/s" -PassThru

#driver fixture battery reader
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\Drivers\Controlador fixture battery reader\New Version\PL2303_Prolific_GPS_1013_20090319.exe" -ArgumentList "/s" -PassThru

#VCredist
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\IT Apps\Helpers\MS_VC_redist\2012\vcredist_x86.exe" -ArgumentList "/s" -PassThru
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\IT Apps\Helpers\MS_VC_redist\2015\vc_redist.x86.exe" -ArgumentList "/s" -PassThru

#Pics II 
mkdir $env:HOMEDRIVE\"PicsII\Pics Runtime"
Copy-Item -Path "\\IT-TOOLS\PicsII Update\PICS II_Upgrade.bat" "C:\PicsII\Pics Runtime\" -recurse -passthru
Copy-Item -Path "\\IT-TOOLS\PicsII Update\PICS_II.lnk" "C:\users\Public\Desktop\" -recurse -passthru

#Valutech folder
Copy-Item -Path "\\b1fs\Shared\ITSupport\IT_Stuff\tools\" "C:\Valutech\" -recurse -passthru

#Wifi TP-Link
Start-Process -Wait -FilePath "\\b1fs\Shared\ITSupport\Drivers\TPLink Wireless\Archer T6E\Setup.exe" -ArgumentList "/s" -PassThru

Write-Host "
##########################################################################################################
#                                   Terminando configuracion..                                           #
##########################################################################################################"
#Datos de activacion
Set-ItemProperty -path "hklm:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name KeyManagementServiceName -Value "b1services.valuout.com"
Set-ItemProperty -path "hklm:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name KeyManagementServicePort -Value "1688"
Set-ItemProperty -path "hklm:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name BackupProductKeyDefault -Value "MH37W-N47XK-V7XM9-C7227-GCQG9"
slmgr /ipk "MH37W-N47XK-V7XM9-C7227-GCQG9"
gpupdate

#agregar usuarios admin
Add-LocalGroupMember -Group "Administrators" -Member "ITOperator"

##########################################################################################################
#                                   Limpieza de archivos de instalacion                                  #
##########################################################################################################
set-location $env:HOMEDRIVE
Remove-Item "c:\temp" -Recurse

write-host "
                         *********************************************
                         *           Instalacion Finalizada          *
                         *          el equipo se reiniciara          *
                         *********************************************
    " -Foreground green

 