# Import functions:
[array]$Functions = Get-ChildItem -Path "$PSScriptRoot\Functions" -File -Filter '*.ps1' | Resolve-Path -Relative

$Functions | ForEach-Object -Process {
    . $_
}
function Read-AZKErrors {
    [CmdletBinding()]
    param (
        # Path to source file
        [Parameter()]
        [string]
        $FilePath,

        # Path to output file
        [Parameter()]
        [string]
        $OutFile
    )
    
    begin {
        Write-Verbose -Message "$(New-TimeStamp) Starting function `"$($MyInvocation.MyCommand)`""
        if (-not $FilePath) {
            Write-Warning -Message  "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Path to source file not specified! Try to search in current location..."
            [array]$probeSourceFiles = Get-ChildItem -Path (Get-Location).Path -File | Where-Object {$_.Extension -in @('.txt','.xml') } | Resolve-Path -Relative
            if (-not $probeSourceFiles) {
                Write-Warning -Message  "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: NOTHING FOUND!"
                return
            } elseif ($probeSourceFiles.Count -eq 1) {
                $FilePath = $probeSourceFiles[0]
            } else {
                $FilePath = $probeSourceFiles | Out-GridView -Title 'SELECT SOURCE FILE AND PRESS `"OK`"' -PassThru
            }
        }
        if (-not $OutFile) {
            Write-Warning -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Output file not specified!"
            $OutFile = "$env:HOMEDRIVE$env:HOMEPATH\Desktop\OutFile.csv"
            Write-Warning -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Result will be saved in file: `"$OutFile`"."
        }
    }
    
    process {
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Processing the file: `"$FilePath`"..." -Verbose
        $ErrorsRaw = Read-AZKErrorsFromFile -FilePath $FilePath
        $ErrorsParsed = $ErrorsRaw | ForEach-Object -Process {
            Sort-AZKErrors -AZKError $_
        }
        $ErrorsParsed = $ErrorsParsed | Select-Object -Property * -Unique
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Saving result in the file: `"$OutFile`"..."
        $ErrorsParsed | Export-Csv -Path $OutFile -Delimiter ';' -Encoding UTF8
    }
    
    end {
        Write-Verbose -Message "$(New-TimeStamp) End of function `"$($MyInvocation.MyCommand)`""
        return $ErrorsParsed | Format-Table -AutoSize -Property *
    }
}
Export-ModuleMember -Function 'Read-AZKErrors'