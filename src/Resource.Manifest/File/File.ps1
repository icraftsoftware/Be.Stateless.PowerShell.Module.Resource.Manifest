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

function New-File {
   [CmdletBinding(DefaultParameterSetName = 'File')]
   [OutputType([PSCustomObject[]])]
   param (
      [Parameter(Mandatory = $true, ParameterSetName = 'File')]
      [Parameter(Mandatory = $true, ParameterSetName = 'Folder')]
      [ValidateScript( { $_ | Test-Path -PathType Leaf } )]
      [PSObject[]]
      $Path,

      [Parameter(Mandatory = $true, ParameterSetName = 'File')]
      [Alias('Destination')]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { $_ | Test-Path -IsValid } )]
      [PSObject[]]
      $DestinationFile,

      [Parameter(Mandatory = $true, ParameterSetName = 'Folder')]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { $_ | Test-Path -IsValid } )]
      [PSObject[]]
      $DestinationFolder,

      [Parameter(Mandatory = $false, ParameterSetName = 'File')]
      [Parameter(Mandatory = $false, ParameterSetName = 'Folder')]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { $_ -is [bool] -or $_ -is [ScriptBlock] } )]
      [PSObject]
      $Condition = $true,

      [Parameter(Mandatory = $false, ParameterSetName = 'File')]
      [Parameter(Mandatory = $false, ParameterSetName = 'Folder')]
      [switch]
      $PassThru
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $destination = switch ($PSCmdlet.ParameterSetName) {
      'File' {
         if ($Path.Count -gt 1) { throw 'Deploying multiple source files to either a single or multiple destination files is ambiguous and not supported. Multiple source files can only be deployed to either a single or multiple destination folders.' }
         if ($DestinationFile | Where-Object -FilterScript { $_.EndsWith('\') } | Test-Any) { throw 'At least one destination file ends with a ''\'', denoting a destination folder instead.' }
         $DestinationFile
      }
      'Folder' {
         # ensure folders end with a \ so that BizTalk.Deployment's File Task can distinguish a folder from a file
         $DestinationFolder | ForEach-Object -Process { if ($_.EndsWith('\')) { $_ } else { "$_\" } }
      }
   }

   $arguments = @{
      ResourceGroup = 'Files'
      Path          = $Path
      Destination   = $destination
      Condition     = $Condition
   }
   New-ResourceItem @arguments -PassThru:$PassThru
}

Set-Alias -Option Readonly -Name File -Value New-File
