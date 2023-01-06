

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230106034119782530"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaplncgl773p1"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAxMDYwMzQxMTlaFw0yMzA3MDUwMzQxMTlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBf+kIZ60v5X/YiNHhu0QsEsbVwWH9
nLUJSq/r4I9d1xlfviokbilCNCOsoVNr6qn2nH5ff26DHnRvDLN87HXtal4Bo8QR
ue4J1ijRPbGWkUOI4sn0xftgjwoyq04dd1fQ+h/up6c5K+h1OnQexv4Riw6LXZB2
1tzO4uxvvburK1/rBgqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBQs4dy8Ix
rvMp3QbZpNbJY2uL02kdY4n0BpeM0FNfmF8vAFAwS8ysWgwLA+t9KdpxFUouKiTh
lo6pvZQgpU+LZ4ACQgFtv0l0JlR5KMPa6x8qyLCSmiOX2MZX2gM5a+2AMBf/0dA0
1UzDbUAwubuanQz9gJFWzvHNW+R5ruvcHkLYe704Yw==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
