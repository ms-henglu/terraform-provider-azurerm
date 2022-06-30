

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220630223412140390"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap39fjfmbhwe"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MzAyMjM0MTJaFw0yMjEyMjcyMjM0MTJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBuS+W9ZgkHz4HaOEfRPG2XPMrn7n6
V54374DhuR5hdhWcGihMHR3jOm5QR0a8zxF1hLx2UonLxSE6I43A0RU9vsgATXyp
4xMYDQ3M5/ia/1lVt94bqchAYKp9PmJ+r9gju/v2eLBJTYzal9nXFYP1TY95+j+y
SRvNFAVAjLQbwuI6pY+jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAProU8Uh
DOFYWGoJYTJEast74W0UE9E0BxfANBVBQTyR40DuxFPEl6mp/uyrV4JE3HFhc4Ca
Rmne6Elr4vOrp8vpAkIB4f1TOP5eIQo8/aku9AGjKQFmWQTIPXfoJrrbk7CcDZnm
sx3nmCqbrdbbxPV/xFxizaUIwlnFkClME2z2ISrJkK0=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
