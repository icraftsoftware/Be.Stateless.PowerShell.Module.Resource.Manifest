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

Import-Module -Name $PSScriptRoot\..\..\Resource.Manifest.psd1 -Force

Describe 'New-SqlDatabase' {
   InModuleScope Resource.Manifest {

      Context 'When path does not exist' {
         BeforeAll {
            $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
         }
         It 'Throws a ParameterBindingValidationException.' {
            { New-SqlDatabase -Name CustomDb -Server localhost -Path c:\folder } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
      }

      Context 'When optional Variables are null or empty' {
         BeforeAll {
            '' > TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql
            '' > TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql
            '' > TestDrive:\BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql
         }
         It 'Does not throw because Variables is null.' {
            New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               { New-SqlDatabase -Name BizTalkFactoryMgmtDb -Server Server -Path TestDrive:\ -Variable $null } |
                  Should -Not -Throw
            }
         }
         It 'Does not throw because Variables is empty.' {
            New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               { New-SqlDatabase -Name BizTalkFactoryMgmtDb -Server Server -Path TestDrive:\ -Variable @{ } } |
                  Should -Not -Throw
            }
         }
      }

      Context 'Creating SqlDatabases throws when not done via the ScriptBlock passed to New-ResourceManifest' {
         It 'Throws a Manifest variable exception.' {
            { New-SqlDatabase -Name BizTalkFactoryMgmtDb -Server ManagementDatabaseServer -Path TestDrive:\ -EnlistInBizTalkBackupJob -PassThru } |
               Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException]) -ExpectedMessage 'The variable ''`$Manifest'' cannot be retrieved because it has not been set.' }
      }

      Context 'Creating SqlDatabases throws when not done in the context of an Application manifest' {
         It 'Throws a manifest type exception.' {
            {
               New-ResourceManifest -Type Package -Name 'BizTalk.Factory' -Build {
                  New-SqlDatabase -Name BizTalkFactoryMgmtDb -Server localhost -Path TestDrive:\
               }
            } | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException]) -ExpectedMessage 'A BizTalk Application''s custom SQL database can only be installed in the context of an Application manifest.' }
      }

      Context 'Creating SqlDatabases must be done via the ScriptBlock passed to New-ResourceManifest' {
         BeforeAll {
            '' > TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql
            '' > TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql
            '' > TestDrive:\BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql

            if (-not(Test-Path Env:\BTSINSTALLPATH)) {
               $env:BTSINSTALLPATH = 'TestDrive:\'
               '' | Set-Content -Path TestDrive:\Schema\Backup_Setup_All_Tables.sql
               '' | Set-Content -Path TestDrive:\Schema\Backup_Setup_All_Procs.sql
            }

            Mock Get-BizTalkGroupSettings { return [PSCustomObject]@{ MgmtDbServerName = 'ManagementDatabaseServer' } }
         }
         It 'Accumulates SqlDeploymentScripts and SqlUndeploymentScripts into the Manifest being built.' {
            $expectedDeploymentItems = @(
               [PSCustomObject]@{ Name = 'BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql' ; Server = 'localhost' ; Database = [string]::Empty ; Variable = @{ } ; Path = 'TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
               [PSCustomObject]@{ Name = 'BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql' ; Server = 'localhost' ; Database = [string]::Empty ; Variable = @{ } ; Path = 'TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
            )
            $expectedUndeploymentItems = @(
               [PSCustomObject]@{ Name = 'BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql' ; Server = 'localhost' ; Database = [string]::Empty ; Variable = @{ } ; Path = 'TestDrive:\BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
            )

            $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               New-SqlDatabase -Name BizTalkFactoryMgmtDb -Server localhost -Path TestDrive:\
            }

            $builtManifest | Should -Not -BeNullOrEmpty

            $builtManifest.ContainsKey('SqlDeploymentScripts') | Should -BeTrue
            $builtManifest.SqlDeploymentScripts | Should -HaveCount 2
            0..1 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedDeploymentItems[$_] -DifferenceItem $builtManifest.SqlDeploymentScripts[$_] | Should -BeNullOrEmpty }

            $builtManifest.ContainsKey('SqlUndeploymentScripts') | Should -BeTrue
            $builtManifest.SqlUndeploymentScripts | Should -HaveCount 1
            Compare-ResourceItem -ReferenceItem $expectedUndeploymentItems[0] -DifferenceItem $builtManifest.SqlUndeploymentScripts[0] | Should -BeNullOrEmpty
         }
         It 'Accumulates BizTalk Backup Job Enlistment Scripts into the Manifest being built.' {
            $expectedDeploymentItems = @(
               [PSCustomObject]@{ Name = 'BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql' ; Server = 'localhost' ; Database = [string]::Empty ; Variable = @{ } ; Path = 'TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
               [PSCustomObject]@{ Name = 'BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql' ; Server = 'localhost' ; Database = [string]::Empty ; Variable = @{ } ; Path = 'TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
               [PSCustomObject]@{ Name = 'Backup_Setup_All_Tables.sql' ; Server = 'localhost' ; Database = 'BizTalkFactoryMgmtDb' ; Variable = @{ } ; Path = (Join-Path $env:BTSINSTALLPATH 'Schema\Backup_Setup_All_Tables.sql') | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
               [PSCustomObject]@{ Name = 'Backup_Setup_All_Procs.sql' ; Server = 'localhost' ; Database = 'BizTalkFactoryMgmtDb' ; Variable = @{ } ; Path = (Join-Path $env:BTSINSTALLPATH 'Schema\Backup_Setup_All_Procs.sql') | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
               [PSCustomObject]@{ Name = 'IncludeCustomDatabaseInOtherBackupDatabases.sql' ; Server = 'ManagementDatabaseServer' ; Database = [string]::Empty ; Variable = @{ CustomDatabaseName = 'BizTalkFactoryMgmtDb' ; ServerName = 'localhost' ; BTSServer = $env:COMPUTERNAME } ; Path = "$PSScriptRoot\..\IncludeCustomDatabaseInOtherBackupDatabases.sql" | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
            )
            $expectedUndeploymentItems = @(
               [PSCustomObject]@{ Name = 'BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql' ; Server = 'localhost' ; Database = [string]::Empty ; Variable = @{ } ; Path = 'TestDrive:\BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
               [PSCustomObject]@{ Name = 'RemoveCustomDatabaseFromOtherBackupDatabases.sql' ; Server = 'ManagementDatabaseServer' ; Database = [string]::Empty ; Variable = @{ CustomDatabaseName = 'BizTalkFactoryMgmtDb' } ; Path = "$PSScriptRoot\..\RemoveCustomDatabaseFromOtherBackupDatabases.sql" | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
            )

            $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               New-SqlDatabase -Name BizTalkFactoryMgmtDb -Server localhost -Path TestDrive:\ -EnlistInBizTalkBackupJob
            }

            $builtManifest | Should -Not -BeNullOrEmpty

            $builtManifest.ContainsKey('SqlDeploymentScripts') | Should -BeTrue
            $builtManifest.SqlDeploymentScripts | Should -HaveCount 5
            0..4 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedDeploymentItems[$_] -DifferenceItem $builtManifest.SqlDeploymentScripts[$_] | Should -BeNullOrEmpty }

            $builtManifest.ContainsKey('SqlUndeploymentScripts') | Should -BeTrue
            $builtManifest.SqlUndeploymentScripts | Should -HaveCount 2
            0..1 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedUndeploymentItems[$_] -DifferenceItem $builtManifest.SqlUndeploymentScripts[$_] | Should -BeNullOrEmpty }
         }
      }

   }
}