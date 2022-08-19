

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220819164912714773"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap1rgbmpgnqi"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA4MTkxNjQ5MTJaFw0yMzAyMTUxNjQ5MTJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAEpMnSsFFUeeZpO6xjyhFFi7B6vMF
LBTHoQkqiX5bu+9q7dWKKYK4UHBEjKB4t17Ea0TD7ZTahLe0bIgoAHm5PHYB9Viv
iSxLU45oswwLdguKAYu0q2w4KpLKGR3ncQ71Nyxg5g5y4wYXtyrbnPIUpUv8Ab+v
OyA38lNmGwug8vnoYc6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAKxNrAb4
moA31xVUWEX5p8kJvDFxLgJGX4abXT4MUmWPPAnblW5R+Lp4hwtDXcZo42HvsUoU
8tgbjJszb9huBk7dAkIA/fY8E4aoQNQMupWL5yrW6yomrpab1n9iIub82lEEdZzc
aEUu9NuO2zOH02RhdIxy25VPv1Y1k1otLG9ijmK4/Kc=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
