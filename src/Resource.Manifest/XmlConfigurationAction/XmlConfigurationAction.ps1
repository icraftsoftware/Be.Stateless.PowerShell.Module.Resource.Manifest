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

function New-XmlConfigurationAction {
   [CmdletBinding()]
   [OutputType([PSCustomObject[]])]
   param (
      [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
      [Parameter(Mandatory = $true, ParameterSetName = 'Update')]
      [Parameter(Mandatory = $true, ParameterSetName = 'Delete')]
      [Alias('TargetConfigurationFile', 'ConfigurationFile', 'ConfigFile')]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Path,

      [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
      [ValidateNotNullOrEmpty()]
      [string]
      $Append,

      [Parameter(Mandatory = $true, ParameterSetName = 'Update')]
      [ValidateNotNullOrEmpty()]
      [string]
      $Update,

      [Parameter(Mandatory = $true, ParameterSetName = 'Delete')]
      [ValidateNotNullOrEmpty()]
      [string]
      $Delete,

      [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
      [Alias('Element', 'ElementName', 'Node', 'NodeName')]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name,

      [Parameter(Mandatory = $false, ParameterSetName = 'Append')]
      [Parameter(Mandatory = $true, ParameterSetName = 'Update')]
      [ValidateNotNullOrEmpty()]
      [HashTable]
      $Attribute,

      [Parameter(Mandatory = $false, ParameterSetName = 'Append')]
      [Parameter(Mandatory = $false, ParameterSetName = 'Update')]
      [Parameter(Mandatory = $false, ParameterSetName = 'Delete')]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { $_ -is [bool] -or $_ -is [ScriptBlock] } )]
      [PSObject]
      $Condition = $true,

      [Parameter(Mandatory = $false, ParameterSetName = 'Append')]
      [Parameter(Mandatory = $false, ParameterSetName = 'Update')]
      [Parameter(Mandatory = $false, ParameterSetName = 'Delete')]
      [switch]
      $PassThru
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   $arguments = @{
      ResourceGroup = 'XmlConfigurationActions'
      Path          = $Path
      Action        = $PSCmdlet.ParameterSetName
      XPath         = $PSBoundParameters.$($PSCmdlet.ParameterSetName)
      Condition     = $Condition
   }
   switch ($PSCmdlet.ParameterSetName) {
      { $_ -eq 'Append' } {
         $arguments.Name = $Name
      }
      { $_ -in @('Append', 'Update') } {
         if ($Attribute | Test-Any) { $arguments.Attribute = $Attribute } else { $arguments.Attribute = @{ } }
      }
   }
   New-ResourceItem @arguments -PassThru:$PassThru
}

Set-Alias -Option Readonly -Name XmlConfigurationAction -Value New-XmlConfigurationAction
