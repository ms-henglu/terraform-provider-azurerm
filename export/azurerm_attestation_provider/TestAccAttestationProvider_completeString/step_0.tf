

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230414020744337929"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapekzsptrzng"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA0MTQwMjA3NDRaFw0yMzEwMTEwMjA3NDRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAzYI8dHExO5NVU8l/PkGec6wOVwdm
nu1slrJSVTDfRTkaXRXRr369omh9hcLkcJ1YmBfqKfWZDPkzKEZxNYAKctYB2v6K
fxkPFQsimU45FOeD+L0MXFnuUX8kKWO0QD5Dvotfdbkd2RGPqh50BcHKwBEE09UM
ZdBqW4gsynQQ6QbqIo6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAWM+Vgou
t479zR1i2Qiu4XctsZJyf234Vf/zL2yqXPDJPk+9AyVSQ9Z3VFuNiGbMYlAz8S1C
E3K8FdW46dLKW0mbAkIBcrrtGJSN3BdHbbqv2eVueKtrE8kuRiMwQ2uiCPAqXSKj
dBug9V/h95KeloGwlKNGl90tZx6biGnCs8b+kV8vwNc=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
