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

<#
.SYNOPSIS
    Creates the necessary manifest resources to deploy and undeploy a SQL Server database.
.DESCRIPTION
    Creates the necessary manifest resources to deploy and undeploy a SQL Server database. The resources created are as
    follows:
    - a SqlDeploymentScript for the script conventionally named ($Manifest.Properties.Name).Create.$(Name).sql
    - a SqlDeploymentScript for the script conventionally named ($Manifest.Properties.Name).Create.$(Name).Objects.sql
    - a SqlUndeploymentScript for the script conventionally named ($Manifest.Properties.Name).Drop.$(Name).sql
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
    [CmdletBinding(DefaultParameterSetName = 'without-backup')]
    [OutputType([PSCustomObject[]])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'without-backup')]
        [Parameter(Mandatory = $true, ParameterSetName = 'with-backup')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'without-backup')]
        [Parameter(Mandatory = $true, ParameterSetName = 'with-backup')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = 'without-backup')]
        [Parameter(Mandatory = $true, ParameterSetName = 'with-backup')]
        [ValidateScript( { $_ | Test-Path -PathType Container } )]
        [PSObject]
        $Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'with-backup')]
        [switch]
        $EnlistInBizTalkBackupJob,

        [Parameter(Mandatory = $false, ParameterSetName = 'without-backup')]
        [Parameter(Mandatory = $false, ParameterSetName = 'with-backup')]
        [AllowNull()]
        [HashTable]
        $Variables,

        [Parameter(Mandatory = $false, ParameterSetName = 'without-backup')]
        [Parameter(Mandatory = $false, ParameterSetName = 'with-backup')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $_ -is [bool] -or $_ -is [ScriptBlock] } )]
        [PSObject]
        $Condition = $true,

        [Parameter(Mandatory = $false, ParameterSetName = 'without-backup')]
        [Parameter(Mandatory = $false, ParameterSetName = 'with-backup')]
        [switch]
        $PassThru
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if ($Manifest.Properties.Type -ne 'Application') {
        throw 'A BizTalk Application''s custom SQL database can only be installed in the context of an Application manifest.'
    }

    $arguments = @{
        Server    = $Server
        Condition = $Condition
    }
    if ($null -ne $Variables -and ($Variables.Keys | Test-Any)) { $arguments.Variables = $Variables }

    $Name | ForEach-Object -Process {
        New-SqlDeploymentScript @arguments -Path (Join-Path $Path "$($Manifest.Properties.Name).Create.$_.sql") -PassThru:$PassThru
        New-SqlDeploymentScript @arguments -Path (Join-Path $Path "$($Manifest.Properties.Name).Create.$_.Objects.sql") -PassThru:$PassThru
        New-SqlUndeploymentScript @arguments -Path (Join-Path $Path "$($Manifest.Properties.Name).Drop.$_.sql") -PassThru:$PassThru

        if ($EnlistInBizTalkBackupJob) {
            New-SqlDeploymentScript -Path (Join-Path $env:BTSINSTALLPATH 'Schema\Backup_Setup_All_Tables.sql') -Server $Server -Database $_ -Condition $Condition -PassThru:$PassThru
            New-SqlDeploymentScript -Path (Join-Path $env:BTSINSTALLPATH 'Schema\Backup_Setup_All_Procs.sql') -Server $Server -Database $_ -Condition $Condition -PassThru:$PassThru
            New-SqlDeploymentScript -Path (Join-Path $PSScriptRoot 'IncludeCustomDatabaseInOtherBackupDatabases.sql') -Server ((Get-BizTalkGroupSettings).MgmtDbServerName) -Condition $Condition -PassThru:$PassThru `
                -Variables @{
                CustomDatabaseName = $_
                ServerName         = $Server
                BTSServer          = $env:COMPUTERNAME
            }
            New-SqlUndeploymentScript -Path (Join-Path $PSScriptRoot 'RemoveCustomDatabaseFromOtherBackupDatabases.sql') -Server ((Get-BizTalkGroupSettings).MgmtDbServerName) -Condition $Condition -PassThru:$PassThru `
                -Variables @{ CustomDatabaseName = $_ }
        }
    }
}

Set-Alias -Name SqlDatabase -Value New-SqlDatabase
