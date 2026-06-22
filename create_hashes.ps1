$files = @(
    "approved_entries.csv",
    "approved_entries_with_scores.csv",
    "winners.csv",
    "draw_seed.txt",
    "draw.ps1"
)

$lines = @()
$lines += "BearTrap Airdrop Draw - SHA256 File Hashes"
$lines += ""
$lines += "Block number: 105742873"
$lines += "Block hash: 0x8826cb4f8553f7cb568fe1969e7951ed26e327ffadde0d70808bfd1976d5738f"
$lines += ""

foreach ($file in $files) {
    $hash = (Get-FileHash ".\$file" -Algorithm SHA256).Hash
    $lines += "File: $file"
    $lines += "SHA256: $hash"
    $lines += ""
}

$lines | Set-Content .\file_hashes_sha256.txt -Encoding UTF8