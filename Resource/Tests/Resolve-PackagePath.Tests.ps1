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

Describe 'Resolve-PackagePath' {
    InModuleScope Resource.Manifest {

        Context 'When value are passed by argument' {
            BeforeAll{
                mkdir TestDrive:\Deployment\bin\Debug\net48
            }
            It 'Returns the asbolute path.' {
                Resolve-PackagePath -Path 'TestDrive:\' -Configuration Debug | Should -Be 'TestDrive:\Deployment\bin\Debug\net48'
            }
            It 'Throws when the path does not exist.' {
                { Resolve-PackagePath -Path 'TestDrive:\' -Configuration Release } | Should -Throw -ExpectedMessage 'Cannot find path ''TestDrive:\Deployment\bin\Release\net48'' because it does not exist.'
            }
        }
    }
}
