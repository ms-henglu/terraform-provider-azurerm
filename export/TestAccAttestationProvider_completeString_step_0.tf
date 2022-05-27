

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220527033826515858"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapset1iydyy0"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA1MjcwMzM4MjZaFw0yMjExMjMwMzM4MjZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBi10s+PwSFV9nnEF5A5Jor0CkvJEw
7qWS4FKCAqvw1WppDS/VNSR3Jczz9nLVY1zscstbSe+uoW7Otb7VZDm+NckAYUXs
JfS8pxfV8Rrncw8i0re3B0SpyqpKdKHR3EMNODmPR68uj0g3ZR2aj2L56qzrXwXt
gyLJsySyqJS7PbSaRLOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAU62//y5
MTpyexEbb+v93i/8nqWl9N0x39TH3O1JVmUE/Yeo8fO6l+PAtvam0bWLSDg7HIYM
0OrAaTOCPfNFTw71AkEie3iltXiDX0rIAY+GPAlq+1HfpU95Fr5RweCB01DOis+s
58Fx4kGi/JVJbfm3sOwPsOxmuGQPpAxsn2Nt2xOThA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
