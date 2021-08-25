

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210825040505477652"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapn8qbm6li67"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA4MjUwNDA1MDVaFw0yMjAyMjEwNDA1MDVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQArhCE7Ga4vnOl51mR+j0Ek+VvzlfF
BeJ9i9a5lGhYh8SDWuuBsQkzhDBvAZgLxhjFQ8f6+2VNahYZfT/pe6jmfKIB/f7R
44RN5ctrZXvEfLL6Mh+OHavp0iN0FENOCdpoypXEjc1oM6v+11ncdQzfOpnL/7wt
exp/kygAd18YloJNWk2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAShzB4hq
TytIfc7dZ1xIkybWkZ6TdpNqXXs1PtPTlRRPVUyyjsm6TB+bXvXHX4HRBlC/tyoC
oP0e66X1AuJNgdiTAkIAgeFFGfQ3yYszkGaEIKFdt2NL/LSMJQ6rcs2iWvsIWceX
CbaDDScF9PonNFz6OoJzpb3stWV3wFypg5zvFRK000Y=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
