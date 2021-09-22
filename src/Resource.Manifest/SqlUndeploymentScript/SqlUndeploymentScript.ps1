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

function New-SqlUndeploymentScript {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript( { $_ | Test-Path -PathType Leaf } )]
        [PSObject[]]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Database,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [hashtable]
        $Variables,

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
        Resource  = 'SqlUndeploymentScripts'
        Path      = $Path | Resolve-Path | Select-Object -ExpandProperty ProviderPath
        Server    = $Server
        Database  = $Database
        Condition = $Condition
        Variables = if ($null -ne $Variables -and ($Variables.Keys | Test-Any)) { $Variables } else { @{ } }
    }
    New-ResourceItem @arguments -PassThru:$PassThru
}

Set-Alias -Name SqlUndeploymentScript -Value New-SqlUndeploymentScript
