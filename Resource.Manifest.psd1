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
    NestedModules         = @(
        'Assembly\Assembly.psm1',
        'BtsApplication\BtsApplication.psm1',
        'BtsBamActivityModel\BtsBamActivityModel.psm1',
        'BtsBamIndex\BtsBamIndex.psm1',
        'BtsBinding\BtsBinding.psm1',
        'BtsComponent\BtsComponent.psm1',
        'BtsOrchestration\BtsOrchestration.psm1',
        'BtsPipeline\BtsPipeline.psm1',
        'BtsPipelineComponent\BtsPipelineComponent.psm1',
        'BtsSchema\BtsSchema.psm1',
        'BtsTransform\BtsTransform.psm1',
        'SqlDatabase\SqlDatabase.psm1',
        'SqlDeploymentScript\SqlDeploymentScript.psm1',
        'SqlUndeploymentScript\SqlUndeploymentScript.psm1',
        'Resource\Resource.psm1'
    )
    RequiredAssemblies    = @()
    RequiredModules       = @('Psx')

    AliasesToExport       = @(
        'ApplicationManifest',
        'Assembly',
        'BamActivityModel',
        'BamIndex',
        'Binding',
        'Component',
        'Orchestration',
        'Pipeline',
        'PipelineComponent',
        'Schema',
        'SqlDatabase',
        'SqlDeploymentScript',
        'SqlUndeploymentScript',
        'Transform'
    )
    CmdletsToExport       = @()
    FunctionsToExport     = @(
        # Assembly.psm1
        'New-Assembly',
        # BtsApplication.psm1
        'New-ApplicationManifest',
        # BtsBamActivityModel.psm1
        'New-BamActivityModel',
        # BtsBamIndex.psm1
        'New-BamIndex',
        # BtsBinding.psm1
        'New-Binding',
        # BtsComponent.psm1
        'New-Component',
        # BtsOrchestration.psm1
        'New-Orchestration',
        # BtsPipeline.psm1
        'New-Pipeline',
        # BtsPipelineComponent.psm1
        'New-PipelineComponent',
        # BtsSchema.psm1
        'New-Schema',
        # BtsTransform.psm1
        'New-Transform',
        # SqlDatabase.psm1
        'New-SqlDatabase',
        # SqlDeploymentScript.psm1
        'New-SqlDeploymentScript',
        # SqlUndeploymentScript.psm1
        'New-SqlUndeploymentScript',
        # Resource.psm1
        'New-Item',
        'New-Manifest'
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
