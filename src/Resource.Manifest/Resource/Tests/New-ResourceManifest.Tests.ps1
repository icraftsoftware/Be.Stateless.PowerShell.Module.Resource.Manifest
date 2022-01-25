﻿#region Copyright & License

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

Describe 'New-ResourceManifest' {
   InModuleScope Resource.Manifest {

      Context 'When values are given by arguments' {
         It 'Returns a manifest instance.' {
            $expectedManifest = [PSCustomObject]@{ Type = 'Application'; Name = 'BizTalk.Factory' ; Description = 'No comment.' ; Reference = @('App.1', 'App.2') }

            $actualManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Description 'No comment.' -Reference 'App.1', 'App.2' -Build { }

            $actualManifest | Should -BeOfType [HashTable]
            $actualManifest.ContainsKey('Properties') | Should -BeTrue
            $actualManifest.Properties | Should -Not -BeNullOrEmpty
            $actualManifest.Properties.Type | Should -Be Application
            Compare-ResourceItem -ReferenceItem $expectedManifest -DifferenceItem $actualManifest.Properties | Should -BeNullOrEmpty
         }
      }

      Context 'When values are splatted' {
         It 'Returns a manifest instance.' {
            $expectedManifest = [PSCustomObject]@{ Type = 'Application'; Name = 'BizTalk.Factory' ; Description = 'No comment.' ; Reference = @('App.1', 'App.2') }

            $arguments = @{
               Type        = 'Application'
               Name        = 'BizTalk.Factory'
               Description = 'No comment.'
               Reference   = 'App.1', 'App.2'
            }
            $actualManifest = New-ResourceManifest @arguments -Build { }

            $actualManifest | Should -BeOfType [HashTable]
            $actualManifest.ContainsKey('Properties') | Should -BeTrue
            $actualManifest.Properties | Should -Not -BeNullOrEmpty
            $actualManifest.Properties.Type | Should -Be Application
            Compare-ResourceItem -ReferenceItem $expectedManifest -DifferenceItem $actualManifest.Properties | Should -BeNullOrEmpty
         }
      }

      Context 'Resource items can be accumulated in a Manifest' {
         It 'Initializes a manifest prior to calling the manifest build ScriptBlock.' {
            { $Manifest } | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException])
            New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               { $Manifest } | Should -Not -Throw
               $Manifest.Properties.Type | Should -Be Application
               $Manifest.Properties.Name | Should -Be BizTalk.Factory
            }
            { $Manifest } | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException])
         }
      }

   }
}