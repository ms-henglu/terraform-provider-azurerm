

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211217074907194751"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapg9248dhljr"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEyMTcwNzQ5MDdaFw0yMjA2MTUwNzQ5MDdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAOYWkrLhO3YFpHtNH9kN9oV1n8ghC
p7RLCHuY6lL7deXGCLiIRth5fRPGjZ33g5IgZMgOgsq3NE6Lzri84WdL7W4AM3V/
kK96jx1yvLFJHfQKzoZDjN9sYhY4KdUEXT31jWeKLTpqdNjYHMZ7bRu6G0RiVvDp
lBsz79vriAy/g4MmVDyjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAO/zqDuv
UB3OWAeEyE+QZR+y79J3eE25G0Qn5xufas0xQY4ucYZtApQGoi11Advn9MZ7Kuxh
CA6mx/yW/dn374wcAkIA6HmJDwgLbqvXEqi9gU+7Z+mhIdExhzUZKcbsceor7c9x
SfqA9ez8jBaJmGMHrg4j24+nX8BepPdIX7B8OlWM1Zw=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
