

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220324175935401663"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapay3imbt902"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAzMjQxNzU5MzVaFw0yMjA5MjAxNzU5MzVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA2K/5mkt0Dpb3HtXSob7fwTxnV6Ib
SOy0vr2gd5pgqmmtfkws0OUheOALtjunx43UCaN2jDdYMwBkTR7OqHguHRoBYiLQ
WOoG8+sF5xCLnmsb5n8lfum6rgH7qMVk4jSe2y3BbhyAgYHS+KVUa0cHL3rUIaBw
HT3D70R08DTLmqMTkyWjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCARBLR6pM
YYlir0eS+5UwaybjfHwY0HNMw4gEFGJA4C/lkB2VKofAectKFzD4001GO6r9xkgL
60xS7asKFTA6bzsyAkIAqM80x5Ao6NzuExICpFeMIoaAh0ktgLmb5npg5m8NffG9
oisZ5ss8MbjDGBc/jndG5ZNgn62CU8K6gHQ5Z6Ep6Gs=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
