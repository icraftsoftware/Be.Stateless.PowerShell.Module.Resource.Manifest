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

Import-Module -Name $PSScriptRoot\..\Resource -Force

Describe 'New-Manifest' {
    InModuleScope Resource {

        Context 'When values are given by arguments' {
            It 'Returns a manifest instance.' {
                $expectedManifest = [PSCustomObject]@{ Name = 'BizTalk.Factory' ; Description = 'No comment.' ; References = @('App.1', 'App.2') }

                $actualManifest = New-Manifest -Type Application -Name 'BizTalk.Factory' -Description 'No comment.' -References 'App.1', 'App.2' -Build { }

                $actualManifest | Should -BeOfType [hashtable]
                $actualManifest.ContainsKey('Application') | Should -BeTrue
                $actualManifest.Application | Should -Not -BeNullOrEmpty
                Compare-Item -ReferenceItem $expectedManifest -DifferenceItem $actualManifest.Application | Should -BeNullOrEmpty
            }
        }

        Context 'When values are splatted' {
            It 'Returns a manifest instance.' {
                $expectedManifest = [PSCustomObject]@{ Name = 'BizTalk.Factory' ; Description = 'No comment.' ; References = @('App.1', 'App.2') }

                $arguments = @{
                    Type        = 'Application'
                    Name        = 'BizTalk.Factory'
                    Description = 'No comment.'
                    References  = 'App.1', 'App.2'
                }
                $actualManifest = New-Manifest @arguments -Build { }

                $actualManifest | Should -BeOfType [hashtable]
                $actualManifest.ContainsKey('Application') | Should -BeTrue
                $actualManifest.Application | Should -Not -BeNullOrEmpty
                Compare-Item -ReferenceItem $expectedManifest -DifferenceItem $actualManifest.Application | Should -BeNullOrEmpty
            }
        }

        Context 'Resource items can be accumulated in a Manifest' {
            It 'Initializes a manifest prior to calling the manifest build ScriptBlock.' {
                { $Manifest } | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException])
                New-Manifest -Type Application -Name 'BizTalk.Factory' -Build {
                    { $Manifest } | Should -Not -Throw
                    $Manifest.Application.Name | Should -Be BizTalk.Factory
                }
                { $Manifest } | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException])
            }
        }

    }
}