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

function New-XmlConfigurationAction {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'insert')]
        [Switch]
        $Insert,

        [Parameter(Mandatory = $true, ParameterSetName = 'update')]
        [Switch]
        $Update,

        [Parameter(Mandatory = $true, ParameterSetName = 'delete')]
        [Switch]
        $Delete,

        [Parameter(Mandatory = $true, ParameterSetName = 'insert')]
        [Parameter(Mandatory = $true, ParameterSetName = 'update')]
        [Parameter(Mandatory = $true, ParameterSetName = 'delete')]
        [ValidateScript( { Test-Path -Path $_ } )]
        [string]
        $Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'insert')]
        [Parameter(Mandatory = $true, ParameterSetName = 'update')]
        [Parameter(Mandatory = $true, ParameterSetName = 'delete')]
        [ValidateNotNullOrEmpty()]
        [string]
        $XPath,

        [Parameter(Mandatory = $true, ParameterSetName = 'insert')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ElementName,

        [Parameter(Mandatory = $false, ParameterSetName = 'insert')]
        [Parameter(Mandatory = $true, ParameterSetName = 'update')]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Attributes,

        [Parameter(Mandatory = $false, ParameterSetName = 'insert')]
        [Parameter(Mandatory = $false, ParameterSetName = 'update')]
        [Parameter(Mandatory = $false, ParameterSetName = 'delete')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $_ -is [bool] -or $_ -is [ScriptBlock] } )]
        [psobject]
        $Condition = $true,

        [Parameter(Mandatory = $false, ParameterSetName = 'insert')]
        [Parameter(Mandatory = $false, ParameterSetName = 'update')]
        [Parameter(Mandatory = $false, ParameterSetName = 'delete')]
        [switch]
        $PassThru
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $arguments = @{
        Resource  = 'XmlConfigurationActions'
        Path      = $Path | Resolve-Path | Select-Object -ExpandProperty ProviderPath
        Action    = $PSCmdlet.ParameterSetName
        XPath     = $XPath
        Condition = $Condition
    }
    if ($Insert) {
        $arguments.Name = $ElementName
    }
    if ($Insert -or $Update) {
        if ($Attributes | Test-Any) { $arguments.Attributes = $Attributes } else { $arguments.Attributes = @{} }
    }
    New-ResourceItem @arguments -PassThru:$PassThru
}

Set-Alias -Name XmlConfigurationAction -Value New-XmlConfigurationAction
