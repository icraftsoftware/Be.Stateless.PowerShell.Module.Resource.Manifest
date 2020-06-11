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

Import-Module -Name $PSScriptRoot\..\BtsBamIndex -Force

Describe 'New-BamIndex' {
    InModuleScope BtsBamIndex {

        Context 'When BamIndex file does not exist' {
            BeforeAll {
                $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
            }
            It 'Throws a ParameterBindingValidationException.' {
                { New-BamIndex -Name InterchangeID -Activity '' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
        }

        Context 'When BamIndex file exists' {
            BeforeAll {
                # ensure Manifest variable is available while using the command outside of the New-Manifest -Build { BuildScriptBlock}
                New-Variable -Name Manifest -Value @{ } -Scope Global
            }
            It 'Returns a custom object with both a path and a name property.' {
                $expectedItem = [PSCustomObject]@{ Name = 'BeginTime' ; Activity = 'Process' }

                $actualItem = New-BamIndex -Name BeginTime -Activity Process -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a collection of custom objects with both a path and a name property.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'BeginTime' ; Activity = 'Process' }
                    [PSCustomObject]@{ Name = 'InterchangeID' ; Activity = 'Process' }
                )

                $actualItems = New-BamIndex -Name BeginTime, InterchangeID -Activity Process -PassThru

                $actualItems | Should -HaveCount 2
                0..1 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
            }
            AfterAll {
                Remove-Variable -Name Manifest -Scope Global -Force
            }
        }

        Context 'Creating BamIndexes must be done via the ScriptBlock passed to New-Manifest' {
            It 'Accumulates the Items as a BamIndexes resource collection of the Manifest being built.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'BeginTime' ; Activity = 'Process' }
                    [PSCustomObject]@{ Name = 'InterchangeID' ; Activity = 'Process' }
                    [PSCustomObject]@{ Name = 'ProcessName' ; Activity = 'Process' }
                )

                $manifest = New-Manifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-BamIndex -Name BeginTime, InterchangeID, ProcessName -Activity Process
                }

                $manifest | Should -Not -BeNullOrEmpty
                $manifest.ContainsKey('BamIndexes') | Should -BeTrue
                $manifest.BamIndexes | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedItems[$_] -DifferenceItem $manifest.BamIndexes[$_] | Should -BeNullOrEmpty }
            }
        }

    }
}