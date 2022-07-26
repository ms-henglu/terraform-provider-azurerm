

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220726001546808111"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaps3qbszgk2a"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA3MjYwMDE1NDZaFw0yMzAxMjIwMDE1NDZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQALsKXdtudfp6sLCU/qe9ZlMCx/w3L
sk4IcLla9sN3dgLkwTEbO0sh42UglyGwx6NSeLa7w2GsKxfAvo56HuIYp14BaOks
qtemh2SPIqJYjz+jgKJ07cLhUTwNYW69eFluHXja5zXfolZdwIKZHmDdr7LaTXk9
8IVlGSBCD6NOR8z5MomjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAQxs4gC5
/15LzTS2A9IQuAmVTVplZU7qbiE7Z0Go1s2fLw6re7zBW+giX0sJ6R/XUZSafsrL
jIowDn+niGRNcprUAkFNvkl0F5QXf9It2lDAbbHu+fnvGBegOu/PfrgLhjTtk4aS
RfpITXkdsjwy0QBGYN4lY0MBuDLD86wV8YXDrk4Hgg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
