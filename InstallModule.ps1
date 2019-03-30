#Requires -RunAsAdministrator

$fullPath = 'C:\Program Files\WindowsPowerShell\Modules\PSStringScanner'

Robocopy $PSScriptRoot $fullPath /mir /XD .vscode .git examples testimonials images spikes /XF appveyor.yml .gitattributes .gitignore