

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210917031336876697"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapqx9t8dvt8r"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA5MTcwMzEzMzZaFw0yMjAzMTYwMzEzMzZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQApfMKDugnQMtCTYB0ZhUjZw5++AzO
mbBu1K6XOw+p4HRbsm4jlYiXuu7FMkDAsiCxjPHAmer8h2KdOPvtnoC+w/4BENvz
QRE2KgDbMvermFKadBNbJXV1NIsWPVj5L0/OBpCBXBHyCgu6q5aUldxUhQ/mVQMB
mEMFXAjCuzjyRJZBtsSjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAXm1Jae7
iu8Xq426EukJKOFsrXRW6HCURhotJ7a75EY6WDlqeCTO2RHTkk5lsYLO/3UaNTgH
C8OFmTEBJZ+WTgdpAkEA6EiM7HTDR5HVCvD57F3d0YtXQGz++84GhdHfJnWU+BD8
66Vo35hFTsTfS2u/MQQVNy7apeYo75KlJZ1JnUjbWA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
