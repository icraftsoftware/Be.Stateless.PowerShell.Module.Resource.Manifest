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

function Get-ResourceItem {
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo[]])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false)]
        [string]
        $RootPath = $MyInvocation.PSScriptRoot,

        [Parameter(Mandatory = $false)]
        [string[]]
        $Extensions = @(".dll", ".exe")
    )
    process {
        $Name | ForEach-Object -Process {
            $items = Get-ChildItem -Path $RootPath `
                -Filter "$_.*" `
                -Include $( $Extensions | ForEach-Object { "*$_" }) `
                -File `
                -Recurse
            if ($null -eq $items ) {
                throw "Resource item not found [Path: '$RootPath', Name: '$_', Extensions = '$($Extensions -join ", ")']."
            }
            $duplicateItems = $items | Group-Object Name | Where-Object Count -GT 1
            if ($duplicateItems | Test-Any) {
                throw "Ambiguous resource items found ['$($duplicateItems.Name -join "', '")'] matching criteria [Path: '$RootPath', Name: '$_', Extensions = '$($Extensions -join ", ")']."
            }
            $items
        }
    }
}

function New-ResourceItem {
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
        $Condition = $true,

        [Parameter(Mandatory = $false, ParameterSetName = 'named-resource')]
        [Parameter(Mandatory = $false, ParameterSetName = 'file-resource')]
        [switch]
        $PassThru,

        [Parameter(DontShow, Mandatory = $false, ParameterSetName = 'named-resource', ValueFromRemainingArguments = $true)]
        [Parameter(DontShow, Mandatory = $false, ParameterSetName = 'file-resource', ValueFromRemainingArguments = $true)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object[]]
        $UnboundArguments = @()
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $splattedArguments = ConvertTo-SplattedArguments -UnboundArguments $UnboundArguments
    if (-not($Condition -is [bool]) -or -not($Condition)) { $splattedArguments.Add('Condition', $Condition) }

    $(if ($PSCmdlet.ParameterSetName -eq 'named-resource') { $Name } else { $Path | Resolve-Path | Select-Object -ExpandProperty ProviderPath }) | ForEach-Object -Process {
        $item = New-Object -TypeName PSCustomObject
        if ($PSCmdlet.ParameterSetName -eq 'named-resource') {
            Add-Member -InputObject $item -MemberType NoteProperty -Name Name -Value $_
        } else {
            Add-Member -InputObject $item -MemberType NoteProperty -Name Name -Value (Split-Path -Path $_ -Leaf)
            Add-Member -InputObject $item -MemberType NoteProperty -Name Path -Value $_
        }
        Add-ResourceItemMembers -Item $item -DynamicMembers $splattedArguments
        if ($PassThru) {
            $item
        } else {
            # TODO support $ItemUnicityScope
            # TODO write-verbose no matter the ItemUnicityScope
            # TODO ?? write-error about Item redefinition according to the ItemUnicityScope,
            # unicity => where Path is the unique criterium xor all the properties must be unique
            if ($Manifest.ContainsKey($Resource)) {
                $Manifest.$Resource = @($Manifest.$Resource) + $item
            } else {
                $Manifest.Add($Resource, $item)
            }
        }
    }
}

function New-ResourceManifest {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Type,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string]
        $Description,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Manifest', 'Resource', 'None')]
        [string]
        $ItemUnicityScope = 'Manifest',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $Build,

        [Parameter(DontShow, Mandatory = $false, ValueFromRemainingArguments = $true)]
        [ValidateNotNullOrEmpty()]
        [object[]]
        $UnboundArguments = @()
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $item = New-Object -TypeName PSCustomObject
    Add-Member -InputObject $item -MemberType NoteProperty -Name Type -Value $Type
    Add-Member -InputObject $item -MemberType NoteProperty -Name Name -Value $Name
    Add-Member -InputObject $item -MemberType NoteProperty -Name Description -Value $Description
    Add-ResourceItemMembers -Item $item -DynamicMembers (ConvertTo-SplattedArguments -UnboundArguments $UnboundArguments)

    $manifestBuildScript = [scriptblock] {
        [CmdletBinding()]
        [OutputType([void])]
        param (
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [hashtable]
            $Manifest
        )
        . $Build
    }

    $manifest = @{ }
    $manifest.Add('Properties', $item)
    & $manifestBuildScript -Manifest $manifest
    $manifest
}

#region helpers

function Add-ResourceItemMembers {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [PSCustomObject]
        $Item,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [hashtable]
        $DynamicMembers,

        [Parameter(Mandatory = $false)]
        [switch]
        $PassThru
    )
    process {
        $DynamicMembers.Keys | ForEach-Object -Process {
            if ($DynamicMembers.$_ -is [ScriptBlock]) {
                # ScriptMethod instead of ScriptProperty to avoid any error to be silenced; see https://stackoverflow.com/a/19777735/1789441
                Add-Member -InputObject $item -MemberType ScriptMethod -Name $_ -Value $DynamicMembers.$_
            } else {
                Add-Member -InputObject $item -MemberType NoteProperty -Name $_ -Value $DynamicMembers.$_
            }
        }
        if ($PassThru) { $Item }
    }
}

function Compare-ResourceItem {
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
            if ($referenceValue -is [array] -and $differenceValue -is [array]) {
                $arrayDifferences = Compare-Object -ReferenceObject $referenceValue -DifferenceObject $differenceValue
                if ($arrayDifferences | Test-Any) {
                    $uniqueReferenceValues = $arrayDifferences | Where-Object -FilterScript { $_.SideIndicator -eq '<=' } | ForEach-Object -Process { $_.InputObject } | Join-String -Separator ", "
                    $uniqueDifferenceValues = $arrayDifferences | Where-Object -FilterScript { $_.SideIndicator -eq '=>' } | ForEach-Object -Process { $_.InputObject } | Join-String -Separator ", "
                    [PSCustomObject]@{Property = $key ; ReferenceValue = "($uniqueReferenceValues)" ; SideIndicator = '<>' ; DifferenceValue = "($uniqueDifferenceValues)" } | Tee-Object -Variable difference
                    Write-Verbose -Message $difference
                }
            } elseif ($referenceValue -is [hashtable] -and $differenceValue -is [hashtable]) {
                Compare-HashTable -ReferenceHashTable $referenceValue -DifferenceHashTable $differenceValue -Prefix "$Key"
            } elseif ($referenceValue -ne $differenceValue) {
                [PSCustomObject]@{Property = $key ; ReferenceValue = $referenceValue ; SideIndicator = '<>' ; DifferenceValue = $differenceValue } | Tee-Object -Variable difference
                Write-Verbose -Message $difference
            }
        }
    }
}

function ConvertTo-SplattedArguments {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [psobject[]]
        $UnboundArguments
    )
    $splattedArguments = @{ }
    $UnboundArguments | ForEach-Object -Process {
        if ($_ -is [array]) {
            $splattedArguments.$lastParameterName = $_
        } else {
            switch -regex ($_) {
                # parse parameter name
                '^-(\w+):?$' {
                    $splattedArguments.Add(($lastParameterName = $matches[1]), $null)
                    break
                }
                # parse values of last parsed parameter
                default {
                    $splattedArguments.$lastParameterName = $_
                    break
                }
            }
        }
    }
    $splattedArguments
}

#endregion