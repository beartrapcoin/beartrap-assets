$InputCsv = ".\approved_entries.csv"
$OutputCsv = ".\winners.csv"
$AllScoresCsv = ".\approved_entries_with_scores.csv"

$Seed = "0x8826cb4f8553f7cb568fe1969e7951ed26e327ffadde0d70808bfd1976d5738f"
$WinnersCount = 200

$rows = Import-Csv $InputCsv -Delimiter ";"

if ($rows.Count -eq 0) {
    throw "Input CSV is empty."
}

$sha = [System.Security.Cryptography.SHA256]::Create()

$result = foreach ($r in $rows) {
    $drawInput = "$Seed|$($r.EntryId)|$($r.PublicXUsername)|$($r.PublicTelegramUsername)|$($r.WalletMasked)"

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($drawInput)
    $hashBytes = $sha.ComputeHash($bytes)
    $score = -join ($hashBytes | ForEach-Object { $_.ToString("x2") })

    [PSCustomObject]@{
        EntryId = $r.EntryId
        PublicXUsername = $r.PublicXUsername
        PublicTelegramUsername = $r.PublicTelegramUsername
        WalletMasked = $r.WalletMasked
        PublicStatus = $r.PublicStatus
        DrawInput = $drawInput
        RandomScore = $score
    }
}

$sorted = @($result | Sort-Object RandomScore)

$ranked = for ($i = 0; $i -lt $sorted.Count; $i++) {
    $rank = $i + 1
    $winnerStatus = if ($rank -le $WinnersCount) { "WINNER" } else { "NOT_WINNER" }

    [PSCustomObject]@{
        DrawRank = $rank
        WinnerStatus = $winnerStatus
        EntryId = $sorted[$i].EntryId
        PublicXUsername = $sorted[$i].PublicXUsername
        PublicTelegramUsername = $sorted[$i].PublicTelegramUsername
        WalletMasked = $sorted[$i].WalletMasked
        PublicStatus = $sorted[$i].PublicStatus
        DrawInput = $sorted[$i].DrawInput
        RandomScore = $sorted[$i].RandomScore
    }
}

$ranked |
    Export-Csv $AllScoresCsv -NoTypeInformation -Encoding UTF8 -Delimiter ";"

$ranked |
    Where-Object { $_.WinnerStatus -eq "WINNER" } |
    Export-Csv $OutputCsv -NoTypeInformation -Encoding UTF8 -Delimiter ";"

Write-Host "Done."
Write-Host "Approved entries:" $ranked.Count
Write-Host "Winners:" ($ranked | Where-Object { $_.WinnerStatus -eq "WINNER" }).Count
Write-Host "Full ranked list saved to:" $AllScoresCsv
Write-Host "Winners saved to:" $OutputCsv