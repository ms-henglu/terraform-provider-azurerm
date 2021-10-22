

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211022001650102753"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapcf74nql4p3"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEwMjIwMDE2NTBaFw0yMjA0MjAwMDE2NTBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB9UPu53uEFfZjQAmv3D04XKkId835
zF+ryVyVxmmnqZY5ZlDHfY0+AyXg30hFlChqXfZcrmlo13roz3B1JhiaEgQAgo9N
V9AphBm+HSvUtR+uW8DkMGlkpu+0o3EV/o+luJFMulxIir+O0gWOTddAe+zoIF6S
hTlwdCOTwY7cMlcCvk+jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAUqmFhWo
gnMQdeODU/Rv8P//dpL+ZzroKN3gU10+VbMTXL0MI6aP4CWhOdKGF4ipUfjU3/2E
ChPa3q2CXnxtODtRAkE9HeqcCf7DJs3xSiZmYu/GEn4EBtOiv0tzg76pbl5zCpZe
BNGnA63c5am+PVFmgzysSCl2WauSYdsk6QBDNIhHGA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
