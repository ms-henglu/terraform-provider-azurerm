

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211001223644843398"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapy3ouetgwms"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEwMDEyMjM2NDRaFw0yMjAzMzAyMjM2NDRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBVGAceHGfesmq5b9WzL8wDGovfdNW
GX9mEQ9Ckej+T8lH7xzxBXrPZJmaD0u01HfoEK11J/pcJzxzj4B7GplURb8AoC58
vSSr4X/AC8ZYMXpTYgkDAbFkifASiTyD9Ig+GfPLiZfJIF1LWvEs2BiEwEmXoXLD
dDsEMTuz8OdCkox6I/GjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAbBpX+7u
Jcwq9HAShxxBDD6iPj5BrLXrrRu0TkpzXqnH5YaXTc/ls4/baoOxFHKqHn0PI32T
VVagPpGrLH5NwxBhAkIBQM0hfCyDnKt0MoTx2qyntw33Tc82ak525X0CF9ccKS6U
Vha7Rvsb5bnpvfHB6JgY8Zum6PSdxS86WniXX9lTFFI=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
