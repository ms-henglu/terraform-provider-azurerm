

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220324155923316273"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapffc7p6pqwk"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAzMjQxNTU5MjNaFw0yMjA5MjAxNTU5MjNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB7Fuvxqn2fb1oGHFYnbmNvmX4ELVZ
l4VYt9NwtCBHhKNEgMWNXVkpka2FrDsAATE6Ep2KsQDGjXk3cFr9usNVQ7sBpusb
mixHGGkVmO3bJp77YmbWPPiaST6JKMEHTevz0U5l0OPEpGpVBV8e17wc0ItpJzsQ
7+NuXznE342WBjZD6CyjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBJnSTuXN1
jcOq5KtAZrSVExLhI6hyDpWZNY9TgNBeTwXrqJKp8MCYrPFO2I2bYHhwEHx3bZOk
5d9qjm8mLMGLBicCQgHxWzgLNx6yOLHp3cAallQWxX5AGuGwF68GjitGvdUT8Oj5
Bn+flhafHYYxa/nibY2iUdVaN3MGadOqBLkzyBVBUg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
