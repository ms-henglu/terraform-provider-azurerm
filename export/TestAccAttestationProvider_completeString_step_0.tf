

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220225034030404087"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap9ir64kgxo0"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAyMjUwMzQwMzBaFw0yMjA4MjQwMzQwMzBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBS7FndPUcRo+lWVQcQE/cQaTpv4lJ
CU2hHP943QBU8J3SDQD+zYfJmTC2dk9Ev583z/okpgPXCIYXXNzB6wCG5P8AfW39
wrAkxDD4cESPWDxd9av7bP8msGkCwGsiMI01WvMfuEmYEvqJWeVkGycFAnaPUorJ
tYRVfqnadRy/ecLqq/GjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAdUeF2lQ
T1iiO07PFrQTxe5jB9YDMAA3lYU6kMH0hs7VUiuZaair1G6PaBIBsLPQNt+CS90Q
PiAU13AlodS2OWXKAkIA/EYZF10gjrhlFkzUPCOkwubsN5CoDXzkF8g3ix7Dss90
mgZjU9203d56CqMIHzoG8SbvMHXEhPUZsXJYJ8ru65g=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
