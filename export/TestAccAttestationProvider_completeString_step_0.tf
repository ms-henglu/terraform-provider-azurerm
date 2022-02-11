

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220211043221295863"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapgbnb432qkl"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAyMTEwNDMyMjFaFw0yMjA4MTAwNDMyMjFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBLZXU/KXGFe3vmT2NxCDmtJCZGvI7
Cs3vyktIQwNLRODvms33kH4smeG++y6c+0LcC5iJL+5L4Eyc2IMEM8oTElgAXSBF
J2OUCIsruB7nmIndyjzoSggFpdYRiGnhCjkbGe+FmLy7MUs3CnzoY822zj5yzxUo
F3Uf1DkIHGoGLXP/iiCjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCASCFjDrO
prcWvHqIXb5b+pbh6HEery63Zn7FCq2AkSXyrTsZW1S8JBPJ0kT04ZwP6Gq9+nno
q8JpbICaW+X8VULjAkIBFIkxoNsN/rNTATxHF0F2yVgl6lfk6wWF8wnug9TLHSx0
puQHgYvEahjRK3cXQb8IMz3symA3dMVCl3mT/VkyuDI=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
