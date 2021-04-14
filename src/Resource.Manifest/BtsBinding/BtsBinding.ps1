#region Copyright & License

# Copyright © 2012 - 2021 François Chabot
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

function New-Binding {
    [CmdletBinding(DefaultParameterSetName = 'override-type')]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'override-path')]
        [Parameter(Mandatory = $true, ParameterSetName = 'override-type')]
        [ValidateScript( { $_ | Test-Path -PathType Leaf } )]
        [psobject[]]
        $Path,

        [Parameter(Mandatory = $false, ParameterSetName = 'override-path')]
        [Parameter(Mandatory = $false, ParameterSetName = 'override-type')]
        [ValidateScript( { ($_ | Test-None) -or ($_ | Test-Path -PathType Container) } )]
        [string[]]
        $AssemblyProbingFolderPaths,

        [Parameter(Mandatory = $false, ParameterSetName = 'override-type')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $EnvironmentSettingOverridesType,

        [Parameter(Mandatory = $false, ParameterSetName = 'override-path')]
        [AllowNull()]
        [AllowEmptyString()]
        [ValidateScript( { [string]::IsNullOrWhiteSpace($_) -or ($_ | Test-Path -PathType Container) } )]
        [string]
        $ExcelSettingOverridesFolderPath,

        [Parameter(Mandatory = $false, ParameterSetName = 'override-path')]
        [Parameter(Mandatory = $false, ParameterSetName = 'override-type')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $_ -is [bool] -or $_ -is [ScriptBlock] } )]
        [psobject]
        $Condition = $true,

        [Parameter(Mandatory = $false, ParameterSetName = 'override-path')]
        [Parameter(Mandatory = $false, ParameterSetName = 'override-type')]
        [switch]
        $PassThru
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $arguments = @{
        Resource                   = 'Bindings'
        Path                       = $Path | Resolve-Path | Select-Object -ExpandProperty ProviderPath
        AssemblyProbingFolderPaths = if ($AssemblyProbingFolderPaths | Test-Any) {
            $AssemblyProbingFolderPaths | Resolve-Path | Select-Object -ExpandProperty ProviderPath
        } else {
            # force empty array by prepending it with the array construction operator, see https://stackoverflow.com/a/18477004/1789441
            , @()
        }
        Condition                  = $Condition
    }
    if ($PSCmdlet.ParameterSetName -eq 'override-type') {
        if (-not [string]::IsNullOrWhiteSpace($EnvironmentSettingOverridesType)) { $arguments.EnvironmentSettingOverridesType = $EnvironmentSettingOverridesType }
    } else {
        if (-not [string]::IsNullOrWhiteSpace($ExcelSettingOverridesFolderPath)) { $arguments.ExcelSettingOverridesFolderPath = Resolve-Path -Path $ExcelSettingOverridesFolderPath | Select-Object -ExpandProperty ProviderPath }
    }
    New-ResourceItem @arguments -PassThru:$PassThru
}

Set-Alias -Name Binding -Value New-Binding
