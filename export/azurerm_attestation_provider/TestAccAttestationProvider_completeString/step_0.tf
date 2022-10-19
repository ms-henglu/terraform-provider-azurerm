

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221019060309084779"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapv97ncpywon"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjEwMTkwNjAzMDlaFw0yMzA0MTcwNjAzMDlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBg+2jr1p9hqjznOgpryXK4Y4nodvD
OydhIMO1HWLbF8QHAsHeaZ7JdIOZvW1ianNz+kwQO6SZOOnLaPoRx2vkgJcBECPb
u7QPVAFKQBHYPlgTJVAVj831AR/CBRar0+6x4NbkNXSjhEPss0pooSPBhZO0mjNp
s4DJt7gG4J3OWWbQH8qjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCANQpeaOX
Z5oG75H43sxHuuuL6L5/S4dhg6VFwXmsOAY/OoC4o+CKxdoClt3C0R5Xkea8KyH2
n5Qodzx8SqF9QsRtAkIAgtZJyKWzA7gd1EZcHemOLmjObUPCf4qoDYCSdQg+WsCP
7IeEk/UhysacW3rN6R5glf/BhLEWkIZBVVenLacMM3o=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
