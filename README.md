# BOSH Windows Stemcell Builder [![slack.cloudfoundry.org](https://slack.cloudfoundry.org/badge.svg)](https://slack.cloudfoundry.org)

This repo contains a set of scripts for automating the process of building BOSH Windows Stemcells. A [Concourse](http://concourse.ci/) [pipeline](https://github.com/cloudfoundry-incubator/greenhouse-ci/blob/master/bosh-windows-stemcells.yml) for the supported platforms (AWS, vSphere) can be found [here](https://main.bosh-ci.cf-app.com/pipelines/windows-stemcells).

### Dependencies

* [ovftool](https://www.vmware.com/support/developer/ovf/)
* [Windows ISO](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2012-r2)
* [Windows Update PowerShell Module](https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc)
* [Packer](https://www.packer.io) version [v0.10.2](https://releases.hashicorp.com/packer/0.10.2/)

### ESXi Configuration

Refer to the [README](./vsphere/README.md).

#### Remotely fetched resources

The below binaries are downloaded as part of the provisioning process.

* [7-Zip](http://www.7-zip.org/a/7z920-x64.msi)
* [VMware Tools](http://softwareupdate.vmware.com/cds/vmw-desktop/ws/12.1.1/3770994/windows/packages/tools-windows.tar)

#### Notes

If the build fails, manual deletion of the `packer-vmware-iso` VM and `packer-vmware-iso` datastore directory may be required.

Known working version of Concourse is [v1.6.0](http://concourse.ci/downloads.html#v160).

### Licenses

Portions of the provisioning scripts were adapted from the [packer-windows](https://github.com/joefitzgerald/packer-windows) project. A copy of the packer-windows license is located [here](vsphere/scripts/LICENSE).
