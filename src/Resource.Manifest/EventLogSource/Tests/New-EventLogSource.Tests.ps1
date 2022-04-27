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

Describe 'New-EventLogSource' {
   InModuleScope Resource.Manifest {

      Context 'When either EventLogSource''s Name or LogName is null or empty' {
         BeforeAll {
            $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
         }
         It 'Throws a ParameterBindingValidationException.' {
            { New-EventLogSource -Name '' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
         It 'Throws a ParameterBindingValidationException.' {
            { New-EventLogSource -Name 'SourceName' -LogName '' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
      }

      Context 'When neither EventLogSource''s Name nor LogName is null or empty' {
         It 'Returns a custom object with a name property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'BizTalk Factory' ; LogName = 'System' }

            $actualItem = New-EventLogSource -Name 'BizTalk Factory' -LogName System -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a collection of custom objects with a name property.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'Claim Store Agent' ; LogName = 'System' }
               [PSCustomObject]@{ Name = 'BizTalk Factory' ; LogName = 'System' }
            )

            $actualItems = New-EventLogSource -Name 'Claim Store Agent', 'BizTalk Factory' -LogName System -PassThru

            $actualItems | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
         }
      }

      Context 'Creating EventLogSources must be done via the ScriptBlock passed to New-ResourceManifest' {
         It 'Accumulates EventLogSources into the Manifest being built.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'BizTalk Factory' ; LogName = 'System' }
               [PSCustomObject]@{ Name = 'Claim Store Agent' ; LogName = 'System' }
            )

            $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               New-EventLogSource -Name 'BizTalk Factory', 'Claim Store Agent' -LogName System
            }

            $builtManifest | Should -Not -BeNullOrEmpty
            $builtManifest.ContainsKey('EventLogSources') | Should -BeTrue
            $builtManifest.EventLogSources | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.EventLogSources[$_] | Should -BeNullOrEmpty }
         }
      }

   }
}