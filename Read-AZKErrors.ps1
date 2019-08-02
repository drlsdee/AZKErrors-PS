[string]$AZKReply = Get-Content -Path .\AZKReply.txt

$splitByDot = $AZKreply -split "\.\s"

function Split-AZKReplyText {
    param (
        [Parameter()]
        [array]
        $replyArr
    )
    [array]$ErrorCodes = $replyArr -match "^AZK-\d{4}"
    [array]$ErrorContent = $replyArr -notmatch "^AZK-\d{4}"
    [array]$Out = @()
    if ($ErrorCodes.Count -ne $ErrorContent.Count) {
        Write-Error -Message "Counts of error codes and error messages are not equal!"
        Write-Error -Message "Error codes count: $($ErrorCodes.Count)"
        Write-Error -Message "Error messages count: $($ErrorContent.Count)"
        exit
    } else {
        $Cnt = $ErrorCodes.Count
        $Ind = 0
        do {
            $Name = $ErrorCodes[$Ind] -replace "-", "_"
            $Value = $ErrorContent[$Ind]
            $msg = @{
                $Name = $Value
            }
            $Out += $msg
            $Ind++
        } while ($Ind -lt $Cnt)
    }
    return $Out
}

$ArrTmp = Split-AZKReplyText -replyArr $splitByDot -Verbose

function Parse-ErrorContent {
    param (
        [Parameter()]
        [string]
        $ErrorMessage
    )
    $MsgSplitted = $ErrorMessage -split '[\[\]]'
    $Preamble = $MsgSplitted[0].Split(' ')
    $Money = $Preamble | Where-Object {$_ -match '^\d+\.\d{2}$'}
    $Year = $Preamble | Where-Object {$_ -match '^\d{4}$'}
    
    [decimal]$Obligation = $Money[0]
    [decimal]$Payments = $Money[1]
    $Diff = $Obligation - $Payments
    $Correction = $Payments - $Diff
    
    $Codes = $MsgSplitted[1] -split ", "
    $Object = New-Object -TypeName psobject
    foreach ($code in $Codes) {
        $KV = $code -split ": "
        $Object | Add-Member -MemberType NoteProperty -Name $KV[0] -Value $KV[1]
    }
    $Object | Add-Member -MemberType NoteProperty -Name 'Год' -Value $Year
    $Object | Add-Member -MemberType NoteProperty -Name 'Обязательства' -Value $Obligation
    $Object | Add-Member -MemberType NoteProperty -Name 'Выплаты' -Value $Payments
    $Object | Add-Member -MemberType NoteProperty -Name 'Разница' -Value $Diff
    $Object | Add-Member -MemberType NoteProperty -Name 'Коррекция' -Value $Correction
    return $Object
}

$ErrorsParsed = @()
foreach ($message in $ArrTmp) {
    $ErrorsParsed += Parse-ErrorContent -ErrorMessage $message.AZK_4124
}
$ErrorsParsed = $ErrorsParsed | Select-Object -Property * -Unique
$ErrorsParsed | Select-Object -Property КЭС,КВР,КФСР,'Отраслевой код','Код субсидии',Обязательства,Выплаты,Коррекция,Разница | Format-Table
$ErrorsParsed | ConvertTo-Csv -NoTypeInformation -Delimiter "`t" | Out-File -FilePath .\ErrorsParsed2.csv