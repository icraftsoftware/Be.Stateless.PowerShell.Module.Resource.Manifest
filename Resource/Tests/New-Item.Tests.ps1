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

Describe 'New-Item' {
    BeforeAll {
        $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
    }
    InModuleScope Resource {

        Context 'Creating a new named resource Item' {
            It 'Throws when name is null.' {
                { New-Item -Resource SomeResource -Name $null } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
            It 'Throws when name is empty.' {
                { New-Item -Resource SomeResource -Name '' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
            It 'Returns a custom object with a name property.' {
                $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' }

                $actualItem = New-Item -Resource SomeResource -Name ActivityID -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a collection of custom objects with a name property.' {
                $expectedItems = [PSCustomObject]@{ Name = 'BeginTime' }, [PSCustomObject]@{ Name = 'InterchangeID' }, [PSCustomObject]@{ Name = 'ProcessName' }

                $actualItems = New-Item -Resource SomeResource -Name BeginTime, InterchangeID, ProcessName -PassThru

                $actualItems | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
            }
        }

        Context 'Creating a new file resource Item' {
            BeforeAll {
                # ensure Manifest variable is available while using the command outside of the New-Manifest -Build { BuildScriptBlock}
                $script:Manifest = @{ }
                # create some empty files
                '' > TestDrive:\one.txt
                '' > TestDrive:\two.txt
                '' > TestDrive:\six.txt
            }
            It 'Throws when path is invalid.' {
                { New-Item -Resource SomeResource -Path 'z:\folder\file.txt' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
            It 'Returns a custom object with both a path and a name property.' {
                $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }

                $actualItem = New-Item -Resource SomeResource -Path TestDrive:\one.txt -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a collection of custom objects with both a path and a name property.' {
                $expectedItems = @(
                    [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'six.txt' ; Path = 'TestDrive:\six.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                    [PSCustomObject]@{ Name = 'two.txt' ; Path = 'TestDrive:\two.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath }
                )

                $actualItems = New-Item -Resource SomeResource -Path (Get-ChildItem -Path TestDrive:\) -PassThru

                $actualItems | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
            }
            It 'Returns a named custom object with dynamic properties corresponding to UnboundArguments.' {
                $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' ; Activity = 'Process' ; Server = 'ManagementDb' }

                $actualItem = New-Item -Resource SomeResource -Name ActivityID -Activity Process -Server ManagementDb -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a named custom object with a dynamic property being a ScriptBlock.' {
                $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' ; Activity = 'Process' ; Server = 'ManagementDb' } | Add-Member -MemberType ScriptProperty -Name Predicate -Value { $true } -PassThru

                $actualItem = New-Item -Resource SomeResource -Name ActivityID -Activity Process -Server ManagementDb -Predicate { $true } -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a located custom object with dynamic properties corresponding to UnboundArguments.' {
                $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Activity = 'Process' ; Server = 'ManagementDb' }

                $actualItem = New-Item -Resource SomeResource -Path TestDrive:\one.txt -Activity Process -Server ManagementDb -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a located custom object with a dynamic property being a ScriptBlock.' {
                $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Activity = 'Process' ; Server = 'ManagementDb' } | Add-Member -MemberType ScriptProperty -Name Predicate -Value { $true } -PassThru

                $actualItem = New-Item -Resource SomeResource -Path TestDrive:\one.txt -Activity Process -Server ManagementDb -Predicate { $true } -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
        }

        Context 'Creating a new resource Item with a Condition predicate' {
            It 'Throws when Condition is neither a bool nor a ScriptBlock.' {
                { New-Item -Resource SomeResource -Name ActivityID -Condition 'some value' -Activity Process } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
            }
            It 'Does not throw when Condition is a bool.' {
                { New-Item -Resource SomeResource -Name ActivityID -Condition $false -Activity Process -PassThru } | Should -Not -Throw
            }
            It 'Does not throw when Condition is a ScriptBlock.' {
                { New-Item -Resource SomeResource -Name ActivityID -Condition { $true } -Activity Process -PassThru } | Should -Not -Throw
            }
            It 'Returns a custom object without a Condition property if it is true.' {
                $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' ; Activity = 'Process' }

                $actualItem = New-Item -Resource SomeResource -Name ActivityID -Condition $true -Activity Process -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a custom object with a Condition property if it is false.' {
                $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' ; Condition = $false ; Activity = 'Process' }

                $actualItem = New-Item -Resource SomeResource -Name ActivityID -Condition $false -Activity Process -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
            It 'Returns a custom object with a Condition property being a ScriptBlock.' {
                $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' ; Activity = 'Process' } | Add-Member -MemberType ScriptProperty -Name Condition -Value { $true } -PassThru

                $actualItem = New-Item -Resource SomeResource -Name ActivityID -Condition { $true } -Activity Process -PassThru

                Compare-Item -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
            }
        }

        Context 'Creating Items must be done via the ScriptBlock passed to New-Manifest' {
            It 'Accumulates the Items as a named Resource collection into the Manifest being built.' {
                $expectedItems = [PSCustomObject]@{ Name = 'BeginTime' }, [PSCustomObject]@{ Name = 'InterchangeID' }, [PSCustomObject]@{ Name = 'ProcessName' }

                $builtManifest = New-Manifest -Type Application -Name 'BizTalk.Factory' -Build {
                    New-Item -Resource SomeResource -Name BeginTime, InterchangeID, ProcessName
                }

                $builtManifest | Should -Not -BeNullOrEmpty
                $builtManifest.ContainsKey('SomeResource') | Should -BeTrue
                $builtManifest.SomeResource | Should -HaveCount 3
                0..2 | ForEach-Object -Process { Compare-Item -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.SomeResource[$_] | Should -BeNullOrEmpty }
            }
        }

    }
}
