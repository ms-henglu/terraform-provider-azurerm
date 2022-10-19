

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221019053854485977"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapg9iee87ebo"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjEwMTkwNTM4NTRaFw0yMzA0MTcwNTM4NTRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBzXGLsjKy485DnQy2lcttMocVas2R
j5IP12gY5OO0f/bAXg2vsJw3qp1suIpV+bsnbk4mpGbYHwLRldcx06Ot3zUBMeu1
A7m47+y0gwlqsyddseI1mk2XJhwhfaES3UanXlhDBOjEqdRkNHDuGPadwvpikyhi
wwEDR94g6U8tR6NA0z+jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAfHLF1xo
0Oml3AZ9rnL3hNfC4j7p21ZhsFTmpEkhBoPgdnlEVF/R7lguVN2M8PCfIuZ1uizE
tB9J7JNJg+9JlSnyAkF30dOmvJp1AwSw+lPuD8q/ZXe8AykT8YVz2I2bxu0sBDx3
S9g7s/el/th6PHO3uKx69S8qKzk74cou+zhu9bewNQ==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
