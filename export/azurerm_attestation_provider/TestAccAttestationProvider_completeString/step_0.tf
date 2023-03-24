

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230324051628509291"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaps8pkgr1oio"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAzMjQwNTE2MjhaFw0yMzA5MjAwNTE2MjhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBSuSxwwN+k1lSWULzreGFJ2cxVazf
4tHSKD4Xk+kSoFKxrV+89AICtEwABX/92pvOxK8HkppkPX8byMAUe7pfh0EAnS6G
qGIT1rpjmHxYE/kPgWWDm8hoRjUSRYwnbj6y0yDfBI24Y0zcsbQZCt9KKM3faHJB
8E/62T42ASh3fTygT72jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAb+usNiq
0ZY2cvwXc+CK2dtjXXWRmrVIWKP99wtYQ1e1PzkXA7TpgpBE1/0gTrB2yqNKA45r
8LBDHyadkieSjPNCAkIB786SD9oKQCqzlJaXO9Gb+hOeERzJlxCixaVcu33RYlVG
CZnv+fmmP0xQLe5ysgf8yP+39B5kwyYg9UrMkRDnYhs=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
