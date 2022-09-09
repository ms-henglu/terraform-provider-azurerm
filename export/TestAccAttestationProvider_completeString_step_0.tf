

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220909033841601803"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap9k0mql122a"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA5MDkwMzM4NDFaFw0yMzAzMDgwMzM4NDFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBJYIiSEO3vuBQ16Rz18sPpW3duNbh
BTkqgGyoEszSuAd9rloYp7clx03afE0fWBCIXZIacDHuETQQu6due9taDXIA94WN
iO/PjnARfWxZ5nlZFGzPIbYbMsJt8brWr6lqbXVqewBHLgOMAamCBVbRTfJFVKhN
XDv2It1fgEKit/20TDGjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBURHPO34C
k3H7OyByUO9Quvyv4f7DbJIZ05LY9l053zqYAsb+GSoAUCt+BB19dtqDeaIsorPq
VD2YPY5qgNewwqACQSvM9Z/kJbEy3yg4BbbgDSwp2dXZWt8HWFX8h3FM2pEtEjyF
GfJIsWdupZUYFG28X8Yqb0/0mFvbF3KpgVOuQMal
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
