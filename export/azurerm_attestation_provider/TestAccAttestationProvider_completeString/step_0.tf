
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230929064348501005"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaph9c9dfuzrf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA5MjkwNjQzNDhaFw0yNDAzMjcwNjQzNDhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA8zKYBEZAjx+SZDOv5uJuiOV3oAMq
aNBCqsPJqidfqbiTaP5Xtso7zqssoYH1skg+GjI5DUI70TyYw6C3IF3uD8AAWpT3
VraD8fUcpcciftAaH5dOWMrJPlpyO5lodZI1gTcbK87ENEl3BN4tqESoiH/SlGxC
c/R406sEIugkASlSSj6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAeDDSucn
rgnDRUi2NWKa2UHpvEpTfxVd8e7gOn7RPF1rkbGYyqv1R+jkZkv2uibPyglG1Sz/
Pq6bs9/OhVO26syCAkIBu3KLVGlwUEr5mNdCYX2xJMe+NynKBvWGCB3G7sCTG+b3
zlqV25+Klf5yKk7/C3ft47FxhgUI/12oGcdJn/Qx7m4=
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
