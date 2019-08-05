﻿$Script:SBForestReplication = {
    $Replication = Start-TestProcessing -Test "Forest Replication" -Level 1 -ExpectedStatus $true -OutputRequired {
        Get-WinTestReplication -Status $true
    }
    foreach ($_ in $Replication) {
        Test-Value -TestName "Replication from $($_.Server) to $($_.ServerPartner)" -Object $_ -Property 'Status' -ExpectedValue $true -Level 2 -PropertExtendedValue 'StatusMessage'
    }
}