

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211105035535706907"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap2lu9zlkpzr"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTExMDUwMzU1MzVaFw0yMjA1MDQwMzU1MzVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAErVnpwHbapIvoNkYrDGVhzPrHuWP
lHkfqVSUeLL2Bp5I9rYeaOJFoa8GxRCNzjkzYwVi8EeFKhQrP+2UjQfUk6oB7viG
CY6xuPlE9YxZfejyMd3jxlhIhwARkW1cKAvjjweZqeuupayQp7AItOtpA7Ywx76W
fo5zwLdIrMnVXuIi2NyjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAMQo8oiT
maSuLZnVCtYvn5BxPtRuB3UVJLHMyj1anNgVvOe8XmlIkbPY8EL3VNzYghe47+V8
yar042ebiJsryKB9AkF9qUpiebl6BU9vzUhCfAD7ky5oa+hIvUtpF2ecS6mwf2VC
renAvlj2nOJvNNLY2y7zkxN5rIQJ70THr2rDnY1ufg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
