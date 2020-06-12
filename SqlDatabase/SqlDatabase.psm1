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

using namespace Be.Stateless.PowerShell.Module.Resource.Manifest

Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Creates the necessary manifest resources to deploy and undeploy a SQL Server database.
.DESCRIPTION
    Creates the necessary manifest resources to deploy and undeploy a SQL Server database. The resources created are as
    follows:
    - a SqlDeploymentScript for the script conventionally named ($Manifest.Application.Name).Create.$(Name).sql
    - a SqlDeploymentScript for the script conventionally named ($Manifest.Application.Name).Create.$(Name).Objects.sql
    - a SqlUndeploymentScript for the script conventionally named ($Manifest.Application.Name).Drop.$(Name).sql
.PARAMETER Name
    The name of the SQL Server database for which to create the necessary deployment and undeployment resources.
.PARAMETER Server
    The name of the SQL Server that will host the database.
.PARAMETER Path
    The folder where the deployment and undeployment SQL scripts are located.
.PARAMETER EnlistInBizTalkBackupJob
.NOTES
    © 2020 be.stateless.
#>
function New-SqlDatabase {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateScript( { $_ | Test-Path -PathType Container } )]
        [psobject]
        $Path,

        [Parameter(Mandatory = $false)]
        [switch]
        $EnlistInBizTalkBackupJob,

        [Parameter(Mandatory = $false)]
        [ValidateScript( { $_ -is [bool] -or $_ -is [ScriptBlock] })]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Condition = $true,

        [Parameter(Mandatory = $false)]
        [switch]
        $PassThru
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if ($null -eq [Resource]::Manifest -or ![Resource]::Manifest.ContainsKey('Application') -or [string]::IsNullOrEmpty([Resource]::Manifest.Application.Name)) {
        throw ([System.InvalidOperationException]::new('ResourceManifest has not been properly initialized.'))
    }
    New-SqlDeploymentScript -Path (Join-Path $Path "$([Resource]::Manifest.Application.Name).Create.$Name.sql") -Condition $Condition -PassThru:$PassThru
    New-SqlDeploymentScript -Path (Join-Path $Path "$([Resource]::Manifest.Application.Name).Create.$Name.Objects.sql") -Condition $Condition -PassThru:$PassThru
    New-SqlUndeploymentScript -Path (Join-Path $Path "$([Resource]::Manifest.Application.Name).Drop.$Name.sql") -Condition $Condition -PassThru:$PassThru

    #TODO EnlistInBizTalkBackupJob
}

Set-Alias -Name SqlDatabase -Value New-SqlDatabase
