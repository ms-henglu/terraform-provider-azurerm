
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230512003423984463"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapsw7mp9ci71"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA1MTIwMDM0MjNaFw0yMzExMDgwMDM0MjNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQABP14LW2NA1DPNV3XaJOL96pqEl2P
Fn1j/0krtkPlqC0us5aVA7kUBpK42hVq9K30DNC+oSSyrKoz2EFYrxmawYoBWbyc
FESJaD6R/XnO0zq5WOYzMj5iM3I2Zckv2kvIEBnFeGBrpLbt09LzcgR12wlWSClb
QNrBsJlLJW8zP1t5xPKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAUZaIJR8
z+yM6yWns5MmUCh8uYwbcwEOx1tKbAPs7MFRzU8w7Km3WHSVQX5VfWBlAtISIXSu
kGDsj+Jq99vX07vaAkIBrB1fFCwJ/kKC1HDyj2lg8AMCE0OltZxknYecdlHvGzIg
TK9yKE15o66YVIjIILel6z9WXG+AaYzy0VdebCP5ZOI=
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
    ]
  }
}
