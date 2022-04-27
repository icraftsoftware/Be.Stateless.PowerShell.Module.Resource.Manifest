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
         It 'Does not throw because AssemblyProbingFolderPath is empty.' {
            { New-Binding -Path TestDrive:\six.txt -AssemblyProbingFolderPath @() -PassThru } | Should -Not -Throw
         }
         It 'Throws because AssemblyProbingFolderPath do not exist.' {
            { New-Binding -Path TestDrive:\six.txt -AssemblyProbingFolderPath 'TestDrive:\foo' -PassThru } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
         It 'Does not throw because EnvironmentSettingOverridesTypeName is null.' {
            { New-Binding -Path TestDrive:\six.txt -EnvironmentSettingOverridesTypeName $null -PassThru } | Should -Not -Throw
         }
         It 'Does not throw because EnvironmentSettingOverridesTypeName is empty.' {
            { New-Binding -Path TestDrive:\six.txt -EnvironmentSettingOverridesTypeName '' -PassThru } | Should -Not -Throw
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
            $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" ; AssemblyProbingFolderPath = @() }

            $actualItem = New-Binding -Path TestDrive:\one.txt -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns an object with AssemblyProbingFolderPath and EnvironmentSettingOverridesTypeName.' {
            $expectedItem = [PSCustomObject]@{
               Name                                = 'one.txt'
               Path                                = "$TestDrive\one.txt"
               AssemblyProbingFolderPath           = ($PSScriptRoot | Resolve-Path | Split-Path -Parent), ($PSScriptRoot | Resolve-Path | Split-Path -Parent | Split-Path -Parent)
               EnvironmentSettingOverridesTypeName = 'some-environment-setting-overrides-type-name'
            }

            $actualItem = New-Binding -Path TestDrive:\one.txt -AssemblyProbingFolderPath $expectedItem.AssemblyProbingFolderPath[0], $expectedItem.AssemblyProbingFolderPath[1] -EnvironmentSettingOverridesTypeName $expectedItem.EnvironmentSettingOverridesTypeName -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a collection of custom objects with both a path and a name property.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" ; AssemblyProbingFolderPath = @() }
               [PSCustomObject]@{ Name = 'two.txt' ; Path = "$TestDrive\two.txt" ; AssemblyProbingFolderPath = @() }
            )

            $actualItems = New-Binding -Path (Get-ChildItem -Path TestDrive:\) -PassThru

            $actualItems | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
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
               [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" ; AssemblyProbingFolderPath = @() }
               [PSCustomObject]@{ Name = 'six.txt' ; Path = "$TestDrive\six.txt" ; AssemblyProbingFolderPath = @() }
               [PSCustomObject]@{ Name = 'two.txt' ; Path = "$TestDrive\two.txt" ; AssemblyProbingFolderPath = @() }
            )

            $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               New-Binding -Path (Get-ChildItem -Path TestDrive:\)
            }

            $builtManifest | Should -Not -BeNullOrEmpty
            $builtManifest.ContainsKey('Bindings') | Should -BeTrue
            $builtManifest.Bindings | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.Bindings[$_] | Should -BeNullOrEmpty }
         }
      }

   }
}