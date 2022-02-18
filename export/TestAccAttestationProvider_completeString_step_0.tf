

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220218070424941567"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapoyprmwqc41"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAyMTgwNzA0MjRaFw0yMjA4MTcwNzA0MjRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBezBETpPpy91aqZtgBP63LKOLJMGH
W7wAiQK6TeLUhRxTWPJzZW8nVgZxiI1zIR4hiy03MjdzB8e9QOLuliYQdDcBf/3B
PiekiYSoBfY6g9nILzRp3IlTqYauQWe22yUXhDKTmA6bqleHuTAYgwHqAq6FyHV5
JpwlT6UqAs3Jnt89RUGjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBJ7bboRtX
0mzIjWvMWILN23YNXfk0uESHclWWaSlDDXVIw1X31oxSKO+sEgFZ9g1fVhZIEnhh
Qly7hvU3B41f040CQgHtvKGAfdYe8fznGdoaFHDZCP7/MFtbiqzANabX91AG1L3+
X2K1OcpSnn/GtQ3eD+pOxltNCg4oQCgiHFOvZH5XoA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
