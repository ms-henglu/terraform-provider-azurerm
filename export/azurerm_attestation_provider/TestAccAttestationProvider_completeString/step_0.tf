

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230316221033700677"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapbialfvd69b"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAzMTYyMjEwMzNaFw0yMzA5MTIyMjEwMzNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQADS9BUZJZ4mq6AF80X7289mcEvdBc
0sMmR4/JZoImgGg3NIh+TwhKkepg27oW4EH5KzGmciwMMDsnzF7cNgmoB5UAAdoP
ePgAqKfK9/AHIz2X45h8FaqyTK+eOwjRyj/UmKdbVBq7hb9ApvizEbaULviWstsX
lts9dMvwgP/8x/CPnTqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAO8mhHss
lAt8FgbgO2BC1EvMDrzQ5rQ1dAQFPf8PhBDh4IGvUwnwPP1AneqEqSxhbCcAUBtG
NzSrCNOjf1QOs2owAkIA8PYAyZPH9qhK9YFPa3DG9EHFsYqS3PJrv7m+sKattZ7D
BuYKdQ6BjeKpcPQ0abZNThwV76Kdy4aYhJl6YvV4cr4=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
