

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211217034913196934"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap99kjrlj2as"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEyMTcwMzQ5MTNaFw0yMjA2MTUwMzQ5MTNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBB3BCT5IiM/STOKbYeZRdFE1gFduA
mFTaZTHTv6cnk8F5oSKD3MaJX+RkxnGS+1J4R73UbLIfzaMFrRJZ9tyqfi0By7t0
P2g/NDExck/HPe/QUU6u0hHhX1h9y6nyg2AqQAGTUQpMmo8OGBYjue+kXBy/P+Hq
VfbMfwNhbZhQ6a1l5bSjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAODY0U6T
TDq7z3tIsxiROuLsTJ0i4gonmBRlqCNOlvmeS5ZsPkrwlIJ8add5mcoXUziEVc1K
gp9Ssg9UyE+uIp8ZAkFu/1DbPmWh4I9/CxDC12KZQvA6eEmzWQEb3CI9MuxCsvQS
m6t73TEFANQk0X74rySVCLFsScAXy0gOYvdPDG1rLA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
