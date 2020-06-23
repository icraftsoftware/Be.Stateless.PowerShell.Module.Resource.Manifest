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

Import-Module -Name $PSScriptRoot\..\SqlDatabase -Force
Import-Module -Name $PSScriptRoot\..\..\Resource -Force

Describe 'New-SqlDatabase' {
    InModuleScope SqlDatabase {

        Context 'When assembly file does not exist' {
            BeforeAll {
                $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
            }
            It 'Throws a ParameterBindingValidationException.' {
                { New-SqlDatabase -Name CustomDb -Server localhost -Path z:\folder } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
        }

        Context 'Creating SqlDatabase throws when not done via the ScriptBlock passed to New-Manifest' {
            It 'Returns a collection of custom objects with both a path and a name property.' {
                { New-SqlDatabase -Name BizTalkFactoryMgmtDb -Server ManagementDatabaseServer -Path TestDrive:\ -EnlistInBizTalkBackupJob -PassThru } |
                    Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException]) -ExpectedMessage 'The variable ''$Manifest'' cannot be retrieved because it has not been set.' }
        }

        Context 'Creating SqlDatabase must be done via the ScriptBlock passed to New-Manifest' {
            BeforeAll {
                '' > TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql
                '' > TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql
                '' > TestDrive:\BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql
            }
            It 'Accumulates SqlDeploymentScripts and SqlUndeploymentScripts into the Manifest being built.' {
                $expectedDeploymentItems = @(
                    [PSCustomObject]@{ Name = 'BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )
                $expectedUndeploymentItems = @(
                    [PSCustomObject]@{ Name = 'BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )

                $builtManifest = New-Manifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-SqlDatabase -Name BizTalkFactoryMgmtDb -Server localhost -Path TestDrive:\
                }

                $builtManifest | Should -Not -BeNullOrEmpty

                $builtManifest.ContainsKey('SqlDeploymentScripts') | Should -BeTrue
                $builtManifest.SqlDeploymentScripts | Should -HaveCount 2
                0..1 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedDeploymentItems[$_] -DifferenceItem $builtManifest.SqlDeploymentScripts[$_] | Should -BeNullOrEmpty }

                $builtManifest.ContainsKey('SqlUndeploymentScripts') | Should -BeTrue
                $builtManifest.SqlUndeploymentScripts | Should -HaveCount 1
                Compare-Item -ReferenceItem $expectedUndeploymentItems[0] -DifferenceItem $builtManifest.SqlUndeploymentScripts[0] | Should -BeNullOrEmpty
            }
            It 'Accumulates BizTalk Backup Job Enlistment Scripts into the Manifest being built.' {
                $expectedDeploymentItems = @(
                    [PSCustomObject]@{ Name = 'BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'IncludeCustomDatabaseInOtherBackupDatabases.sql' ; Server = 'localhost' ; Variables = @{ CustomDatabaseName = 'BizTalkFactoryMgmtDb' ; ServerName = 'localhost' ; BTSServer = $env:COMPUTERNAME } ; Path = "$PSScriptRoot\..\IncludeCustomDatabaseInOtherBackupDatabases.sql" | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )
                $expectedUndeploymentItems = @(
                    [PSCustomObject]@{ Name = 'BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'RemoveCustomDatabaseFromOtherBackupDatabases.sql' ; Server = 'localhost' ; Variables = @{ CustomDatabaseName = 'BizTalkFactoryMgmtDb' } ; Path = "$PSScriptRoot\..\RemoveCustomDatabaseFromOtherBackupDatabases.sql" | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )

                $builtManifest = New-Manifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-SqlDatabase -Name BizTalkFactoryMgmtDb -Server localhost -Path TestDrive:\ -EnlistInBizTalkBackupJob
                }

                $builtManifest | Should -Not -BeNullOrEmpty

                $builtManifest.ContainsKey('SqlDeploymentScripts') | Should -BeTrue
                $builtManifest.SqlDeploymentScripts | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedDeploymentItems[$_] -DifferenceItem $builtManifest.SqlDeploymentScripts[$_] | Should -BeNullOrEmpty }

                $builtManifest.ContainsKey('SqlUndeploymentScripts') | Should -BeTrue
                $builtManifest.SqlUndeploymentScripts | Should -HaveCount 2
                0..1 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedUndeploymentItems[$_] -DifferenceItem $builtManifest.SqlUndeploymentScripts[$_] | Should -BeNullOrEmpty }
            }
        }

    }
}