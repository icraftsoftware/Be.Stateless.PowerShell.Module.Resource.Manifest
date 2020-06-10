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

Describe 'Compare-Item' {
   InModuleScope Resource {

      Context 'When both Items are null' {
         It 'Returns nothing.' {
            { Compare-Item -ReferenceItem $null -DifferenceItem $null } | Should -Throw
         }
      }

      Context 'When one Item is not a PSCustomObject' {
         BeforeAll {
            $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
         }
         It 'Throws when ReferenceItem is a HashTable.' {
            { Compare-Item -ReferenceItem (@{Name = 'Stark' }) -DifferenceItem [PSCustomObject](@{ Name = 'Stark' }) } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
         It 'Throws when DifferenceItem is a HashTable.' {
            { Compare-Item -ReferenceItem [PSCustomObject](@{Name = 'Stark' }) -DifferenceItem (@{ Name = 'Stark' }) } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
      }

      Context 'When both Items have one identical property' {
         It 'Returns nothing.' {
            $left = [PSCustomObject]@{ a = 'x' }
            $right = [PSCustomObject]@{ a = 'x' }
            Compare-Item -ReferenceItem $left -DifferenceItem $right | Should -BeNullOrEmpty
         }
      }

      Context 'When both Items have several identical properties' {
         It 'Returns nothing.' {
            $left = [PSCustomObject]@{ firstname = 'pepper' ; lastname = 'potts' ; displayname = 'pepper potts' }
            $right = [PSCustomObject]@{ firstname = 'pepper' ; lastname = 'potts' ; displayname = 'pepper potts' }
            Compare-Item -ReferenceItem $left -DifferenceItem $right | Should -BeNullOrEmpty
         }
      }

      Context 'When reference Item contains a key with a null value' {
         It 'Returns ''a <''.' {
            $left = [PSCustomObject]@{ a = $null }
            $right = [PSCustomObject]@{ }

            [object[]]$result = Compare-Item -ReferenceItem $left -DifferenceItem $right

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

            [object[]]$result = Compare-Item -ReferenceItem $left -DifferenceItem $right

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

            [object[]]$result = Compare-Item -ReferenceItem $left -DifferenceItem $right

            $result.Length | Should -Be 1
            $result.Property | Should -Be 'a'
            $result.ReferenceValue | Should -Be 'value'
            $result.SideIndicator | Should -Be '<>'
            $result.DifferenceValue | Should -BeNullOrEmpty
         }
         It 'Returns ''role partner <> assistance''.' {
            $left = [PSCustomObject]@{ firstname = 'pepper' ; lastname = 'potts' ; role = 'partner' }
            $right = [PSCustomObject]@{ firstname = 'pepper' ; lastname = 'potts' ; role = 'assistant' }

            [object[]]$result = Compare-Item -ReferenceItem $left -DifferenceItem $right

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

            Compare-Item -ReferenceItem $left -DifferenceItem $right | Should -BeNullOrEmpty
         }
         It 'Returns ''array (1, 2)) <> (3, 4, 5)''.' {
            $left = [PSCustomObject]@{ firstname = 'pepper' ; array = 1, 2 }
            $right = [PSCustomObject]@{ firstname = 'pepper' ; array = 3, 4, 5 }

            [object[]]$result = Compare-Item -ReferenceItem $left -DifferenceItem $right

            $result.Length | Should -Be 1
            $result.Property | Should -Be 'array'
            $result.ReferenceValue | Should -Be '(1, 2)'
            $result.SideIndicator | Should -Be '<>'
            $result.DifferenceValue | Should -Be '(3, 4, 5)'
         }
      }

   }
}
