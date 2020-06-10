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
    GUID                  = 'd89d38a7-af47-4966-8f5d-32145085003f'
    Author                = 'François Chabot'
    CompanyName           = 'be.stateless'
    Copyright             = '(c) 2020 be.stateless. All rights reserved.'
    Description           = 'Commands to define and process resource manifests that can later be used to drive operations, in a declarative way, according to the nature of the resources to operate upon.'
    ProcessorArchitecture = 'None'
    PowerShellVersion     = '5.0'
    NestedModules         = @(
        'Assembly\Assembly.psm1',
        'Resource\Resource.psm1'
    )
    RequiredAssemblies    = @()
    RequiredModules       = @()

    AliasesToExport       = @('Assembly')
    CmdletsToExport       = @()
    FunctionsToExport     = @(
        # Assembly.psm1
        'New-Assembly',
        # Resource.psm1
        'Compare-Item',
        'New-Item',
        'New-Manifest'
    )
    VariablesToExport     = @()

    DefaultCommandPrefix  = 'Resource'
}
