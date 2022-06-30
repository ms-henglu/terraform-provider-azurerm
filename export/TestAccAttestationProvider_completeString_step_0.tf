

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220630210454207967"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapq6exyd7wbm"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MzAyMTA0NTRaFw0yMjEyMjcyMTA0NTRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBe9tMv6aDNzYaetE5OCJjQgN6Nq0I
aIVZmd+Fom8KPl0TAcaXA4s0aUXdJsNvKKoR08MUANWWWMObw8SxvbpyoxoAeTUG
YBHsGhQvUWl0djUmMOazIJtWB+lZPk4veqMRbhIy3DThHA/V/8a5uQWF3ttMzv7q
I9gYypdCP4xBbcw+U46jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBFNL8xroi
OviEemEFvQ0ANOXSitUhKsoia6aL0/nG1C9O/FMxGSiIXblFQbvA+BvAakDMw/yV
12JrIKaz33IRPv8CQgCziuvgzsGsrp44C6I2O6L3eh2ifQeh+RC0pBeE7qFcTiYX
cI/samYn3wgitag3jlqCGIw6KRzvz6FEWkMWraFiDg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
