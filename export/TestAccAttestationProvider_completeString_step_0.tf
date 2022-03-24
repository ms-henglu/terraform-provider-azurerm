

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220324162942028953"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapi7svab0kul"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAzMjQxNjI5NDJaFw0yMjA5MjAxNjI5NDJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAP2Z1gZ0nprYCdc85qScv6/82Vg7g
pKSoGJ3ujszea2JUpPCZfpqKM89slxotPnADTop6uRmKIu2H9ESIDMDBSU0A8uhD
AvMMNwiW+hoAwJV8E3tTrLum/CdjuHT4kelRS+XkhFGbmV9srOrejxKMvjXREqxA
NQint5uJ1dKqhMVyDLmjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAVY5vuo4
6S5b0YrZNQP/HUE24SoeXlbeiMxOMmTu4eNIiAvuEg5szEuJH111TJBYInNS+tA0
0FjqWlxhe6ENRtCTAkIBCaOgEhBS/ah6e72O9OAjP4QcQj5UV13vmIII/cgZMFUa
lCbFQToghP7RuJudMC2STqNTVD/nb56nfP+4RoDXXg4=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
