function Start-TestimoReportSection {
    [cmdletBinding()]
    param(
        [string] $Name,
        [Array] $Data,
        [System.Collections.IDictionary]$Information,
        [Scriptblock]$SourceCode,
        [PSCustomObject] $Results,
        [Array] $WarningsAndErrors,
        [switch] $HideSteps
    )
    [Array] $PassedTestsSingular = $Results | Where-Object { $_.Status -eq $true }
    [Array] $FailedTestsSingular = $Results | Where-Object { $_.Status -eq $false }
    [Array] $SkippedTestsSingular = $Results | Where-Object { $_.Status -ne $true -and $_.Status -ne $false }

    New-HTMLSection -HeaderText $Name -HeaderBackGroundColor CornflowerBlue -Direction column {
        New-HTMLSection -Invisible -Direction column {
            New-HTMLSection -HeaderText 'Information' {
                New-HTMLContainer {
                    New-HTMLChart {
                        New-ChartPie -Name 'Passed' -Value ($PassedTestsSingular.Count) -Color $ColorPassed
                        New-ChartPie -Name 'Failed' -Value ($FailedTestsSingular.Count) -Color $ColorFailed
                        New-ChartPie -Name 'Skipped' -Value ($SkippedTestsSingular.Count) -Color $ColorSkipped
                    } -Height 250
                    New-HTMLText -Text @(
                        "Below command was used to generate and asses current data that is visible in this report. "
                        "In case there are more information required feel free to confirm problems found yourself. "
                    ) -FontSize 10pt
                    New-HTMLCodeBlock -Code $SourceCode -Style 'PowerShell' -Theme enlighter
                    if ($WarningsAndErrors) {
                        New-HTMLSection -HeaderText 'Warnings & Errors' -HeaderBackGroundColor OrangePeel {
                            New-HTMLTable -DataTable $WarningsAndErrors -Filtering -PagingLength 7
                        }
                    }
                } #-Width 35%
                New-HTMLContainer {
                    if ($Information.Source.Details) {
                        if ($Information.Source.Details.Description) {
                            New-HTMLText -Text $Information.Source.Details.Description -FontSize 10pt
                        }
                        if ($Information.Source.Details.Resources) {
                            New-HTMLText -LineBreak
                            New-HTMLText -Text 'Following resources may be helpful to understand this topic ', ', please make sure to read those to understand this topic before following any instructions.' -FontSize 10pt -FontWeight bold, normal
                            New-HTMLList -FontSize 10pt {
                                foreach ($Resource in $Information.Source.Details.Resources) {
                                    if ($Resource.StartsWith('[')) {
                                        New-HTMLListItem -Text $Resource
                                    } else {
                                        # Since the link is given in pure form, we want to convert it to markdown link
                                        $Resource = "[$Resource]($Resource)"
                                        New-HTMLListItem -Text $Resource
                                    }
                                }
                            }
                        }
                    }
                    New-HTMLText -FontSize 10pt -Text 'Summary of Test results for ', $Name -FontWeight bold
                    New-HTMLText -FontSize 10pt -Text @(
                        'If any of the tests below have '
                        'Status',
                        ' set to '
                        ' FALSE ',
                        'AD Team needs to investigate according to the steps provided or using their internal processes (for example SOP). '
                        "It's important to have a read of attached blog posts to understand more about described problems. "
                        "Please keep in mind that while Status may be "
                        "TRUE"
                        " or "
                        "FALSE"
                        " it's important to take into account "
                        "Importance"
                        " and "
                        "Action"
                        " columns. "
                    ) -FontWeight normal, bold, normal, bold, normal, normal, normal, bold, normal, bold, normal, bold, normal, bold, normal
                    New-HTMLTable -DataTable $Results {
                        #New-HTMLTableCondition -Name 'Action' -Value 'Informational' -BackgroundColor DeepSkyBlue -Row
                        #New-HTMLTableCondition -Name 'Action' -Value 'Recommended' -BackgroundColor MediumTurquoise -Row
                        #New-HTMLTableCondition -Name 'Action' -Value 'Must Implement/Have' -BackgroundColor Aquamarine -Row

                        New-HTMLTableCondition -Name 'Status' -Value $true -BackgroundColor $ColorPassed -Color $ColorPassedText #-Row
                        New-HTMLTableCondition -Name 'Status' -Value $false -BackgroundColor $ColorFailed -Color $ColorFailedText #-Row
                        New-HTMLTableCondition -Name 'Status' -Value $null -BackgroundColor $ColorSkipped -Color $ColorSkippedText #-Row
                    } -Filtering
                }
            }
        }
        # If there is no data to display we don't want to add empty table and section to the report. It makes no sense to take useful resources.
        if ($Data) {
            New-HTMLSection -HeaderText 'Data' {
                New-HTMLContainer {
                    if ($Information.DataInformation) {
                        & $Information.DataInformation
                    }
                    New-HTMLTable -DataTable $Data -Filtering {
                        if ($Information.DataHighlights) {
                            & $Information.DataHighlights
                        }
                    } -PagingLength 7
                }
            }
        }
        if ($Information.Solution -and $HideSteps.IsPresent -eq $false) {
            New-HTMLSection -Name 'Solution' {
                & $Information.Solution
            }
        }
    }
}