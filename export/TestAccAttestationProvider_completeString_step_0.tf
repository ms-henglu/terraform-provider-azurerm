

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211001020504344023"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapd6hntontcf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEwMDEwMjA1MDRaFw0yMjAzMzAwMjA1MDRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB19FJR3IpgyNbcX9MNL26qVftUya0
A6m9zfkWw7lszhkOtiwARp8vE65+ZbbOC4iOM7omDDQaOnux85tdc6XDJlUADJqN
vFXZuN4hNhDRJiBdNE5BuGfOatTRTn9+Vc4ZESM/y+yr7+lVRvRsTAi7vuJpihoO
ct9aBSod2zvrTUVp4J6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBUYyt9CbM
XGSHwDjhJA+6OhSqT4JW3kLwMA+o5ubx/AGaiAp8hiOvoeQeQnZWJbeDvUKDUFzD
HUAERKQLlE/ZAXgCQgCYlgrivESqHhxxqqhDZ8JqiKBAq9hbnRep59PIFSqiAyjY
5iUvOYde8sNIv9UeBTbXuVr2nZ0dlaL+/gjlt2P4sQ==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
