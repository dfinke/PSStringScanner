$manifestPath = "$PSScriptRoot\..\PSStringScanner.psd1"
Import-Module $manifestPath -Force

Describe "Module Health" {
    It "Should have a valid module manifest" {
        Test-ModuleManifest -Path $manifestPath | Should BeOfType ([psmoduleinfo])
    }

    It "Should have a manifest that meets PSGallery Requirements" {
        # this catches one verified case so far of a valid manifest rejected by PSGallery
        # https://github.com/dfinke/NameIT/issues/24

        Import-PowerShellDataFile -Path $manifestPath | Should BeOfType [hashtable]
    }
}