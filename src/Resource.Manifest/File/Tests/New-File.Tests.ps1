﻿#region Copyright & License

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

Describe 'New-File' {
   InModuleScope Resource.Manifest {

      Context 'When file does not exist' {
         BeforeAll {
            $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
         }
         It 'Throws a ParameterBindingValidationException.' {
            { New-File -Path c:\assembly.dll -Destination c:\root\file.txt } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
      }

      Context 'When file exists' {
         BeforeAll {
            # create some empty files
            '' > TestDrive:\one.txt
            '' > TestDrive:\two.txt
         }
         It 'Returns a custom object with both a path and a name property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Destination = @('c:\files\one.1.txt', 'c:\files\one.2.txt') }

            $actualItem = New-File -Path TestDrive:\one.txt -Destination c:\files\one.1.txt, c:\files\one.2.txt -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a collection of custom objects with both a path and a name property.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Destination = 'c:\files\' }
               [PSCustomObject]@{ Name = 'two.txt' ; Path = 'TestDrive:\two.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Destination = 'c:\files\' }
            )

            $actualItems = New-File -Path (Get-ChildItem -Path TestDrive:\) -DestinationFolder c:\files\ -PassThru

            $actualItems | Should -HaveCount 2
            0..1 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
         }
         It 'Ensures that destination folders end with a ''\''.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Destination = @('c:\folder.1\', 'c:\folder.2\') }
               [PSCustomObject]@{ Name = 'two.txt' ; Path = 'TestDrive:\two.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Destination = @('c:\folder.1\', 'c:\folder.2\') }
            )

            $actualItems = New-File -Path (Get-ChildItem -Path TestDrive:\) -DestinationFolder c:\folder.1\, c:\folder.2 -PassThru

            $actualItems | Should -HaveCount 2
            0..1 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
         }
         It 'Throws when deploying multiple source files to one destination file.' {
            { New-File -Path (Get-ChildItem -Path TestDrive:\) -Destination c:\files\one.txt, c:\files\two.txt -PassThru } |
               Should -Throw -ExpectedMessage 'Deploying multiple source files to either a single or multiple destination files is ambiguous and not supported. Multiple source files can only be deployed to either a single or multiple destination folders.'
         }
         It 'Throws when deploying multiple source files to multiple destination files.' {
            { New-File -Path (Get-ChildItem -Path TestDrive:\) -Destination c:\files\one.txt, c:\files\two.txt -PassThru } |
               Should -Throw -ExpectedMessage 'Deploying multiple source files to either a single or multiple destination files is ambiguous and not supported. Multiple source files can only be deployed to either a single or multiple destination folders.'
         }
         It 'Throws when a destination file is a folder path.' {
            { New-File -Path TestDrive:\one.txt -Destination c:\files\one.1.txt, c:\files\ -PassThru } |
               Should -Throw -ExpectedMessage 'At least one destination file ends with a ''\'', denoting a destination folder instead.'
         }
      }

      Context 'Creating Files must be done via the ScriptBlock passed to New-ResourceManifest' {
         BeforeAll {
            # create some empty files
            '' > TestDrive:\one.txt
            '' > TestDrive:\two.txt
            '' > TestDrive:\six.txt
         }
         It 'Accumulates Assemblies into the Manifest being built.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'one.txt' ; Path = 'TestDrive:\one.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Destination = @('c:\folder.1\', 'c:\folder.2\') }
               [PSCustomObject]@{ Name = 'six.txt' ; Path = 'TestDrive:\six.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Destination = @('c:\folder.1\', 'c:\folder.2\') }
               [PSCustomObject]@{ Name = 'two.txt' ; Path = 'TestDrive:\two.txt' | Resolve-Path | Select-Object -ExpandProperty ProviderPath ; Destination = @('c:\folder.1\', 'c:\folder.2\') }
            )

            $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               New-File -Path (Get-ChildItem -Path TestDrive:\) -DestinationFolder c:\folder.1, c:\folder.2
            }

            $builtManifest | Should -Not -BeNullOrEmpty
            $builtManifest.ContainsKey('Files') | Should -BeTrue
            $builtManifest.Files | Should -HaveCount 3
            0..2 | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.Files[$_] | Should -BeNullOrEmpty }
         }
      }

   }
}