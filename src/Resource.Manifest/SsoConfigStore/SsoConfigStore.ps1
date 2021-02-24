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

function New-SsoConfigStore {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript( { $_ | Test-Path -PathType Leaf } )]
        [psobject[]]
        $Path,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]]
        $AdministratorGroups,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]]
        $UserGroups,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $EnvironmentSettingOverridesType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $_ -is [bool] -or $_ -is [ScriptBlock] })]
        [psobject]
        $Condition = $true,

        [Parameter(Mandatory = $false)]
        [switch]
        $PassThru
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $arguments = @{
        Resource            = 'SsoConfigStores'
        Path                = $Path | Resolve-Path | Select-Object -ExpandProperty ProviderPath
        Condition           = $Condition
        # force empty array by prepending it with the array construction operator, see https://stackoverflow.com/a/18477004/1789441
        AdministratorGroups = if ($AdministratorGroups | Test-Any) { $AdministratorGroups } else { , @() }
        UserGroups          = if ($UserGroups | Test-Any) { $UserGroups } else { , @() }
    }
    if (-not [string]::IsNullOrWhiteSpace($EnvironmentSettingOverridesType)) { $arguments.EnvironmentSettingOverridesType = $EnvironmentSettingOverridesType }

    New-ResourceItem @arguments -PassThru:$PassThru
}

Set-Alias -Name SsoConfigStore -Value New-SsoConfigStore
