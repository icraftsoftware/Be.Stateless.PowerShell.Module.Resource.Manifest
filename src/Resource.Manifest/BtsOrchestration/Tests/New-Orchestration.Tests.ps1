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

Describe 'New-Orchestration' {
   InModuleScope Resource.Manifest {

      Context 'When Orchestration file does not exist' {
         BeforeAll {
            $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
         }
         It 'Throws a ParameterBindingValidationException.' {
            { New-Orchestration -Path 'c:\Orchestration.dll' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
      }

      Context 'When Orchestration file exists' {
         BeforeAll {
            # create some empty files
            '' > TestDrive:\one.txt
            '' > TestDrive:\two.txt
         }
         It 'Returns a custom object with both a path and a name property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" }

            $actualItem = New-Orchestration -Path TestDrive:\one.txt -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a collection of custom objects with both a path and a name property.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" }
               [PSCustomObject]@{ Name = 'two.txt' ; Path = "$TestDrive\two.txt" }
            )

            $actualItems = New-Orchestration -Path (Get-ChildItem -Path TestDrive:\) -PassThru

            $actualItems | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
         }
      }

      Context 'Creating Orchestrations must be done via the ScriptBlock passed to New-ResourceManifest' {
         BeforeAll {
            # create some empty files
            '' > TestDrive:\one.txt
            '' > TestDrive:\two.txt
            '' > TestDrive:\six.txt
         }
         It 'Accumulates Orchestrations into the Manifest being built.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" }
               [PSCustomObject]@{ Name = 'six.txt' ; Path = "$TestDrive\six.txt" }
               [PSCustomObject]@{ Name = 'two.txt' ; Path = "$TestDrive\two.txt" }
            )

            $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               New-Orchestration -Path (Get-ChildItem -Path TestDrive:\)
            }

            $builtManifest | Should -Not -BeNullOrEmpty
            $builtManifest.ContainsKey('Orchestrations') | Should -BeTrue
            $builtManifest.Orchestrations | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.Orchestrations[$_] | Should -BeNullOrEmpty }
         }
      }

   }
}