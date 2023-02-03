

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230203062847713504"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapw1eftfk6zg"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAyMDMwNjI4NDdaFw0yMzA4MDIwNjI4NDdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBtghY7LI0Ceck8ALQBObP6dmgVajO
XuGW2XD603WA7p9w+WXF5VQv1YCQdt6ZG3G0RvSJgT+pT7BJUaxvjZKBGLABqzQ7
2fZ9j8eE8nEwKYZ+ugFwhf/I0Egb2nXJtlMxmAvDEEwFFhrutIIr5Hb9nuLnk1zQ
rgZvOFeEaj2296ED7VijNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAdVhgTc3
t2s2QVMQgMqqLHBCvuUU8ozdGbQ/sffrlA53mGagKAZJgZpnC0YKOuHZWZCFOY4h
kMvruundOZJAKDNWAkE/LcA7RbwavoQK60+h1rh4pKsbS8RLAr6GMKkqcipAMgWl
3NOZNNivv/erz1jDw0KShHRrcP8jz5NDVCEP9Z23hA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
