#region Copyright & License

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

function New-ApplicationManifest {
   [CmdletBinding()]
   [OutputType([PSCustomObject])]
   param (
      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name,

      [Parameter(Mandatory = $false)]
      [AllowNull()]
      [AllowEmptyString()]
      [string]
      $Description,

      [Parameter(Mandatory = $false)]
      [AllowNull()]
      [AllowEmptyCollection()]
      [string[]]
      $Reference,

      [Parameter(Mandatory = $false)]
      [AllowNull()]
      [AllowEmptyCollection()]
      [string[]]
      $WeakReference,

      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [scriptblock]
      $Build
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   $arguments = @{
      Type          = 'Application'
      Name          = $Name
      # force empty array by prepending it with the array construction operator, see https://stackoverflow.com/a/18477004/1789441
      Reference     = if ($Reference | Test-Any) { $Reference } else { , @() }
      WeakReference = if ($WeakReference | Test-Any) { $WeakReference } else { , @() }
   }
   if (![string]::IsNullOrWhiteSpace($Description)) { $arguments.Description = $Description }
   New-ResourceManifest @arguments -Build $Build
}

Set-Alias -Option Readonly -Name ApplicationManifest -Value New-ApplicationManifest
