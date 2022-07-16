# Resource.Manifest PowerShell Module

##### Build Pipelines

[![][pipeline.mr.badge]][pipeline.mr]

[![][pipeline.ci.badge]][pipeline.ci]

##### Latest Release

[![][module.badge]][module]

[![][release.badge]][release]

##### Release Preview

[![][module.preview.badge]][module.preview]

##### Documentation

[![][doc.main.badge]][doc.main]

[![][doc.this.badge]][doc.this]

## Overview

`Resource.Manifest` is a `PowerShell` module providing commands to define resource manifests made of resource groups &mdash;i.e. resources grouped by kind. Resource manifests are declarative Microsoft BizTalk Server® deployment recipes that can be entrusted to the [`BizTalk.Deployment`][biztalk.deployment] `PowerShell` module, which will determine how a manifest's resources have to be deployed and in what order.

## Installation

In order to be able to install the `PowerShell` module, you might have to trust the `be.stateless`'s certificate public key beforehand; see these [instructions][doc.install] for details on how to proceed.

<!-- badges -->

[doc.install]: https://www.stateless.be/PowerShell/Module/Installation.html "PowerShell Module Installation"
[doc.main.badge]: https://img.shields.io/static/v1?label=BizTalk.Factory%20SDK&message=User's%20Guide&color=8CA1AF&logo=readthedocs
[doc.main]: https://www.stateless.be/ "BizTalk.Factory SDK User's Guide"
[doc.this.badge]: https://img.shields.io/static/v1?label=Resource.Manifest&message=User's%20Guide&color=8CA1AF&logo=readthedocs
[doc.this]: https://www.stateless.be/PowerShell/Module/Resource/Manifest "Resource.Manifest PowerShell Module User's Guide"
[github.badge]: https://img.shields.io/static/v1?label=Repository&message=Be.Stateless.PowerShell.Module.Resource.Manifest&logo=github
[github]: https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.Resource.Manifest "Be.Stateless.PowerShell.Module.Resource.Manifest GitHub Repository"
[module.badge]: https://img.shields.io/powershellgallery/v/Resource.Manifest.svg?label=Resource.Manifest&style=flat&logo=powershell
[module]: https://www.powershellgallery.com/packages/Resource.Manifest "Resource.Manifest PowerShell Module"
[module.preview.badge]: https://badge-factory.azurewebsites.net/package/icraftsoftware/be.stateless/BizTalk.Factory.Preview/Resource.Manifest?logo=powershell
[module.preview]: https://dev.azure.com/icraftsoftware/be.stateless/_packaging?_a=package&feed=BizTalk.Factory.Preview&package=Resource.Manifest&protocolType=NuGet "Resource.Manifest PowerShell Module Preview"
[pipeline.ci.badge]: https://dev.azure.com/icraftsoftware/be.stateless/_apis/build/status/Be.Stateless.PowerShell.Module.Resource.Manifest%20Continuous%20Integration?branchName=master&label=Continuous%20Integration%20Build
[pipeline.ci]: https://dev.azure.com/icraftsoftware/be.stateless/_build/latest?definitionId=25&branchName=master "Be.Stateless.PowerShell.Module.Resource.Manifest Continuous Integration Build Pipeline"
[pipeline.mr.badge]: https://dev.azure.com/icraftsoftware/be.stateless/_apis/build/status/Be.Stateless.PowerShell.Module.Resource.Manifest%20Manual%20Release?branchName=master&label=Manual%20Release%20Build
[pipeline.mr]: https://dev.azure.com/icraftsoftware/be.stateless/_build/latest?definitionId=26&branchName=master "Be.Stateless.PowerShell.Module.Resource.Manifest Manual Release Build Pipeline"
[release.badge]: https://img.shields.io/github/v/release/icraftsoftware/Be.Stateless.PowerShell.Module.Resource.Manifest?label=Release&logo=github
[release]: https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.Resource.Manifest/releases/latest "Be.Stateless.PowerShell.Module.Resource.Manifest GitHub Release"

<!-- links -->

[biztalk.deployment]: https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment
