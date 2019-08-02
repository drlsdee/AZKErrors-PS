# Import submodules:
[array]$functionsPublic = Get-ChildItem -Path .\Functions\Public -File -Filter '*.psm1' | Resolve-Path -Relative
[array]$functionsPrivate = Get-ChildItem -Path .\Functions\Private -File -Filter '*.psm1' | Resolve-Path -Relative
[array]$functionsAll = $functionsPublic + $functionsPrivate

foreach ($func in $functionsAll) {
    Import-Module -Name $func -Verbose
}

[array]$testErrorBody = Read-AZKErrorsFromFile -FilePath .\ProtocolNegative.xml -Verbose
$testErrorBody | Get-Member -MemberType NoteProperty

# Remove imported submodules:
foreach ($func in $functionsAll) {
    $modToRemove = (Split-Path -Path $func -Leaf) -replace '.psm1', ''
    Remove-Module -Name $modToRemove -Verbose
}
