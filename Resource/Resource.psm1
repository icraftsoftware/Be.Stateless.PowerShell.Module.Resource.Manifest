#region Copyright & License

# Copyright © 2012 - 2020 François Chabot
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#endregion

Set-StrictMode -Version Latest

function Compare-Item {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateScript( { $_.GetType().Name -eq 'PSCustomObject' })]
        [PSCustomObject]
        $ReferenceItem,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [PSCustomObject]
        $DifferenceItem
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $referenceProperties = @(Get-Member -InputObject $ReferenceItem -MemberType  NoteProperty, ScriptProperty | Select-Object -ExpandProperty Name)
    $differenceProperties = @(Get-Member -InputObject $DifferenceItem -MemberType  NoteProperty, ScriptProperty | Select-Object -ExpandProperty Name)
    $referenceProperties + $differenceProperties | Select-Object -Unique -PipelineVariable key | ForEach-Object -Process {
        if ($referenceProperties.Contains($key) -and !$differenceProperties.Contains($key)) {
            [PSCustomObject]@{Property = $key ; ReferenceValue = $ReferenceItem.$key ; SideIndicator = '<' ; DifferenceValue = $null } | Tee-Object -Variable difference
            Write-Verbose -Message $difference
        } elseif (!$referenceProperties.Contains($key) -and $differenceProperties.Contains($key)) {
            [PSCustomObject]@{Property = $key ; ReferenceValue = $null ; SideIndicator = '>' ; DifferenceValue = $DifferenceItem.$key } | Tee-Object -Variable difference
            Write-Verbose -Message $difference
        } else {
            $referenceValue, $differenceValue = $ReferenceItem.$key, $DifferenceItem.$key
            if ($referenceValue -ne $differenceValue) {
                [PSCustomObject]@{Property = $key ; ReferenceValue = $referenceValue ; SideIndicator = '<>' ; DifferenceValue = $differenceValue } | Tee-Object -Variable difference
                Write-Verbose -Message $difference
            }
        }
    }
}

function New-Item {
    [CmdletBinding(DefaultParameterSetName = 'file-resource')]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'named-resource')]
        [Parameter(Mandatory = $true, ParameterSetName = 'file-resource')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Resource,

        [Parameter(Mandatory = $true, ParameterSetName = 'named-resource')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'file-resource')]
        [ValidateScript( { $_ | Test-Path -PathType Leaf } )]
        [psobject[]]
        $Path,

        [Parameter(Mandatory = $false, ParameterSetName = 'named-resource')]
        [Parameter(Mandatory = $false, ParameterSetName = 'file-resource')]
        [ValidateScript( { $_ -is [bool] -or $_ -is [ScriptBlock] })]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Condition,

        [Parameter(DontShow, Mandatory = $false, ParameterSetName = 'named-resource', ValueFromRemainingArguments = $true)]
        [Parameter(DontShow, Mandatory = $false, ParameterSetName = 'file-resource', ValueFromRemainingArguments = $true)]
        [ValidateNotNullOrEmpty()]
        [object[]]
        $UnboundArguments = @()
    )

    function Update-Item {
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        param (
            [Parameter(Mandatory = $true)]
            [ValidateNotNull()]
            [PSCustomObject]
            $Item,

            [Parameter(Mandatory = $true)]
            [AllowEmptyCollection()]
            [psobject[]]
            $Properties
        )
        process {
            $DynamicProperties = @{ }
            if ($null -ne $Condition) {
                $DynamicProperties.Add('Condition', $Condition)
            }
            $Properties | ForEach-Object -Process {
                switch -regex ($_) {
                    # parse parameter name
                    '^-(\w+)$' {
                        $lastParameterName = $matches[1]
                        $DynamicProperties.Add($matches[1], $null)
                        break
                    }
                    # parse values of last parsed parameter
                    default {
                        $DynamicProperties.$lastParameterName += $_
                        break
                    }
                }
            }
            $DynamicProperties.Keys | ForEach-Object -Process {
                if ($DynamicProperties.$_ -is [ScriptBlock]) {
                    Add-Member -InputObject $item -MemberType ScriptProperty -Name $_ -Value $DynamicProperties.$_
                } else {
                    Add-Member -InputObject $item -MemberType NoteProperty -Name $_ -Value $DynamicProperties.$_
                }
            }
            $Item
        }
    }

    switch ( $PSCmdlet.ParameterSetName) {
        'named-resource' {
            $Name | ForEach-Object -Process {
                $item = New-Object -TypeName PSCustomObject
                Add-Member -InputObject $item -MemberType NoteProperty -Name Name -Value $_
                Update-Item -Item $item -Properties $UnboundArguments
            }
        }
        'file-resource' {
            $Path | ForEach-Object -Process {
                $resolvedPath = $_ | Resolve-Path | Select-Object -ExpandProperty ProviderPath
                $item = New-Object -TypeName PSCustomObject
                Add-Member -InputObject $item -MemberType NoteProperty -Name Name -Value (Split-Path -Path $resolvedPath -Leaf)
                Add-Member -InputObject $item -MemberType NoteProperty -Name Path -Value $resolvedPath
                Update-Item -Item $item -Properties $UnboundArguments
            }
        }
    }
}
