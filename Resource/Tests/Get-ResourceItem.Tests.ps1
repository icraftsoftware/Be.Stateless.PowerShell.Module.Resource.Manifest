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

Import-Module -Name $PSScriptRoot\..\..\Resource.Manifest.psm1 -Force

Describe 'Get-ResourceItem' {
    InModuleScope Resource.Manifest {

        Context 'When resource items does not exist' {
            It 'Throws when any item is found.' {
                { Get-ResourceItem -Name 'Test' } | Should -Throw -ExceptionType ([System.Management.Automation.RuntimeException]) -ExpectedMessage "Package item not found ``[Path: '*', Name: 'Test', Include = '``*.dll ``*.exe'``]"
            }
        }

        Context 'When resource items exists' {
            BeforeAll {
                # create some empty files
                mkdir TestDrive:\subfolder
                '' > TestDrive:\subfolder\Test.1.dll
                '' > TestDrive:\Test.2.dll
                '' > TestDrive:\Test.2.xml
            }
            It 'Returns a collection of file.' {
                $expetedResourceItems = Get-ResourceItem -PackagePath "TestDrive:\" -Name 'Test'
                $actualResourceItems = Get-ResourceItem -PackagePath "TestDrive:\" -Name 'Test'

                $actualResourceItems | Should -HaveCount 2
                0..1 | ForEach-Object -Process { Compare-Object $actualResourceItems[$_] $expetedResourceItems[$_] | Should -BeNullOrEmpty }
            }
            It 'Returns a single file.' {
                $expetedResourceItem = Get-Item 'TestDrive:\subfolder\Test.1.dll'
                $actualResourceItems = Get-ResourceItem -PackagePath "TestDrive:\" -Name 'Test.1'

                $actualResourceItems | Should -HaveCount 1
                Compare-Object $actualResourceItems[0] $expetedResourceItem | Should -BeNullOrEmpty
            }
        }
    }
}
