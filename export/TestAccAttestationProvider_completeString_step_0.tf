

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211008044046692236"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestappqqht79j7d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEwMDgwNDQwNDZaFw0yMjA0MDYwNDQwNDZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAQFaGJK8Aq5NmDQRMr7hokZobnHwW
OE49j2p2DKl3E4b+s6HQNRvxE9c8NDU4wN4IGjZdj0HB/CVkJjdxEWDQ8eYAeam0
IwoTk01WbXXvEli4cwQXLXhSeIOnQGONmYZVpqzErl28BI7KpoDo4sxN10adMxIK
cUGs4BGLin1K7UjExV6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAMWki4l0
sJ7j+nWCPvfkfNBEZC/4izDv6JgjkMmwtSqaV3SCDuigZn8FnkK4qbMIz3Hg+j14
cycuswJ0W9ajvoasAkIBiSn7upxoXbmFoJ8nuPuOPRQiHGfFcg+B9Unz2TOpKYnT
M/eFmzLkAs3fV+3JWy1tm1hYbexBP3y3nWcbzQ/8vv4=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
