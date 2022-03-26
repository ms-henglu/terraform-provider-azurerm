

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220326010127576425"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap1tspdwm4bn"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAzMjYwMTAxMjdaFw0yMjA5MjIwMTAxMjdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAbaGbrP+jVC8cv7fy6Q/O+u70P63j
j403wAN3zW54XpstmiY9OYjIgmSBLwSdDn+97OYmtRJH2M2bdN0jG+kpWZMAvVs+
iTAAhrAgFw6MXR4V185WHyhIdWIhRjU2OiZS90OjXx1olJPTY9hhr66EBaU709LU
4S5drTRF7fkOdAkOakGjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAennRcrT
b9UtSmNPk+dowD/E/Xezbg6u35yr7OsBM13uHuXHgSpzUXKCli0vlk8lNP3HYSrG
zzOrNgBPd0wYvxCnAkIB/8jcl78OeL/45fLNrLK40Q0rMEsQ/4LdC4HxvRXkpI/U
9H9w0Uj/v4EGEBNcjpnO6/nqaGNI/VyuHaH36+EX5/4=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
