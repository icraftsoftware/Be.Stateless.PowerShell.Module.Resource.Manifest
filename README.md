# Be.Stateless.PowerShell.Module.Resource.Manifest

[![Build Status](https://dev.azure.com/icraftsoftware/be.stateless/_apis/build/status/Be.Stateless.PowerShell.Module.Resource.Manifest%20Manual%20Release?branchName=master)](https://dev.azure.com/icraftsoftware/be.stateless/_build/latest?definitionId=26&branchName=master)
[![GitHub Release](https://img.shields.io/github/v/release/icraftsoftware/Be.Stateless.PowerShell.Module.Resource.Manifest?label=Release&logo=github)](https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.Resource.Manifest/releases/latest)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/Resource.Manifest.svg?style=flat&logo=powershell)](https://www.powershellgallery.com/packages/Resource.Manifest)

Commands to define and process resource manifests that can later be used to drive operations, in a declarative way, according to the nature of the resources to operate upon.

## Module Installation

Notice that to be able to install this PowerShell module right from the PowerShell Gallery you will need to trust the certificate that was used to sign it. Run the following PowerShell commands (they merely download and install the certificate's public key in the 'Trusted People' store underneath the 'Local Machine' certifcate store):

```PowerShell
Invoke-WebRequest -Uri https://github.com/icraftsoftware/Be.Stateless.Build.Scripts/raw/master/be.stateless.public.cer -OutFile "$($env:TEMP)\be.stateless.public.cer"
Import-Certificate -FilePath "$($env:TEMP)\be.stateless.public.cer" -CertStoreLocation Cert:\LocalMachine\TrustedPeople\
```

Notice that if the `ExecutionPolicy` is set to `AllSigned` you also need to run the following PowerShell command (it merely installs the certificate's public key in the 'Trusted Publishers' store underneath the 'Local Machine' certifcate store):

```PowerShell
Import-Certificate -FilePath "$($env:TEMP)\be.stateless.public.cer" -CertStoreLocation Cert:\LocalMachine\TrustedPublisher\
```
