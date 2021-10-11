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

Describe 'New-XmlConfiguration' {
    InModuleScope Resource.Manifest {

        Context 'When Configuration Specification file does not exist' {
            BeforeAll {
                $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
            }
            It 'Throws a ParameterBindingValidationException.' {
                { New-XmlConfiguration -Path 'c:\web.config' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
        }

        Context 'When Configuration Specification file exists' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.config
                '' > TestDrive:\two.config
            }
            It 'Returns a custom object with both a path and a name property.' {
                $expectedItem = [PSCustomObject]@{ Name = 'one.config' ; Path = 'TestDrive:\one.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }

                $actualItem = New-XmlConfiguration -Path TestDrive:\one.config -PassThru

                Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a collection of custom objects with both a path and a name property.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.config' ; Path = 'TestDrive:\one.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'two.config' ; Path = 'TestDrive:\two.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )

                $actualItems = New-XmlConfiguration -Path (Get-ChildItem -Path TestDrive:\) -PassThru

                $actualItems | Should -HaveCount 2
                0..1 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
            }
        }

        Context 'Creating XmlConfigurations must be done via the ScriptBlock passed to New-Manifest' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.config
                '' > TestDrive:\two.config
                '' > TestDrive:\six.config
            }
            It 'Accumulates XmlConfigurations into the Manifest being built.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.config' ; Path = 'TestDrive:\one.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'six.config' ; Path = 'TestDrive:\six.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'two.config' ; Path = 'TestDrive:\two.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )

                $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-XmlConfiguration -Path (Get-ChildItem -Path TestDrive:\)
                }

                $builtManifest | Should -Not -BeNullOrEmpty
                $builtManifest.ContainsKey('XmlConfigurations') | Should -BeTrue
                $builtManifest.XmlConfigurations | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.XmlConfigurations[$_] | Should -BeNullOrEmpty }
            }
        }

    }
}
