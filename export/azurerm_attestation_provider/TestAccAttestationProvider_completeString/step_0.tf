

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230120054236437832"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapuzowqf8k1w"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAxMjAwNTQyMzZaFw0yMzA3MTkwNTQyMzZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAGS56oRdyHtNUZ365s+XuvC/brNsl
TsJOAzwTImceX/iPTzALQfGC4nIVQi4iLe0MDVzmXTFKUWdqEPjlMX65gs8AIg0i
W0CQ4swyTtqZhmekxBURJQFp+wydM3exBQJ9h2aQF2fYVcbCyN+bROgRv+wmJfdQ
i38vq3dGetszFa6kRMSjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAdN+M717
Aaz87NoQqWqopApdUTAxY8+F/LMMIKpdmB3fam95B2sJzSe7KWDZGca4NqWRaTRq
3Q1ESPS87rVPN4IRAkIBV83x73DOfjUYJlBDocOahAY+b88A5M2cXpMttA1cRmu7
2SnLurxkCS05E9ot8pVTlNayNaD76cy05hQIfODra0I=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
