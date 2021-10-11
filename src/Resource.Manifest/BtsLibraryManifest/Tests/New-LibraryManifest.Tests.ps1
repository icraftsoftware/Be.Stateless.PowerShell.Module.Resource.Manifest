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

Describe 'New-LibraryManifest' {
    InModuleScope Resource.Manifest {

        Context 'When values are given by arguments' {
            It 'Returns a manifest instance.' {
                $expectedManifest = [PSCustomObject]@{ Type = 'Library' ; Name = 'BizTalk.Factory' ; Description = 'No comment.' }

                $actualManifest = New-LibraryManifest -Name 'BizTalk.Factory' -Description 'No comment.' -Build { }

                $actualManifest | Should -BeOfType [HashTable]
                $actualManifest.ContainsKey('Properties') | Should -BeTrue
                $actualManifest.Properties | Should -Not -BeNullOrEmpty
                $actualManifest.Properties.Type | Should -Be Library
                Compare-ResourceItem -ReferenceItem $expectedManifest -DifferenceItem $actualManifest.Properties | Should -BeNullOrEmpty
            }
            It 'Returns a manifest instance with all the properties.' {
                $actualManifest = New-LibraryManifest -Name 'BizTalk.Factory' -Build { }

                $actualManifest | Should -BeOfType [HashTable]
                $actualManifest.ContainsKey('Properties') | Should -BeTrue
                $actualManifest.Properties | Should -Not -BeNullOrEmpty
                $actualManifest.Properties.Type | Should -Be Library
                $actualManifest.Properties.Name | Should -Be 'BizTalk.Factory'
                $actualManifest.Properties.Description | Should -BeNullOrEmpty
            }
        }

        Context 'When values are splatted' {
            It 'Returns a manifest instance.' {
                $expectedManifest = [PSCustomObject]@{ Type = 'Library' ; Name = 'BizTalk.Factory' ; Description = 'No comment.' }

                $arguments = @{
                    Name        = 'BizTalk.Factory'
                    Description = 'No comment.'
                }
                $actualManifest = New-LibraryManifest @arguments -Build { }

                $actualManifest | Should -BeOfType [HashTable]
                $actualManifest.ContainsKey('Properties') | Should -BeTrue
                $actualManifest.Properties | Should -Not -BeNullOrEmpty
                $actualManifest.Properties.Type | Should -Be Library
                Compare-ResourceItem -ReferenceItem $expectedManifest -DifferenceItem $actualManifest.Properties | Should -BeNullOrEmpty
            }
        }

    }
}