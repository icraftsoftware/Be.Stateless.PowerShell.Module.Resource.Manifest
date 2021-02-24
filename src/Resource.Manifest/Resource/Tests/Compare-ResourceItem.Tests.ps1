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

Describe 'Compare-ResourceItem' {
   InModuleScope Resource.Manifest {

      Context 'When both Items are null' {
         It 'Returns nothing.' {
            { Compare-ResourceItem -ReferenceItem $null -DifferenceItem $null } | Should -Throw
         }
      }

      Context 'When one Item is not a PSCustomObject' {
         BeforeAll {
            $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
         }
         It 'Throws when ReferenceItem is a HashTable.' {
            { Compare-ResourceItem -ReferenceItem (@{Name = 'Stark' }) -DifferenceItem [PSCustomObject](@{ Name = 'Stark' }) } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
         It 'Throws when DifferenceItem is a HashTable.' {
            { Compare-ResourceItem -ReferenceItem [PSCustomObject](@{Name = 'Stark' }) -DifferenceItem (@{ Name = 'Stark' }) } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
      }

      Context 'When both Items have one identical property' {
         It 'Returns nothing.' {
            $left = [PSCustomObject]@{ a = 'x' }
            $right = [PSCustomObject]@{ a = 'x' }
            Compare-ResourceItem -ReferenceItem $left -DifferenceItem $right | Should -BeNullOrEmpty
         }
      }

      Context 'When both Items have several identical properties' {
         It 'Returns nothing.' {
            $left = [PSCustomObject]@{ firstname = 'pepper' ; lastname = 'potts' ; displayname = 'pepper potts' }
            $right = [PSCustomObject]@{ firstname = 'pepper' ; lastname = 'potts' ; displayname = 'pepper potts' }
            Compare-ResourceItem -ReferenceItem $left -DifferenceItem $right | Should -BeNullOrEmpty
         }
      }

      Context 'When reference Item contains a key with a null value' {
         It 'Returns ''a <''.' {
            $left = [PSCustomObject]@{ a = $null }
            $right = [PSCustomObject]@{ }

            [object[]]$result = Compare-ResourceItem -ReferenceItem $left -DifferenceItem $right

            $result.Length | Should -Be 1
            $result.Property | Should -Be 'a'
            $result.ReferenceValue | Should -BeNullOrEmpty
            $result.SideIndicator | Should -Be '<'
            $result.DifferenceValue | Should -BeNullOrEmpty
         }
      }

      Context 'When difference Item contains a key with a null value' {
         It 'Returns ''a >''.' {
            $left = [PSCustomObject]@{ }
            $right = [PSCustomObject]@{ a = $null }

            [object[]]$result = Compare-ResourceItem -ReferenceItem $left -DifferenceItem $right

            $result.Length | Should -Be 1
            $result.Property | Should -Be 'a'
            $result.ReferenceValue | Should -BeNullOrEmpty
            $result.SideIndicator | Should -Be '>'
            $result.DifferenceValue | Should -BeNullOrEmpty
         }
      }

      Context 'When reference and difference Items have one property that is different' {
         It 'Returns ''a value <>''.' {
            $left = [PSCustomObject]@{ a = 'value' }
            $right = [PSCustomObject]@{ a = $null }

            [object[]]$result = Compare-ResourceItem -ReferenceItem $left -DifferenceItem $right

            $result.Length | Should -Be 1
            $result.Property | Should -Be 'a'
            $result.ReferenceValue | Should -Be 'value'
            $result.SideIndicator | Should -Be '<>'
            $result.DifferenceValue | Should -BeNullOrEmpty
         }
         It 'Returns ''role partner <> assistance''.' {
            $left = [PSCustomObject]@{ firstname = 'pepper' ; lastname = 'potts' ; role = 'partner' }
            $right = [PSCustomObject]@{ firstname = 'pepper' ; lastname = 'potts' ; role = 'assistant' }

            [object[]]$result = Compare-ResourceItem -ReferenceItem $left -DifferenceItem $right

            $result.Length | Should -Be 1
            $result.Property | Should -Be 'role'
            $result.ReferenceValue | Should -Be 'partner'
            $result.SideIndicator | Should -Be '<>'
            $result.DifferenceValue | Should -Be 'assistant'
         }
      }

      Context 'When Items have an array property' {
         It 'Returns nothing.' {
            $left = [PSCustomObject]@{ firstname = 'pepper' ; array = 1, 2 }
            $right = [PSCustomObject]@{ firstname = 'pepper' ; array = 1, 2 }

            Compare-ResourceItem -ReferenceItem $left -DifferenceItem $right | Should -BeNullOrEmpty
         }
         It 'Returns ''array (1, 2)) <> (3, 4, 5)''.' {
            $left = [PSCustomObject]@{ firstname = 'pepper' ; array = 1, 2 }
            $right = [PSCustomObject]@{ firstname = 'pepper' ; array = 3, 4, 5 }

            [object[]]$result = Compare-ResourceItem -ReferenceItem $left -DifferenceItem $right

            $result.Length | Should -Be 1
            $result.Property | Should -Be 'array'
            $result.ReferenceValue | Should -Be '(1, 2)'
            $result.SideIndicator | Should -Be '<>'
            $result.DifferenceValue | Should -Be '(3, 4, 5)'
         }
      }

      Context 'When Items have a hashtable property' {
         It 'Returns nothing.' {
            $left = [PSCustomObject]@{ firstname = 'pepper' ; hashtable = @{ prop = 'value' } }
            $right = [PSCustomObject]@{ firstname = 'pepper' ; hashtable = @{ prop = 'value' } }

            Compare-ResourceItem -ReferenceItem $left -DifferenceItem $right | Should -BeNullOrEmpty
         }
         It 'Returns ''hashtable.one 1 `<'', ''hashtable.six 6 `<`> 9'', ''hashtable.two `> 2''.' {
            $left = [PSCustomObject]@{ firstname = 'pepper' ; hashtable = @{ one = '1' ; six = '6' } }
            $right = [PSCustomObject]@{ firstname = 'pepper' ; hashtable = @{ two = '2' ; six = '9' } }

            [object[]]$result = Compare-ResourceItem -ReferenceItem $left -DifferenceItem $right

            $result.Length | Should -Be 3

            $result[0].Key | Should -Be 'hashtable.one'
            $result[0].ReferenceValue | Should -Be '1'
            $result[0].SideIndicator | Should -Be '<'
            $result[0].DifferenceValue | Should -Be $null

            $result[1].Key | Should -Be 'hashtable.six'
            $result[1].ReferenceValue | Should -Be '6'
            $result[1].SideIndicator | Should -Be '<>'
            $result[1].DifferenceValue | Should -Be '9'

            $result[2].Key | Should -Be 'hashtable.two'
            $result[2].ReferenceValue | Should -Be $null
            $result[2].SideIndicator | Should -Be '>'
            $result[2].DifferenceValue | Should -Be '2'
         }
      }

   }
}
