

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220812014629278630"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapom016lwkc4"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA4MTIwMTQ2MjlaFw0yMzAyMDgwMTQ2MjlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBIvzJ0JSuTEKMCY7VL/5f1lnDGxrO
yRTw9lo0B0CAUbGqzGI5IMQ2zHYfAa/xytV8wVikah4QO+lWnhoGwYKQ22ABTyXq
NS4SpAXHoYa1PMpB19VvOb4AU7TZT6rRXPRpm/CiFoO4utRB1XA+GmxF0dGKfinJ
Ib5JD88j3TCGe4weIHWjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAOVaguXa
Iv1jrgBtok4Q1KgE2prYa1cxIQzrT1A93Ec6VRFMgHvruTwlW+jdKiffrZkWXpRe
uCJYA/4pajy4SeHbAkIA2UlLsirBbyflEUDxBSrNMQo2AZJhsNjAN1ciDMbOqfav
fuEdZH4Xo83LNuS8Yac/cAXVRNeRfiUMDAKT4Kt2GDI=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
