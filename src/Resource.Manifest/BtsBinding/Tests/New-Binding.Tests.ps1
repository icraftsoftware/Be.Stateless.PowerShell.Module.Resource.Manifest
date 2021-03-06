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

Describe 'New-Binding' {
    InModuleScope Resource.Manifest {

        Context 'When binding file does not exist' {
            BeforeAll {
                $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
            }
            It 'Throws a ParameterBindingValidationException.' {
                { New-Binding -Path 'c:\binding.dll' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
        }
        Context 'When optional arguments are null, empty, or invalid' {
            BeforeAll {
                $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
                # create some empty files
                '' > TestDrive:\six.txt
            }
            It 'Does not throw because AssemblyProbingFolderPaths is empty.' {
                { New-Binding -Path TestDrive:\six.txt -AssemblyProbingFolderPaths @() -PassThru } | Should -Not -Throw
            }
            It 'Throws because AssemblyProbingFolderPaths do not exist.' {
                { New-Binding -Path TestDrive:\six.txt -AssemblyProbingFolderPaths 'TestDrive:\foo' -PassThru } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
            It 'Does not throw because EnvironmentSettingOverridesType is null.' {
                { New-Binding -Path TestDrive:\six.txt -EnvironmentSettingOverridesType $null -PassThru } | Should -Not -Throw
            }
            It 'Does not throw because EnvironmentSettingOverridesType is empty.' {
                { New-Binding -Path TestDrive:\six.txt -EnvironmentSettingOverridesType '' -PassThru } | Should -Not -Throw
            }
            It 'Does not throw because ExcelSettingOverridesFolderPath is null.' {
                { New-Binding -Path TestDrive:\six.txt -ExcelSettingOverridesFolderPath $null -PassThru } | Should -Not -Throw
            }
            It 'Does not throw because ExcelSettingOverridesFolderPath is empty.' {
                { New-Binding -Path TestDrive:\six.txt -ExcelSettingOverridesFolderPath '' -PassThru } | Should -Not -Throw
            }
            It 'Throws because ExcelSettingOverridesFolderPath does not exist.' {
                { New-Binding -Path TestDrive:\six.txt -ExcelSettingOverridesFolderPath 'TestDrive:\foo' -PassThru } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
        }

        Context 'When binding file exists' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.txt
                '' > TestDrive:\two.txt
            }
            It 'Should not throw.' {
                { New-Binding -Path TestDrive:\two.txt -PassThru } | Should -Not -Throw
            }
            It 'Returns a custom object with both a path and a name property.' {
                $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; AssemblyProbingFolderPaths = @() }

                $actualItem = New-Binding -Path TestDrive:\one.txt -PassThru

                Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns an object with AssemblyProbingFolderPaths and EnvironmentSettingOverridesType.' {
                $expectedItem = [PSCustomObject]@{
                    Name                            = 'one.txt'
                    Path                            = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath
                    AssemblyProbingFolderPaths      = ($PSScriptRoot | Resolve-Path | Split-Path -Parent), ($PSScriptRoot | Resolve-Path | Split-Path -Parent | Split-Path -Parent)
                    EnvironmentSettingOverridesType = 'some-environment-setting-overrides-type-name'
                }

                $actualItem = New-Binding -Path TestDrive:\one.txt -AssemblyProbingFolderPaths $expectedItem.AssemblyProbingFolderPaths[0], $expectedItem.AssemblyProbingFolderPaths[1] -EnvironmentSettingOverridesType $expectedItem.EnvironmentSettingOverridesType -PassThru

                Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns an object with AssemblyProbingFolderPaths and ExcelSettingOverridesFolderPath.' {
                $expectedItem = [PSCustomObject]@{
                    Name                            = 'one.txt'
                    Path                            = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath
                    AssemblyProbingFolderPaths      = ($PSScriptRoot | Resolve-Path | Split-Path -Parent), ($PSScriptRoot | Resolve-Path | Split-Path -Parent | Split-Path -Parent)
                    ExcelSettingOverridesFolderPath = $PSScriptRoot
                }

                $actualItem = New-Binding -Path TestDrive:\one.txt -AssemblyProbingFolderPaths $expectedItem.AssemblyProbingFolderPaths[0], $expectedItem.AssemblyProbingFolderPaths[1] -ExcelSettingOverridesFolderPath $PSScriptRoot -PassThru

                Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a collection of custom objects with both a path and a name property.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; AssemblyProbingFolderPaths = @() }
                    [PSCustomObject]@{ Name = 'two.txt' ; Path = 'TestDrive:\two.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; AssemblyProbingFolderPaths = @() }
                )

                $actualItems = New-Binding -Path (Get-ChildItem -Path TestDrive:\) -PassThru

                $actualItems | Should -HaveCount 2
                0..1 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
            }
        }

        Context 'Creating Bindings must be done via the ScriptBlock passed to New-ResourceManifest' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.txt
                '' > TestDrive:\two.txt
                '' > TestDrive:\six.txt
            }
            It 'Accumulates Bindings into the Manifest being built.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; AssemblyProbingFolderPaths = @() }
                    [PSCustomObject]@{ Name = 'six.txt' ; Path = 'TestDrive:\six.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; AssemblyProbingFolderPaths = @() }
                    [PSCustomObject]@{ Name = 'two.txt' ; Path = 'TestDrive:\two.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; AssemblyProbingFolderPaths = @() }
                )

                $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-Binding -Path (Get-ChildItem -Path TestDrive:\)
                }

                $builtManifest | Should -Not -BeNullOrEmpty
                $builtManifest.ContainsKey('Bindings') | Should -BeTrue
                $builtManifest.Bindings | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.Bindings[$_] | Should -BeNullOrEmpty }
            }
        }

    }
}