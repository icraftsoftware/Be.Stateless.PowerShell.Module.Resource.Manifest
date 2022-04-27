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

Describe 'New-SsoConfigStore' {
   InModuleScope Resource.Manifest {

      Context 'When ConfigStore file does not exist' {
         BeforeAll {
            $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
         }
         It 'Throws a ParameterBindingValidationException.' {
            { New-SsoConfigStore -Path 'c:\nonexistent-file.dll' } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
      }

      Context 'When optional arguments are null, empty, or invalid' {
         BeforeAll {
            $script:ParameterBindingValidationExceptionType = [Type]::GetType('System.Management.Automation.ParameterBindingValidationException, System.Management.Automation', $true)
            # create some empty files
            '' > TestDrive:\six.txt
         }
         It 'Does not throw because UserGroup is null.' {
            { New-SsoConfigStore -Path TestDrive:\six.txt -UserGroup $null -PassThru } | Should -Not -Throw
         }
         It 'Does not throw because UserGroup is empty.' {
            { New-SsoConfigStore -Path TestDrive:\six.txt -UserGroup @() -PassThru } | Should -Not -Throw
         }
         It 'Does not throw because AdministratorGroup is null.' {
            { New-SsoConfigStore -Path TestDrive:\six.txt -AdministratorGroup $null -PassThru } | Should -Not -Throw
         }
         It 'Does not throw because AdministratorGroup is empty.' {
            { New-SsoConfigStore -Path TestDrive:\six.txt -AdministratorGroup @() -PassThru } | Should -Not -Throw
         }
         It 'Does not throw because AssemblyProbingFolderPath is empty.' {
            { New-SsoConfigStore -Path TestDrive:\six.txt -AssemblyProbingFolderPath @() -PassThru } | Should -Not -Throw
         }
         It 'Throws because AssemblyProbingFolderPath do not exist.' {
            { New-SsoConfigStore -Path TestDrive:\six.txt -AssemblyProbingFolderPath 'TestDrive:\foo' -PassThru } | Should -Throw -ExceptionType $ParameterBindingValidationExceptionType
         }
         It 'Does not throw because EnvironmentSettingOverridesTypeName is null.' {
            { New-SsoConfigStore -Path TestDrive:\six.txt -EnvironmentSettingOverridesTypeName $null -PassThru } | Should -Not -Throw
         }
         It 'Does not throw because EnvironmentSettingOverridesTypeName is empty.' {
            { New-SsoConfigStore -Path TestDrive:\six.txt -EnvironmentSettingOverridesTypeName '' -PassThru } | Should -Not -Throw
         }
      }

      Context 'When ConfigStore file exists' {
         BeforeAll {
            # create some empty files
            '' > TestDrive:\one.txt
            '' > TestDrive:\two.txt
         }
         It 'Returns a custom object with both a path and a name property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" ; AdministratorGroup = @(Get-BizTalkGroupSettings | ForEach-Object BizTalkAdministratorGroup) ; UserGroup = @(Get-BizTalkHost | ForEach-Object NTGroupName | Select-Object -Unique) ; AssemblyProbingFolderPath = @() }

            $actualItem = New-SsoConfigStore -Path TestDrive:\one.txt -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a custom object with a UserGroup, AdministratorGroup, and a EnvironmentSettingOverridesTypeName property.' {
            $expectedItem = [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" ; AdministratorGroup = @('BizTalk Server Administrators') ; UserGroup = @('BizTalk Application Users') ; EnvironmentSettingOverridesTypeName = 'override-type' ; AssemblyProbingFolderPath = @() }

            $actualItem = New-SsoConfigStore -Path TestDrive:\one.txt -PassThru -AdministratorGroup 'BizTalk Server Administrators' -UserGroup 'BizTalk Application Users' -EnvironmentSettingOverridesTypeName 'override-type'

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns an object with AssemblyProbingFolderPath and EnvironmentSettingOverridesTypeName.' {
            $expectedItem = [PSCustomObject]@{
               Name                                = 'one.txt'
               Path                                = "$TestDrive\one.txt"
               AdministratorGroup                  = @(Get-BizTalkGroupSettings | ForEach-Object BizTalkAdministratorGroup)
               UserGroup                           = @(Get-BizTalkHost | ForEach-Object NTGroupName | Select-Object -Unique)
               AssemblyProbingFolderPath           = ($PSScriptRoot | Resolve-Path | Split-Path -Parent), ($PSScriptRoot | Resolve-Path | Split-Path -Parent | Split-Path -Parent)
               EnvironmentSettingOverridesTypeName = 'some-environment-setting-overrides-type-name'
            }

            $actualItem = New-SsoConfigStore -Path TestDrive:\one.txt -AssemblyProbingFolderPath $expectedItem.AssemblyProbingFolderPath[0], $expectedItem.AssemblyProbingFolderPath[1] -EnvironmentSettingOverridesTypeName $expectedItem.EnvironmentSettingOverridesTypeName -PassThru

            Compare-ResourceItem -ReferenceItem $expectedItem -DifferenceItem $actualItem | Should -BeNullOrEmpty
         }
         It 'Returns a collection of custom objects with both a path and a name property.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" ; AdministratorGroup = @(Get-BizTalkGroupSettings | ForEach-Object BizTalkAdministratorGroup) ; UserGroup = @(Get-BizTalkHost | ForEach-Object NTGroupName | Select-Object -Unique) ; AssemblyProbingFolderPath = @() }
               [PSCustomObject]@{ Name = 'two.txt' ; Path = "$TestDrive\two.txt" ; AdministratorGroup = @(Get-BizTalkGroupSettings | ForEach-Object BizTalkAdministratorGroup) ; UserGroup = @(Get-BizTalkHost | ForEach-Object NTGroupName | Select-Object -Unique) ; AssemblyProbingFolderPath = @() }
            )

            $actualItems = New-SsoConfigStore -Path (Get-ChildItem -Path TestDrive:\) -PassThru

            $actualItems | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $actualItems[$_] | Should -BeNullOrEmpty }
         }
      }

      Context 'Creating SsoConfigStores must be done via the ScriptBlock passed to New-Manifest' {
         BeforeAll {
            # create some empty files
            '' > TestDrive:\one.txt
            '' > TestDrive:\two.txt
            '' > TestDrive:\six.txt
         }
         It 'Accumulates SsoConfigStores into the Manifest being built.' {
            $expectedItems = @(
               [PSCustomObject]@{ Name = 'one.txt' ; Path = "$TestDrive\one.txt" ; AdministratorGroup = @(Get-BizTalkGroupSettings | ForEach-Object BizTalkAdministratorGroup) ; UserGroup = @(Get-BizTalkHost | ForEach-Object NTGroupName | Select-Object -Unique) ; AssemblyProbingFolderPath = @() }
               [PSCustomObject]@{ Name = 'six.txt' ; Path = "$TestDrive\six.txt" ; AdministratorGroup = @(Get-BizTalkGroupSettings | ForEach-Object BizTalkAdministratorGroup) ; UserGroup = @(Get-BizTalkHost | ForEach-Object NTGroupName | Select-Object -Unique) ; AssemblyProbingFolderPath = @() }
               [PSCustomObject]@{ Name = 'two.txt' ; Path = "$TestDrive\two.txt" ; AdministratorGroup = @(Get-BizTalkGroupSettings | ForEach-Object BizTalkAdministratorGroup) ; UserGroup = @(Get-BizTalkHost | ForEach-Object NTGroupName | Select-Object -Unique) ; AssemblyProbingFolderPath = @() }
            )

            $builtManifest = New-ResourceManifest -Type Application -Name 'BizTalk.Factory' -Build {
               New-SsoConfigStore -Path (Get-ChildItem -Path TestDrive:\)
            }

            $builtManifest | Should -Not -BeNullOrEmpty
            $builtManifest.ContainsKey('SsoConfigStores') | Should -BeTrue
            $builtManifest.SsoConfigStores | Should -HaveCount $expectedItems.Length
            0..($expectedItems.Length - 1) | ForEach-Object -Process { Compare-ResourceItem -ReferenceItem $expectedItems[$_] -DifferenceItem $builtManifest.SsoConfigStores[$_] | Should -BeNullOrEmpty }
         }
      }

   }
}
