#From: https://stackoverflow.com/questions/47222779/dynamically-generating-columns-when-summarizing-powershell-objects-to-the-consol
function Get-PivotedObject {
    param (
        [Parameter(Mandatory = $true)]
        $Data,
        [Parameter(Mandatory = $true)]
        [string]$Entity,
        [Parameter(Mandatory = $true)]
        [string]$Attribute,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $PivotHeaders = $Data | Select-Object -ExpandProperty $Attribute -Unique;

    $Data | Select-Object -ExpandProperty $Entity -Unique | ForEach-Object {
        $Record = [ordered]@{
            $Entity = $_;
        }
        foreach ($Header in $PivotHeaders) {
            $Record.$Header = $Data | Where-Object { 
                ($_.$Entity -eq $Record.$Entity) -and ($_.$Attribute -eq $Header)
            } | Select-Object -ExpandProperty $Value -First 1;
            # Notice this only returns the first value it finds for a given entity and attribute

        }

        [PSCustomObject]$Record;
    }
}
