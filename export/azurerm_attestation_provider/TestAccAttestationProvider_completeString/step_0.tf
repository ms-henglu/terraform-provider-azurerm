
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230810142926602333"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapqgduh7lbxh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA4MTAxNDI5MjZaFw0yNDAyMDYxNDI5MjZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAYKpwgdl6ZJKzlq9iDP7tUVwcB6FF
EQ/dQjISPksM/ailPu8tkuGXWWZ08ySr3LhAph2537QDpzacBIoa50LTT9wAxW08
Yusx+igXsff8AkBywTzDrV2r4TOl5yFc0px/zXFaIqsrC++Rnj2CfYjW2TqcwlM7
jzsq2vnNz2V4ZD6stzejNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAaISOvQI
yJozSYlGGjS3deo7yU8wLHtpDpmbHY8RWV/IzCY4l8xo+aEW9qoSzJEv+WeVFd5g
zBDxEa48+MZPLvDgAkIBGl5cdNOjiYoweI1vCMb5CA73rEjZD2Obb2ODZ4sX/vO+
m6V4P8YQkno5CxWbzZxgtVZlNuONwIxJgfIqisU3WH8=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }

  lifecycle {
    ignore_changes = [
      "open_enclave_policy_base64",
      "sgx_enclave_policy_base64",
      "tpm_policy_base64",
      "sev_snp_policy_base64",
    ]
  }
}
