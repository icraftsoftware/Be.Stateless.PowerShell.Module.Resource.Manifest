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

function New-WindowsService {
   [CmdletBinding()]
   [OutputType([PSCustomObject[]])]
   param (
      [Parameter(Mandatory = $true)]
      [ValidateScript( { $_ | Test-Path -PathType Leaf } )]
      [PSObject]
      $Path,

      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name,

      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [PSCredential]
      $Credential,

      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Description,

      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $DisplayName,

      [Parameter(Mandatory = $false)]
      [ValidateSet('Automatic', 'AutomaticDelayedStart', 'Disabled', 'Manual')]
      [ValidateNotNullOrEmpty()]
      [string]
      $StartupType = 'Automatic',

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
      ResourceGroup = 'WindowsServices'
      Path          = $Path
      Name          = $Name
      Credential    = $Credential
      StartupType   = $StartupType
      Condition     = $Condition
   }
   if (![string]::IsNullOrWhiteSpace($Description)) { $arguments.Description = $Description }
   if (![string]::IsNullOrWhiteSpace($DisplayName)) { $arguments.DisplayName = $DisplayName }

   New-ResourceItem @arguments -PassThru:$PassThru
}

Set-Alias -Option Readonly -Name WindowsService -Value New-WindowsService
