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

Import-Module -Name $PSScriptRoot\..\SqlDeploymentScript -Force
Import-Module -Name $PSScriptRoot\..\..\Resource -Force

Describe 'New-SqlDeploymentScript' {
    InModuleScope SqlDeploymentScript {

        Context 'When SqlDeploymentScript file does not exist' {
            BeforeAll {
                $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
            }
            It 'Throws a ParameterBindingValidationException.' {
                { New-SqlDeploymentScript -Path 'z:\SqlDeploymentScript.dll' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
        }

        Context 'When SqlDeploymentScript file exists' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.sql
                '' > TestDrive:\two.sql
            }
            It 'Returns a custom object with both a path and a name property.' {
                $expectedItem = [PSCustomObject]@{ Name = 'one.sql' ; Server = 'localhost' ; Variables = @{ Login = 'account' } ; Path = 'TestDrive:\one.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }

                $actualItem = New-SqlDeploymentScript -Path TestDrive:\one.sql -Server localhost -Variables @{ Login = 'account' } -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a collection of custom objects with both a path and a name property.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\one.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'two.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\two.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )

                $actualItems = New-SqlDeploymentScript -Path (Get-ChildItem -Path TestDrive:\) -Server localhost -PassThru

                $actualItems | Should -HaveCount 2
                0..1 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
            }
        }

        Context 'Creating SqlDeploymentScripts must be done via the ScriptBlock passed to New-Manifest' {
            BeforeAll {
                # create some empty files
                '' > TestDrive:\one.sql
                '' > TestDrive:\two.sql
                '' > TestDrive:\six.sql
            }
            It 'Accumulates SqlDeploymentScripts into the Manifest being built.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\one.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'six.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\six.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'two.sql' ; Server = 'localhost' ; Variables = @{} ; Path = 'TestDrive:\two.sql' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )

                $builtManifest = New-Manifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-SqlDeploymentScript -Path (Get-ChildItem -Path TestDrive:\) -Server localhost
                }

                $builtManifest | Should -Not -BeNullOrEmpty
                $builtManifest.ContainsKey('SqlDeploymentScripts') | Should -BeTrue
                $builtManifest.SqlDeploymentScripts | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.SqlDeploymentScripts[$_] | Should -BeNullOrEmpty }
            }
        }

    }
}