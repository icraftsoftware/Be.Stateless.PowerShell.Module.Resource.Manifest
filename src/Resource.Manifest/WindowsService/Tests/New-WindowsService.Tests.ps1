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

Describe 'New-WindowsService' {
   InModuleScope Resource.Manifest {
      BeforeAll {
         $script:credential = New-Object -TypeName PSCredential -ArgumentList '.\BTS_USER', (ConvertTo-SecureString p@ssw0rd -AsPlainText -Force)
      }

      Context 'When service executable file does not exist' {
         BeforeAll {
            $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
         }
         It 'Throws a ParameterBindingValidationException.' {
            { New-WindowsService -Path 'c:\nonexistent-file.exe' -ShortName service -Credential $credential } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
      }

      Context 'When service executable file exists' {
         BeforeAll {
            # create some empty files
            '' > TestDrive:\service.exe
         }
         It 'Returns a custom object with both a path and a name property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'service' ; Path = 'TestDrive:\service.exe' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Credential = $credential ; StartupType = 'Automatic' }

            $actualItem = New-WindowsService -Path 'TestDrive:\service.exe' -Name 'service' -Credential $credential -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a custom object with both a description and a display name property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'service' ; Path = 'TestDrive:\service.exe' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Credential = $credential ; StartupType = 'Automatic' ; Description = 'some descritpion' ; DisplayName = 'display name' }

            $actualItem = New-WindowsService -Path 'TestDrive:\service.exe' -Name 'service' -Credential $credential -Description 'some descritpion' -DisplayName 'display name' -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
      }

      Context 'Creating service executable file must be done via the ScriptBlock passed to New-Manifest' {
         BeforeAll {
            # create some empty files
            '' > TestDrive:\service-one.exe
            '' > TestDrive:\service-two.exe
         }
         It 'Accumulates WindowsServices into the Manifest being built.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'service-one' ; Path = 'TestDrive:\service-one.exe' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Credential = $credential ; StartupType = 'Automatic' }
               [PSCustomObject]@{ Name = 'service-two' ; Path = 'TestDrive:\service-two.exe' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Credential = $credential ; StartupType = 'Manual' }
            )

            $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               New-WindowsService -Path 'TestDrive:\service-one.exe' -Name 'service-one' -Credential $credential
               New-WindowsService -Path 'TestDrive:\service-two.exe' -Name 'service-two' -Credential $credential -StartupType Manual
            }

            $builtManifest | Should -Not -BeNullOrEmpty
            $builtManifest.ContainsKey('WindowsServices') | Should -BeTrue
            $builtManifest.WindowsServices | Should -HaveCount 2
            0..1 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.WindowsServices[$_] | Should -BeNullOrEmpty }
         }
      }

   }
}
