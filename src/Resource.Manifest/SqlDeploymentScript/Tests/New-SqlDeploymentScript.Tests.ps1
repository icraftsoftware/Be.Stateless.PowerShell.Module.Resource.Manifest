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

Import-Module -Name $PSScriptRoot\..\..\Resource.Manifest.psd1 -Force

Describe 'New-SqlDeploymentScript' {
    InModuleScope Resource.Manifest {

        Context 'When SqlDeploymentScript file does not exist' {
            BeforeAll {
                $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
            }
            It 'Throws a ParameterBindingValidationException.' {
                { New-SqlDeploymentScript -Path 'c:\SqlDeploymentScript.dll' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
        }

        Context 'When optional Variables are null or empty' {
            BeforeAll {
                '' > TestDrive:\one.sql
            }
            It 'Does not throw because Variables is null.' {
                { New-SqlDeploymentScript -Path TestDrive:\one.sql -Server localhost -Variables $null -PassThru } |
                    Should -Not -Throw
            }
            It 'Does not throw because Variables is empty.' {
                { New-SqlDeploymentScript -Path TestDrive:\one.sql -Server localhost -Variables @{ } -PassThru } |
                    Should -Not -Throw
            }
        }

        Context 'When SqlDeploymentScript file exists' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.sql
                '' > TestDrive:\two.sql
            }
            It 'Returns a custom object with both a path and a name property.' {
                $expectedItem = [PSCustomObject]@{ Name = 'one.sql' ; Server = 'localhost' ; Database = [string]::Empty ; Variables = @{ Login = 'account' } ; Path = 'TestDrive:\one.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }

                $actualItem = New-SqlDeploymentScript -Path TestDrive:\one.sql -Server localhost -Variables @{ Login = 'account' } -PassThru

                Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a collection of custom objects with both a path and a name property.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.sql' ; Server = 'localhost' ; Database = 'CustomDb' ; Path = 'TestDrive:\one.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Variables = @{} }
                    [PSCustomObject]@{ Name = 'two.sql' ; Server = 'localhost' ; Database = 'CustomDb' ; Path = 'TestDrive:\two.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Variables = @{} }
                )

                $actualItems = New-SqlDeploymentScript -Path (Get-ChildItem -Path TestDrive:\) -Server localhost -Database 'CustomDb' -PassThru

                $actualItems | Should -HaveCount 2
                0..1 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
            }
        }

        Context 'Creating SqlDeploymentScripts must be done via the ScriptBlock passed to New-ResourceManifest' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.sql
                '' > TestDrive:\two.sql
                '' > TestDrive:\six.sql
            }
            It 'Accumulates SqlDeploymentScripts into the Manifest being built.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.sql' ; Server = 'localhost' ; Database = [string]::Empty ; Path = 'TestDrive:\one.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Variables = @{} }
                    [PSCustomObject]@{ Name = 'six.sql' ; Server = 'localhost' ; Database = [string]::Empty ; Path = 'TestDrive:\six.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Variables = @{} }
                    [PSCustomObject]@{ Name = 'two.sql' ; Server = 'localhost' ; Database = [string]::Empty ; Path = 'TestDrive:\two.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Variables = @{} }
                )

                $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-SqlDeploymentScript -Path (Get-ChildItem -Path TestDrive:\) -Server localhost
                }

                $builtManifest | Should -Not -BeNullOrEmpty
                $builtManifest.ContainsKey('SqlDeploymentScripts') | Should -BeTrue
                $builtManifest.SqlDeploymentScripts | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.SqlDeploymentScripts[$_] | Should -BeNullOrEmpty }
            }
        }

    }
}