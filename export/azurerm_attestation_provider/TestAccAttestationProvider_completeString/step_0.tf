

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221028171730165785"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapiy7nqeroi8"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjEwMjgxNzE3MzBaFw0yMzA0MjYxNzE3MzBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB5IhgNDjxnFxo/tiBtfzMA1HDEaMu
7mPhgTfZ0lrOeR5S2gQe1lfK9qScKUS23c570pBXS8eyAUznBUZ0mJMAuUgBR6+0
nQaX4W8U24MBSw+YvtoQeBsK9UF2O41+ShefEzBc9aG9+ay4GWkR2wGzqOOsiTAh
JbLRXRp5C5hxYqeOaj+jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAMwJwO6X
etR4C0pUUEJUF+4GVru9XNsaHlaLncMgyVukRsbuf7q+m4JVOxKrhuXNZyv647MA
RkEpFNfkEmmwO+ISAkIAz+yWoL1rUMMzeaYTp4+9OPeJ5xIPO80T+eM48e9f1Ngs
/e8VlQM+RDaSDUOj/H0vGZQ7gCaM1XXkmryUu3k3jzM=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
