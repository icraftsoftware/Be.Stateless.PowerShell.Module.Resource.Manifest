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

Describe 'Get-ResourceItem' {
    InModuleScope Resource.Manifest {

        Context 'When resource file does not exist' {
            It 'Throws when no resource item is found.' {
                { Get-ResourceItem -Name Test } | Should -Throw `
                    -ExceptionType ([System.Management.Automation.RuntimeException]) `
                    -ExpectedMessage "Resource item not found ``[Path: '*', Name: 'Test', Extension = '.dll, .exe']."
            }
        }

        Context 'When resource file exists' {
            BeforeAll {
                # create some empty files
                mkdir TestDrive:\subfolder
                '' > TestDrive:\subfolder\Ambiguous.dll
                '' > TestDrive:\subfolder\Test.1.dll
                '' > TestDrive:\Ambiguous.dll
                '' > TestDrive:\Test.2.dll
                '' > TestDrive:\Test.2.xml
            }
            It 'Throws when multiple resource items with the same name are found.' {
                { Get-ResourceItem -FolderPath TestDrive:\ -Name Ambiguous } | Should -Throw `
                    -ExceptionType ([System.Management.Automation.RuntimeException]) `
                    -ExpectedMessage "Ambiguous resource items found ``['Ambiguous.dll'] matching criteria ``[Path: '*', Name: 'Ambiguous', Extensions = '.dll, .exe']."
            }
            It 'Returns a collection of resource items.' {
                $actualResourceItems = Get-Item -Path TestDrive:\subfolder\Test.1.dll, TestDrive:\Test.2.dll

                $expectedResourceItems = Get-ResourceItem -FolderPath TestDrive:\ -Name Test.1, Test.2
                $expectedResourceItems | Should -HaveCount 2

                0..1 | ForEach-Object -Process { Compare-Object -ReferenceObject  $actualResourceItems[$_] -DifferenceObject $expectedResourceItems[$_] | Should -BeNullOrEmpty }
            }
            It 'Returns a single resource item.' {
                $actualResourceItem = Get-Item -Path TestDrive:\Test.2.dll
                $expectedResourceItem = Get-ResourceItem -FolderPath (Resolve-Path TestDrive:\ | Select-Object -ExpandProperty ProviderPath) -Name Test.2
                Compare-Object -ReferenceObject $expectedResourceItem -DifferenceObject $actualResourceItem  | Should -BeNullOrEmpty
            }
        }
    }
}
