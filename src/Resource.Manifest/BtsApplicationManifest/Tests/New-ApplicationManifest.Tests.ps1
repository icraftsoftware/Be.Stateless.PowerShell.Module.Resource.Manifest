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

Describe 'New-ApplicationManifest' {
   InModuleScope Resource.Manifest {

      Context 'When values are given by arguments' {
         It 'Returns a manifest instance.' {
            $expectedManifest = [PSCustomObject]@{ Type = 'Application' ; Name = 'BizTalk.Factory' ; Description = 'No comment.' ; Reference = @('App.1', 'App.2') ; WeakReference = @('App.3', 'App.4') }

            $actualManifest = New-ApplicationManifest -Name BizTalk.Factory -Description 'No comment.' -Reference App.1, App.2 -WeakReference App.3, App.4 -Build { }

            $actualManifest | Should -BeOfType [HashTable]
            $actualManifest.ContainsKey('Properties') | Should -BeTrue
            $actualManifest.Properties | Should -Not -BeNullOrEmpty
            $actualManifest.Properties.Type | Should -Be Application
            Compare-ResourceItem -ReferenceItem $expectedManifest -DifferenceItem $actualManifest.Properties | Should -BeNullOrEmpty
         }
         It 'Returns a manifest instance with all the properties when optional arguments are null.' {
            $actualManifest = New-ApplicationManifest -Name BizTalk.Factory -Description $null -Reference $null -WeakReference $null -Build { }

            $actualManifest | Should -BeOfType [HashTable]
            $actualManifest.ContainsKey('Properties') | Should -BeTrue
            $actualManifest.Properties | Should -Not -BeNullOrEmpty
            $actualManifest.Properties | Should -BeOfType [PSCustomObject]
            $actualManifest.Properties.Type | Should -Be Application
            $actualManifest.Properties.Name | Should -Be BizTalk.Factory
            $actualManifest.Properties | Get-Member -Name Description | Should -Not -BeNullOrEmpty
            $actualManifest.Properties.Description | Should -BeNullOrEmpty
            $actualManifest.Properties | Get-Member -Name Reference | Should -Not -BeNullOrEmpty
            $actualManifest.Properties.Reference | Should -HaveCount 0
            $actualManifest.Properties | Get-Member -Name WeakReference | Should -Not -BeNullOrEmpty
            $actualManifest.Properties.WeakReference | Should -HaveCount 0
         }
         It 'Returns a manifest instance with all the properties.' {
            $actualManifest = New-ApplicationManifest -Name BizTalk.Factory -Build { }

            $actualManifest | Should -BeOfType [HashTable]
            $actualManifest.ContainsKey('Properties') | Should -BeTrue
            $actualManifest.Properties | Should -Not -BeNullOrEmpty
            $actualManifest.Properties | Should -BeOfType [PSCustomObject]
            $actualManifest.Properties.Type | Should -Be Application
            $actualManifest.Properties.Name | Should -Be BizTalk.Factory
            $actualManifest.Properties | Get-Member -Name Description | Should -Not -BeNullOrEmpty
            $actualManifest.Properties.Description | Should -BeNullOrEmpty
            $actualManifest.Properties | Get-Member -Name Reference | Should -Not -BeNullOrEmpty
            $actualManifest.Properties.Reference | Should -HaveCount 0
            $actualManifest.Properties | Get-Member -Name WeakReference | Should -Not -BeNullOrEmpty
            $actualManifest.Properties.WeakReference | Should -HaveCount 0
         }
      }

      Context 'When values are splatted' {
         It 'Returns a manifest instance.' {
            $expectedManifest = [PSCustomObject]@{ Type = 'Application' ; Name = 'BizTalk.Factory' ; Description = 'No comment.' ; Reference = @('App.1', 'App.2') ; WeakReference = @('App.3', 'App.4') }

            $arguments = @{
               Name          = 'BizTalk.Factory'
               Description   = 'No comment.'
               Reference     = 'App.1', 'App.2'
               WeakReference = 'App.3', 'App.4'
            }
            $actualManifest = New-ApplicationManifest @arguments -Build { }

            $actualManifest | Should -BeOfType [HashTable]
            $actualManifest.ContainsKey('Properties') | Should -BeTrue
            $actualManifest.Properties | Should -Not -BeNullOrEmpty
            $actualManifest.Properties.Type | Should -Be Application
            Compare-ResourceItem -ReferenceItem $expectedManifest -DifferenceItem $actualManifest.Properties | Should -BeNullOrEmpty
         }
      }

   }
}