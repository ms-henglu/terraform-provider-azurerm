

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220527023841953142"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapn4gzbinlng"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA1MjcwMjM4NDFaFw0yMjExMjMwMjM4NDFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBLbI5etX2owoOGkOSRa/4jnfEwlvY
KH2kqeMgU4BobHohicmTI/77cEE54Q4KDZHuoedI2XXWzWY/Yjy8j648qrwBM/MI
VGWkTj7LU7ziuFl8+0GF3nXcCIvfZ0eFHqkIK8l5n1x297lyaVICqYVtqFIR63P3
UjC9tWn0VEED719lrh2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAP1emmVF
c6Vs4ngOW4DuMJesh6zlLyLfWuL8Rtcjk9fLQDb2r+pRiXyEKCWjNIsE2wfmy4n9
m30uy/JIwYb5kkyaAkIAzmOX2R9pUoaRpX4gnZY7h7uN7bT48083RMauk42tyBku
PbcbkyXOYTMhfL/XEStCH4HhtQ1nEhoKFgb2XUVu1jQ=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
