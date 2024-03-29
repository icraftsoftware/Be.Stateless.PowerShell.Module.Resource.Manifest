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

@{
   RootModule            = 'Resource.Manifest.psm1'
   ModuleVersion         = '2.1.1.1'
   GUID                  = '07e35b0e-3441-46b4-82e6-d8daafb837bd'
   Author                = 'François Chabot'
   CompanyName           = 'be.stateless'
   Copyright             = '© 2020 - 2022 be.stateless. All rights reserved.'
   Description           = 'Commands to define and process resource manifests that can later be used to drive operations, in a declarative way, according to the nature of the resources to operate upon.'
   ProcessorArchitecture = 'None'
   PowerShellVersion     = '5.0'
   NestedModules         = @()
   RequiredAssemblies    = @()
   RequiredModules       = @(
      @{ ModuleName = 'BizTalk.Administration' ; ModuleVersion = '2.1.0.0' ; GUID = 'de802b43-c7a6-4580-a34b-ac805bbf813e' }
      # comment out following dependency to workaround cyclic dependency issue, see https://github.com/PowerShell/PowerShell/issues/2607
      # @{ ModuleName = 'Psx' ; ModuleVersion = '2.1.0.0' ; GUID = '217de01f-f2e1-460a-99a4-b8895d0dd071' }
   )

   AliasesToExport       = @(
      'ApplicationManifest',
      'Assembly',
      'BamActivityModel',
      'BamIndex',
      'Binding',
      'EventLogSource',
      'File',
      'Installer',
      'LibraryManifest',
      'Map',
      'Orchestration',
      'Pipeline',
      'PipelineComponent',
      'ProcessDescriptor',
      'Schema',
      'ServiceComponent',
      'SqlDatabase',
      'SqlDeploymentScript',
      'SqlUndeploymentScript',
      'SsoConfigStore',
      'WindowsService',
      'XmlConfiguration',
      'XmlConfigurationAction',
      'XmlUnconfigurationAction'
   )
   CmdletsToExport       = @()
   FunctionsToExport     = @(
      # Assembly.ps1
      'New-Assembly',
      # BtsApplicationManifest.ps1
      'New-ApplicationManifest',
      # BtsBamActivityModel.ps1
      'New-BamActivityModel',
      # BtsBamIndex.ps1
      'New-BamIndex',
      # BtsBinding.ps1
      'New-Binding',
      # BtsLibraryManifest.ps1
      'New-LibraryManifest',
      # BtsMap.ps1
      'New-Map',
      # BtsOrchestration.ps1
      'New-Orchestration',
      # BtsPipeline.ps1
      'New-Pipeline',
      # BtsPipelineComponent.ps1
      'New-PipelineComponent',
      # BtsProcessDescriptor.ps1
      'New-ProcessDescriptor',
      # BtsSchema.ps1
      'New-Schema',
      # EventLogSource.ps1
      'New-EventLogSource',
      # File.ps1
      'New-File',
      # Installer.ps1
      'New-Installer',
      # ServiceComponent.ps1
      'New-ServiceComponent',
      # SqlDatabase.ps1
      'New-SqlDatabase',
      # SqlDeploymentScript.ps1
      'New-SqlDeploymentScript',
      # SqlLogin.ps1
      'ConvertTo-SqlLogin',
      # SqlUndeploymentScript.ps1
      'New-SqlUndeploymentScript',
      # Resource.ps1
      'Get-ResourceItem',
      'New-ResourceItem',
      'New-ResourceManifest',
      # SsoConfigStore.ps1
      'New-SsoConfigStore',
      # WindowsService.ps1
      'New-WindowsService',
      # XmlConfiguration.ps1
      'New-XmlConfiguration',
      # XmlConfigurationAction.ps1
      'New-XmlConfigurationAction',
      # XmlUnconfigurationAction.ps1
      'New-XmlUnconfigurationAction'
   )
   VariablesToExport     = @()
   PrivateData           = @{
      PSData = @{
         Tags                       = @('be.stateless', 'icraftsoftware', 'Item', 'Resource', 'Group', 'Declarative', 'PowerShell')
         LicenseUri                 = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.Resource.Manifest/blob/master/LICENSE'
         ProjectUri                 = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.Resource.Manifest'
         IconUri                    = 'https://github.com/icraftsoftware/Be.Stateless.Build.Scripts/raw/master/nuget.png'
         ExternalModuleDependencies = @('BizTalk.Administration', 'Psx')
         Prerelease                 = 'preview'
      }
   }
}
