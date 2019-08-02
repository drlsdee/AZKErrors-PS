function Read-AZKErrorsFromFile {
    [CmdletBinding()]
    param (
        # Path to text file with contents of AZK reply
        [Parameter()]
        [string]
        $FilePath
    )
    
    begin {
        Write-Verbose -Message "$(New-TimeStamp) Starting function `"$($MyInvocation.MyCommand)`""
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Getting content from file $FilePath."
        $FileContentRaw = Get-Content -Path $FilePath -Encoding UTF8
        if ((Get-Item -Path $FilePath).Extension -eq '.xml') {
            Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Source file is XML document. Parsing..."
            $XMLDoc = New-Object -TypeName System.Xml.XmlDocument
            $XMLDoc.LoadXml($FileContentRaw)
            if ($XMLDoc.docStatusChanged.remark) {
                Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: An XML node `"docStatusChanged.remark`" found. Reading..."
                $ErrorBody = $XMLDoc.docStatusChanged.remark
            } else {
                Write-Error -Category InvalidData -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: An XML node `"docStatusChanged.remark`" NOT found! Exiting..."
                Write-Verbose -Message "$(New-TimeStamp) EXIT of function `"$($MyInvocation.MyCommand)`""
                return
            }
        } else {
            $ErrorBody = $FileContentRaw
        }
    }
    
    process {
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Splitting content from file $FilePath."
        [array]$ErrorBodySplit = ($ErrorBody -split 'AZK-') -replace '\s+$','' | Where-Object {$_.Length -gt 0}
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Creating an output object."
        #$ErrorList = New-Object -TypeName 'System.Collections.Generic.Dictionary[int,string]'
        $ErrorList = New-Object -TypeName 'System.Collections.Generic.List[psobject]'
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Processing error messages."
        foreach ($ErrorString in $ErrorBodySplit) {
            [int]$ErrorCode = $ErrorString.Remove( $ErrorString.IndexOf('.') )
            Write-Debug -Message "[ErrorCode is]: $ErrorCode"
            [string] $ErrorMessage = $ErrorString -replace '^\d+\.\s*', ''
            Write-Debug -Message "[ErrorMESSAGE is]: $ErrorMessage"
            $ErrorObject = New-Object -TypeName psobject
            $ErrorObject | Add-Member -MemberType NoteProperty -Name 'ErrorCode' -Value $ErrorCode
            $ErrorObject | Add-Member -MemberType NoteProperty -Name 'ErrorMessage' -Value $ErrorMessage
            $ErrorList.Add($ErrorObject)
        }
    }
    
    end {
        Write-Verbose -Message "$(New-TimeStamp) End of function `"$($MyInvocation.MyCommand)`""
        return $ErrorList
    }
}

Export-ModuleMember -Function 'Read-AZKErrorsFromFile'