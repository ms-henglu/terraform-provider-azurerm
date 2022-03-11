

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220311042030735641"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaprlqr8ubtkx"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAzMTEwNDIwMzBaFw0yMjA5MDcwNDIwMzBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAINhe7ghmlRI80I1UIu5q7YgXNT6n
vTkuk2o6PSioIM4VpTsJiRC14k6bxxokpnIawru6+Sh1Vb7+Fo1SLmHzIK0AvxEw
XQ2hbEdbBCM3wzd0bSPpBmu+9UrwGcEIZawTDnWNOBDMoW9ecgd3APe4DZcOI5wz
IWzzGP2cyK5nqAgCyrqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBDnLBHubX
KKWkVjzMz5o18EDa1efJKZf4Dkln5DQ+anVPCezFk+eboodz/XO8tPIbVI+4/dtB
NmI6jflvx5rQJqYCQgFzQwssJjfWUjG10jijaCF8dgeMXOusXjBQ6e+qdKjd1ASu
Nop7u4FynkMrD+r54hYJWd3/a6xIAjExB4SeUxT3tQ==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
