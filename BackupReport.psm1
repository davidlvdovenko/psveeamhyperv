Import-Module PSHTML -Force

$public = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue
$private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue

foreach($importedFile in @($public + $private)){
    try{
        . $importedFile.FullName
    }
    catch{
        Write-Error -Message "Failed to import $($importedFile.FullName): $_"
    }
}

Export-ModuleMember -Function $public.Basename