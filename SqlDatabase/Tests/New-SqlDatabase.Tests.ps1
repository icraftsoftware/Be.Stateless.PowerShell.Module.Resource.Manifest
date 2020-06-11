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

        Context 'Creating SqlDatabase must be done via the ScriptBlock passed to New-Manifest' {
            BeforeAll {
                '' > TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql
                '' > TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql
                '' > TestDrive:\BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql
            }
            It 'Accumulates SqlDeploymentScripts and SqlUndeploymentScripts into the Manifest being built.' {
                $expectedDeploymentItems = @(
                    [PSCustomObject]@{ Name = 'BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql' ; Path = 'TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql' ; Path = 'TestDrive:\BizTalk.Factory.Create.BizTalkFactoryMgmtDb.Objects.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )
                $expectedUndeploymentItems = @(
                    [PSCustomObject]@{ Name = 'BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql' ; Path = 'TestDrive:\BizTalk.Factory.Drop.BizTalkFactoryMgmtDb.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )

                $builtManifest = New-Manifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-SqlDatabase -Name BizTalkFactoryMgmtDb -Server ManagementDatabaseServer -Path TestDrive:\ -EnlistInBizTalkBackupJob
                }

                $builtManifest | Should -Not -BeNullOrEmpty

                $builtManifest.ContainsKey('SqlDeploymentScripts') | Should -BeTrue
                $builtManifest.SqlDeploymentScripts | Should -HaveCount 2
                0..1 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedDeploymentItems[$_] -DifferenceItem $builtManifest.SqlDeploymentScripts[$_] | Should -BeNullOrEmpty }

                $builtManifest.ContainsKey('SqlUndeploymentScripts') | Should -BeTrue
                $builtManifest.SqlDeploymentScripts | Should -HaveCount 1
                Compare-Item -ReferenceItem $expectedUndeploymentItems[0] -DifferenceItem $builtManifest.SqlUndeploymentScripts[0] | Should -BeNullOrEmpty
            }
        }

    }
}