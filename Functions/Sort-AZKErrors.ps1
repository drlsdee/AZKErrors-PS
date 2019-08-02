function Sort-AZKErrors {
    [CmdletBinding()]
    param (
        # The custom object must contain properties both [int]ErrorCode and [string]ErrorMessage
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [psobject]
        $AZKError
    )
    
    begin {
        Write-Verbose -Message "$(New-TimeStamp) Starting function `"$($MyInvocation.MyCommand)`""
        Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Check input object:"
        if (-not ($AZKError.ErrorCode -and $AZKError.ErrorMessage)) {
            Write-Warning -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: The input object does not contain required properties!"
            return
        } else {
            Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Input object is valid. Continue..."
            $ErrorCode = $AZKError.ErrorCode
            Write-Verbose -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Error code found: $ErrorCode"
            $ErrorMessage = $AZKError.ErrorMessage
        }
    }
    
    process {
        switch ($ErrorCode) {
            '4124' {
                $OutObject = Read-AZKError4124 -ErrorMessage $ErrorMessage
            }
            Default {
                Write-Warning -Message "$(New-TimeStamp) [$($MyInvocation.MyCommand)]: Unknown error code: `"$ErrorCode`"!"
                return
            }
        }
    }
    
    end {
        Write-Verbose -Message "$(New-TimeStamp) End of function `"$($MyInvocation.MyCommand)`""
        return $OutObject
    }
}
