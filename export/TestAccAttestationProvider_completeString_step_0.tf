

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220311032059239407"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaplkv9r816il"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAzMTEwMzIwNTlaFw0yMjA5MDcwMzIwNTlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBsIWjvVb1nVZSxiPrO28PdA03rfp5
Z9ZOHnIhz9ikjuB+UOpqScXEomHAdAbThWY9y2vLZlxBmJtdjLiRB+pUfjoAEV/E
9Sp5j8oTnNj0dBo+AkvnWxYaGYjY2fUSuaLMWuvu+Nn/CfpEfOPGC3dxpF5w8TNx
qJYlSGQk1ufoOZ+/yOejNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAeemE6d6
+sEGUKsF0srLsNlBMuVbPJcM+f7mB2zC9Bzmxq3Rtrd0yuQBo+JtRwGcHbRzwghu
RnqKR5uhRrllOt+/AkIBX/eg83Kt2fKWYgS7alSyIBXjHD3LsITF5MhMdkj7SNd/
3ni6BSwpoP7AvcKgm5WdCETZHtJsXMW99lfCSeFU3EI=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
