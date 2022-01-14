

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220114063826574180"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap4u4gk1uk9a"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAxMTQwNjM4MjZaFw0yMjA3MTMwNjM4MjZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBCLdu0bzO2c0c4OdICFQnT1Jfj6uE
M9lyzcRFqp68uBArgKBBCGQwrqoC8a+H01bPY29zAcq4zYYV1SRgRfB6Z6cAKDnI
8d4p/onga+qXD0ZqvPvj6z5Tgh7gtQ/rsEWICaCmmvcx0vxDHPpxSjnCtX6znVWv
4qVv86RNQjA9ZFM+IhyjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBDhNlCCdX
TG1hPAzWXAAZ0tYAN3yoP3Mk0W51lvBpccCbr2G75fwm8JAIwzxkU3X+4nIHo1R6
fxwZooJuOE1hdpwCQT5YdKrJta8ysbLrOEVRuRBckFSGbo+oS4AKVSDLebtkjOUb
j6Mbh/OnN3QluhW+iUapUIbp/SBhszMFMiQ5bD4J
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
