function Read-AZKError4124 {
    [CmdletBinding()]
    param (
        # Error message
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [string]
        $ErrorMessage
    )
    
    begin {
        Write-Verbose -Message "$(New-TimeStamp) Starting function `"$($MyInvocation.MyCommand)`""
        [string]$Year = $ErrorMessage.Split('[]')[0].Split(' ') -match '^\d{4}$'
        #$Year
        [System.Collections.Generic.List[decimal]]$Money = $ErrorMessage.Split('[]')[0].Split(' ') -match '^\d+\.\d{2}$'
        # Don't worry. Here we are splitting the string with method for any '[]' character and then splitting the result with operator for exact ', ' substring.
        $Codes = $ErrorMessage.Split('[]')[1] -split ', '
    }
    
    process {
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Creating an output object `"PSObject`""
        $OutObject = New-Object -TypeName psobject
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Processing year: $Year"
        $OutObject | Add-Member -MemberType NoteProperty -Name 'Год' -Value $Year
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Processing codes..."
        foreach ($code in $Codes) {
            $KV = ($code -split ': ') -replace '\.',''
            Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Value of key `"$($KV[0])`" is `"$($KV[1])`""
            $OutObject | Add-Member -MemberType NoteProperty -Name $KV[0] -Value $KV[1]
        }
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Processing the difference between existing obligations and planned payments:"
        $Obligation = $Money[0]
        $OutObject | Add-Member -MemberType NoteProperty -Name 'Обязательства' -Value $Obligation
        $PaymentPlanned = $Money[1]
        $OutObject | Add-Member -MemberType NoteProperty -Name 'ПлатежПлан' -Value $PaymentPlanned
        $Difference = $Obligation - $PaymentPlanned
        $OutObject | Add-Member -MemberType NoteProperty -Name 'Превышение' -Value $Difference
        $PaymentCorrect = $PaymentPlanned - $Difference
        $OutObject | Add-Member -MemberType NoteProperty -Name 'ПлатежКоррекция' -Value $PaymentCorrect
    }
    
    end {
        Write-Verbose -Message "$(New-TimeStamp) End of function `"$($MyInvocation.MyCommand)`""
        return $OutObject
    }
}
