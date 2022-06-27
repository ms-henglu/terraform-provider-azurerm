

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220627125630973186"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapb4ckquu1d1"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MjcxMjU2MzBaFw0yMjEyMjQxMjU2MzBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBrKDYYM7QhgobrpSMWIj0FQIqPHKk
yrwZUI4HZOK2SponxOlUVwHrt799tsEyUDMf8lkM1qci35BrnyV3b1LO2UUBn66R
qDsBKaIVfaZNu+sTjFh50lCO7VzezRPtqZyEAE6XXk73FSpanmfHlAHSJ87e3wm2
FXD0CnUm8m5hEEkqzkujNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAaB2KNss
Yig3m2uxGuE/R/etHhPFbt7OCdpetehmgocVaCQcAlpa1wV6y5gCPBKFqk5ZugG2
CtkBEWzAGX8PvuObAkIBfyYZDaPX9OadHjNyMhjlQQWD6IACyTfPLQ3HMf7aVk9r
AGnHXRIyB/hIchbTzVR+7Y9CYiDi01CQs+NsRltJJm8=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
