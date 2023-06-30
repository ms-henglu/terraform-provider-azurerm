
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230630032641060458"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap11hxu7n2jc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA2MzAwMzI2NDFaFw0yMzEyMjcwMzI2NDFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBc/F8zOXK3ESLGEWPpaBDnoyNPrba
F89YU91pes5Mz6GPqVRgBVV7yvNs7jiOqMai8vj288KzPhjAtJOhqybeDOIAdt1S
TzNwk+NwgixGl/drUtiKkUZb1zIPIzju16GoEiZ/M9sPf8AqqWVYbzIEgpCqz6Yu
Afc7RVqcXI7eZoJqZ7ajNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAQd388Td
MC0rOB2yWsbXcxN9jpqDw75hb8+34vNvENZ3tYk2p530URvke5tSU3qr++Hw+D2d
JCOh5qu8x7CGjWE4AkIAliYpQo7BJQqVh8XeES21FTgutOzBNBXbGiri9AKgXacq
tRkV4aMLRr6QH7rjpiH9nfd7nBp4tMX1TpsyFJuj3+M=
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
