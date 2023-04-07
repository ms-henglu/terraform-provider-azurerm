

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230407022912800094"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapgqd4dutt3k"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA0MDcwMjI5MTJaFw0yMzEwMDQwMjI5MTJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBctPuB5sNMm/5GgYj2UTCgQVmzRFF
CRAiDmVkXeNaRrkaWjebo5SNAR+9baWtJcMb1LIBpuXkD6RGIqzdwQZFjBsByJlx
cuXcnRxqp5y5mxIa0cZWAfzRVxdcW+tb+GD2qKmL+TOF0d2WLDeaGBi6i+a/AQ02
L34yDRcQW5jyXz7l2eqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAeIM4WcL
6OZCLNF3G6Lh5SEmHkaACUldGgzHTPTfbvBd2Tzzv4OKl8MLosFMSy6r478+UNlf
UsNA4djufgciYCf8AkIBelgfWOtr9repMkKQshliEs0PxfqQ2xvO3ROXCtBhyd1m
irqfSve0WkZY5Ya/tURMkeaej1XpTI6VZz1rhF3hdjE=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
