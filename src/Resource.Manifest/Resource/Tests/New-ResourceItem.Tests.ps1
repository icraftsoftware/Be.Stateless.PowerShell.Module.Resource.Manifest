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

Describe 'New-ResourceItem' {
   InModuleScope Resource.Manifest {

      Context 'Creating a new named resource Item' {
         BeforeAll {
            $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
         }
         It 'Throws when name is null.' {
            { New-ResourceItem -ResourceGroup SomeResources -Name $null } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
         It 'Throws when name is empty.' {
            { New-ResourceItem -ResourceGroup SomeResources -Name '' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
         It 'Returns a custom object with a name property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' }

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Name ActivityID -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a collection of custom objects with a name property.' {
            $expectedItems = [PSCustomObject]@{ Name = 'BeginTime' }, [PSCustomObject]@{ Name = 'InterchangeID' }, [PSCustomObject]@{ Name = 'ProcessName' }

            $actualItems = New-ResourceItem -ResourceGroup SomeResources -Name BeginTime, InterchangeID, ProcessName -PassThru

            $actualItems | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
         }
      }

      Context 'Creating a new file resource Item' {
         BeforeAll {
            # ensure Manifest variable is available while using the command outside of the New-ResourceManifest -Build { BuildScriptBlock}
            $script:Manifest = @{ }
            # create some empty files
            '' > TestDrive:\one.txt
            '' > TestDrive:\two.txt
            '' > TestDrive:\six.txt
         }
         It 'Does not throw when path is not found.' {
            { New-ResourceItem -ResourceGroup SomeResources -Path 'c:\folder\file.txt' } | Should -Not -Throw
         }
         It 'Throws when path is found but cannot be resolved.' {
            Mock -CommandName Test-Path -MockWith { return $true } -ParameterFilter { $Path -eq 'c:\folder\file.txt' }
            { New-ResourceItem -ResourceGroup SomeResources -Path 'c:\folder\file.txt' } | Should -Throw -ExceptionType 'System.Management.Automation.ItemNotFoundException, System.Management.Automation'
         }
         It 'Returns a custom object with both a path and a name property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" }

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Path TestDrive:\one.txt -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a custom object with both a path and a custom name property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'MyName' ; Path = "$TestDrive\one.txt" }

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Path TestDrive:\one.txt -Name MyName -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a custom object with only a name property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'MyName' }

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Name MyName -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a collection of custom objects with both a path and a name property.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" }
               [PSCustomObject]@{ Name = 'six.txt' ; Path = "$TestDrive\six.txt" }
               [PSCustomObject]@{ Name = 'two.txt' ; Path = "$TestDrive\two.txt" }
            )

            $actualItems = New-ResourceItem -ResourceGroup SomeResources -Path (Get-ChildItem -Path TestDrive:\) -PassThru

            $actualItems | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
         }
         It 'Returns a named custom object with dynamic properties corresponding to UnboundArguments.' {
            $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' ; Activity = 'Process' ; Server = 'ManagementDb' }

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Name ActivityID -Activity Process -Server ManagementDb -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a named custom object with a dynamic method being a ScriptBlock.' {
            $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' ; Activity = 'Process' ; Server = 'ManagementDb' } | Add-Member -MemberType ScriptMethod -Name Predicate -Value { $true } -PassThru

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Name ActivityID -Activity Process -Server ManagementDb -Predicate { $true } -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a located custom object with dynamic properties corresponding to UnboundArguments.' {
            $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" ; Activity = 'Process' ; Server = 'ManagementDb' }

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Path TestDrive:\one.txt -Activity Process -Server ManagementDb -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a located custom object with a dynamic method being a ScriptBlock.' {
            $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" ; Activity = 'Process' ; Server = 'ManagementDb' } | Add-Member -MemberType ScriptMethod -Name Predicate -Value { $true } -PassThru

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Path TestDrive:\one.txt -Activity Process -Server ManagementDb -Predicate { $true } -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
      }

      Context 'Creating a new resource Item with a Condition predicate' {
         It 'Throws when Condition is neither a bool nor a ScriptBlock.' {
            { New-ResourceItem -ResourceGroup SomeResources -Name ActivityID -Condition 'some value' -Activity Process } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
         It 'Does not throw when Condition is a bool.' {
            { New-ResourceItem -ResourceGroup SomeResources -Name ActivityID -Condition $false -Activity Process -PassThru } | Should -Not -Throw
         }
         It 'Does not throw when Condition is a ScriptBlock.' {
            { New-ResourceItem -ResourceGroup SomeResources -Name ActivityID -Condition { $true } -Activity Process -PassThru } | Should -Not -Throw
         }
         It 'Returns a custom object without a Condition property if it is true.' {
            $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' ; Activity = 'Process' }

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Name ActivityID -Condition $true -Activity Process -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a custom object with a Condition property if it is false.' {
            $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' ; Condition = $false ; Activity = 'Process' }

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Name ActivityID -Condition $false -Activity Process -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a custom object with a Condition method being a ScriptBlock.' {
            $expectedItem = [PSCustomObject]@{ Name = 'ActivityID' ; Activity = 'Process' } | Add-Member -MemberType ScriptMethod -Name Condition -Value { $true } -PassThru

            $actualItem = New-ResourceItem -ResourceGroup SomeResources -Name ActivityID -Condition { $true } -Activity Process -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
      }

      Context 'Creating Items must be done via the ScriptBlock passed to New-ResourceManifest' {
         It 'Accumulates the Items as a named Resource collection into the Manifest being built.' {
            $expectedItems = [PSCustomObject]@{ Name = 'BeginTime' }, [PSCustomObject]@{ Name = 'InterchangeID' }, [PSCustomObject]@{ Name = 'ProcessName' }

            $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               New-ResourceItem -ResourceGroup SomeResources -Name BeginTime, InterchangeID, ProcessName
            }

            $builtManifest | Should -Not -BeNullOrEmpty
            $builtManifest.ContainsKey('SomeResources') | Should -BeTrue
            $builtManifest.SomeResources | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.SomeResources[$_] | Should -BeNullOrEmpty }
         }
         It 'Does not accumulate the Items whose condition is false into the Manifest being built.' {
            $expectedItems = [PSCustomObject]@{ Name = 'ProcessName' }

            $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               New-ResourceItem -ResourceGroup SomeResources -Name BeginTime, InterchangeID -Condition $false
               New-ResourceItem -ResourceGroup SomeResources -Name ProcessName
            }

            $builtManifest | Should -Not -BeNullOrEmpty
            $builtManifest.ContainsKey('SomeResources') | Should -BeTrue
            $builtManifest.SomeResources | Should -HaveCount 1
            Compare-ResourceItem -ReferenceItem $expectedItems -DifferenceItem $builtManifest.SomeResources | Should -BeNullOrEmpty
         }
      }

   }
}
