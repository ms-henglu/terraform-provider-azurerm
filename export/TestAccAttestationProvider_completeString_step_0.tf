

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220415030140269915"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapg1zmvck1x1"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA0MTUwMzAxNDBaFw0yMjEwMTIwMzAxNDBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAex9H/kgWgoPiOTfxJRhhb5mEOuTd
7goK2fPs7XsboG/DC+MG2wy3e6eunHXrzscMbWHNCpw7cMNVzSFBZPvp8PoBBhfe
bwt11a6cQ1c83BAvZzQAj/3Pn5w1P9/HoS6cIhUyoIOcWxsLghwJUlC1I5+wpGWD
Ba+hpv5RtPsBZewXDnSjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAV2h1waR
mJafogJK5f+DxFkSXQhQPD1Muf+eNquQSwuRy8+ZKQHhzqey+3UF+hTWQV/Vmb7T
zsDo2jLjFJhznPBxAkIB3nnZ4LqcxeL2w0sDFhTlrlkfCzV3pTQ0itgOj5RAahE/
bm8jm9oYanDf1F3ixPykRt+dY42rPLHZJgh8kytiiiE=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
