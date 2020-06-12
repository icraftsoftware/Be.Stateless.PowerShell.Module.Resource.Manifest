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

Import-Module -Name $PSScriptRoot\..\BtsTransform -Force
Import-Module -Name $PSScriptRoot\..\..\Resource -Force

Describe 'New-Transform' {
    InModuleScope BtsTransform {

        Context 'When Transform file does not exist' {
            BeforeAll {
                $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
            }
            It 'Throws a ParameterBindingValidationException.' {
                { New-Transform -Path 'z:\Transform.dll' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
        }

        Context 'When Transform file exists' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.txt
                '' > TestDrive:\two.txt
            }
            It 'Returns a custom object with both a path and a name property.' {
                $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }

                $actualItem = New-Transform -Path TestDrive:\one.txt -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a collection of custom objects with both a path and a name property.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'two.txt' ; Path = 'TestDrive:\two.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )

                $actualItems = New-Transform -Path (Get-ChildItem -Path TestDrive:\) -PassThru

                $actualItems | Should -HaveCount 2
                0..1 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
            }
        }

        Context 'Creating Transforms must be done via the ScriptBlock passed to New-Manifest' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.txt
                '' > TestDrive:\two.txt
                '' > TestDrive:\six.txt
            }
            It 'Accumulates Transforms into the Manifest being built.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'six.txt' ; Path = 'TestDrive:\six.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'two.txt' ; Path = 'TestDrive:\two.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )

                $builtManifest = New-Manifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-Transform -Path (Get-ChildItem -Path TestDrive:\)
                }

                $builtManifest | Should -Not -BeNullOrEmpty
                $builtManifest.ContainsKey('Transforms') | Should -BeTrue
                $builtManifest.Transforms | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.Transforms[$_] | Should -BeNullOrEmpty }
            }
        }

    }
}