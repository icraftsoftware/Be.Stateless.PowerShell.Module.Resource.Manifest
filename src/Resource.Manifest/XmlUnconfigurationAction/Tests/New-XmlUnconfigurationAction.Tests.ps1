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

Describe 'New-XmlUnconfigurationAction' {
    InModuleScope Resource.Manifest {

        Context 'When configuration file does not exist' {
            BeforeAll {
                $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
            }
            It 'Throws a ParameterBindingValidationException.' {
                { New-XmlUnconfigurationAction -Path 'c:\web.config' -Delete /configuration } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
        }

        Context 'When configuration file exists' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.config
            }
            It 'Returns a custom object with a delete action.' {
                $expectedItem = [PSCustomObject]@{ Name = 'one.config' ; Path = 'TestDrive:\one.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Action = 'Delete' ; XPath = '/configuration/node' }

                $actualItem = New-XmlUnconfigurationAction -Path TestDrive:\one.config -Delete /configuration/node -PassThru

                Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a custom object with an insert action.' {
                $expectedItem = [PSCustomObject]@{ Name = 'node' ; Path = 'TestDrive:\one.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Action = 'Append' ; XPath = '/configuration' ; Attributes = @{} }

                $actualItem = New-XmlUnconfigurationAction -Path TestDrive:\one.config -Append /configuration -ElementName node -PassThru

                Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a custom object with an insert action and attributes.' {
                $expectedItem = [PSCustomObject]@{ Name = 'node' ; Path = 'TestDrive:\one.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Action = 'Append' ; XPath = '/configuration' ; Attributes = @{ a1 = 'v1' ; a2 = 'v2' } }

                $actualItem = New-XmlUnconfigurationAction -Path TestDrive:\one.config -Append /configuration -ElementName node -Attributes @{ a1 = 'v1' ; a2 = 'v2' } -PassThru

                Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a custom object with an update action.' {
                $expectedItem = [PSCustomObject]@{ Name = 'one.config' ; Path = 'TestDrive:\one.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Action = 'Update' ; XPath = '/configuration/node' ; Attributes = @{ a1 = 'v1' ; a2 = 'v2' } }

                $actualItem = New-XmlUnconfigurationAction -Path TestDrive:\one.config -Update /configuration/node -Attributes @{ a1 = 'v1' ; a2 = 'v2' } -PassThru

                Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
        }

        Context 'Creating XmlUnconfigurationActions must be done via the ScriptBlock passed to New-Manifest' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.config
            }
            It 'Accumulates XmlUnconfigurationActions into the Manifest being built.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.config' ; Path = 'TestDrive:\one.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Action = 'Delete' ; XPath = '/configuration/node' }
                    [PSCustomObject]@{ Name = 'node' ; Path = 'TestDrive:\one.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Action = 'Append' ; XPath = '/configuration' ; Attributes = @{ a1 = 'v1' ; a2 = 'v2' } }
                    [PSCustomObject]@{ Name = 'one.config' ; Path = 'TestDrive:\one.config' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Action = 'Update' ; XPath = '/configuration/node' ; Attributes = @{ a1 = 'v1' ; a2 = 'v2' } }
                )

                $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-XmlUnconfigurationAction -Path TestDrive:\one.config -Delete /configuration/node
                    New-XmlUnconfigurationAction -Path TestDrive:\one.config -Append /configuration -Name node -Attributes @{ a1 = 'v1' ; a2 = 'v2' }
                    New-XmlUnconfigurationAction -Path TestDrive:\one.config -Update /configuration/node -Attributes @{ a1 = 'v1' ; a2 = 'v2' }
                }

                $builtManifest | Should -Not -BeNullOrEmpty
                $builtManifest.ContainsKey('XmlUnconfigurationActions') | Should -BeTrue
                $builtManifest.XmlUnconfigurationActions | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.XmlUnconfigurationActions[$_] | Should -BeNullOrEmpty }
            }
        }

    }
}
