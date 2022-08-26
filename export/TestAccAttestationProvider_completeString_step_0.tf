

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220826005514348224"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapq3buj2po4h"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA4MjYwMDU1MTRaFw0yMzAyMjIwMDU1MTRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAtwqfCV/iGRzB/PBCMjIotvoNVof4
JT2zLbFouVAj1DN3DW36oe92b83qWUVita1qIeEFOeXmyH8rEJcv1Ak4JnwA8e8B
Jt6x8XnrjybFu8u7WkbNsfPHLg05V+/8UUHv3EU9mNQlsRBXdyOvQpwOCOpUCEX6
dNkqvW5nGz0JBHTC2FqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBcpACn5oH
lKLwzUGObeWQ91TiidXWeBeQwcfmcCXVi7VvRk2L7O/XIjgcKjiegSgxFZLUo1uz
xLEan8AnLh3j1JUCQgDmyPVNksGFIzCZvDg2LPG2uXmxUQjtFO8HFVxlPrr/HGbL
r+rra3ard/rkNB6myKKzQ+nwDLoyXSHClK8z6MPi+Q==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
