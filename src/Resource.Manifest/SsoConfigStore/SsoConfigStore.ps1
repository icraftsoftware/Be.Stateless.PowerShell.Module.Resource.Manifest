﻿#region Copyright & License

# Copyright © 2012 - 2022 François Chabot
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
      [PSObject[]]
      $Path,

      [Parameter(Mandatory = $false)]
      [AllowNull()]
      [AllowEmptyCollection()]
      [string[]]
      $AdministratorGroup = @(Get-BizTalkGroupSettings | ForEach-Object BizTalkAdministratorGroup),

      [Parameter(Mandatory = $false)]
      [AllowNull()]
      [AllowEmptyCollection()]
      [string[]]
      $UserGroup = @(Get-BizTalkHost | ForEach-Object NTGroupName | Select-Object -Unique),

      [Parameter(Mandatory = $false)]
      [ValidateScript( { ($_ | Test-None) -or ($_ | Test-Path -PathType Container) } )]
      [string[]]
      $AssemblyProbingFolderPath,

      [Parameter(Mandatory = $false)]
      [AllowNull()]
      [AllowEmptyString()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { $_ -is [bool] -or $_ -is [ScriptBlock] } )]
      [PSObject]
      $Condition = $true,

      [Parameter(Mandatory = $false)]
      [switch]
      $PassThru
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   $arguments = @{
      ResourceGroup             = 'SsoConfigStores'
      Path                      = $Path
      Condition                 = $Condition
      # force empty array by prepending it with the array construction operator, see https://stackoverflow.com/a/18477004/1789441
      AdministratorGroup        = if ($AdministratorGroup | Test-Any) { $AdministratorGroup } else { , @() }
      UserGroup                 = if ($UserGroup | Test-Any) { $UserGroup } else { , @() }
      AssemblyProbingFolderPath = if ($AssemblyProbingFolderPath | Test-Any) { $AssemblyProbingFolderPath | Resolve-Path | Select-Object -ExpandProperty ProviderPath } else { , @() }
   }
   if (-not [string]::IsNullOrWhiteSpace($EnvironmentSettingOverridesTypeName)) { $arguments.EnvironmentSettingOverridesTypeName = $EnvironmentSettingOverridesTypeName }

   New-ResourceItem @arguments -PassThru:$PassThru
}

Set-Alias -Option Readonly -Name SsoConfigStore -Value New-SsoConfigStore
