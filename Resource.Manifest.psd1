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

@{
    RootModule            = 'Resource.Manifest.psm1'
    ModuleVersion         = '1.0.0.0'
    GUID                  = '07e35b0e-3441-46b4-82e6-d8daafb837bd'
    Author                = 'François Chabot'
    CompanyName           = 'be.stateless'
    Copyright             = '(c) 2020 be.stateless. All rights reserved.'
    Description           = 'Commands to define and process resource manifests that can later be used to drive operations, in a declarative way, according to the nature of the resources to operate upon.'
    ProcessorArchitecture = 'None'
    PowerShellVersion     = '5.0'
    NestedModules         = @()
    RequiredAssemblies    = @()
    RequiredModules       = @('Psx')

    AliasesToExport       = @(
        'ApplicationManifest',
        'Assembly',
        'BamActivityModel',
        'BamIndex',
        'Binding',
        'Component',
        'LibraryManifest',
        'Map',
        'Orchestration',
        'Pipeline',
        'PipelineComponent',
        'Schema',
        'SqlDatabase',
        'SqlDeploymentScript',
        'SqlUndeploymentScript',
        'Transform',
        'XmlConfiguration'
    )
    CmdletsToExport       = @()
    FunctionsToExport     = @(
        # Assembly.ps1
        'New-Assembly',
        # BtsApplication.ps1
        'New-ApplicationManifest',
        # BtsBamActivityModel.ps1
        'New-BamActivityModel',
        # BtsBamIndex.ps1
        'New-BamIndex',
        # BtsBinding.ps1
        'New-Binding',
        # BtsComponent.ps1
        'New-Component',
        # BtsLibrary.ps1
        'New-LibraryManifest',
        # BtsMap.ps1
        'New-Map',
        # BtsOrchestration.ps1
        'New-Orchestration',
        # BtsPipeline.ps1
        'New-Pipeline',
        # BtsPipelineComponent.ps1
        'New-PipelineComponent',
        # BtsSchema.ps1
        'New-Schema',
        # SqlDatabase.ps1
        'New-SqlDatabase',
        # SqlDeploymentScript.ps1
        'New-SqlDeploymentScript',
        # SqlUndeploymentScript.ps1
        'New-SqlUndeploymentScript',
        # Resource.ps1
<<<<<<<
        'Get-ResourceItem',
        'New-ResourceItem',
        'New-ResourceManifest'
        # XmlConfiguration.ps1
        'New-XmlConfiguration'
    )
    VariablesToExport     = @()
    PrivateData           = @{
        PSData = @{
            Tags                       = @('Item', 'Resource', 'Group', 'Declarative', 'PowerShell')
            LicenseUri                 = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.Resource.Manifest/blob/master/LICENSE'
            ProjectUri                 = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.Resource.Manifest'
            ExternalModuleDependencies = @('Psx')
        }
    }
}
