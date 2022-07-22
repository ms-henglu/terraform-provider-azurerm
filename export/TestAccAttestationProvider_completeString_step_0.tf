

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220722034826839282"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap7xtdj4crnm"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA3MjIwMzQ4MjZaFw0yMzAxMTgwMzQ4MjZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB0yGdeliuicqwoxmmbnvhybp3ObzE
lV67dBl1zknvxmm2USytrjgzWmRYYQbUskpg3uEdRDT8GA6DkzRvDEvaRbIAEkGx
cVKzrDTKJFbbUngjAJxrgEkfddfyqFROJAnErZa3nWztLRTBMxV6MrpxgTxJGA2x
dygOzcL0YHo0zPybQU+jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAXJXjD8j
3kzVcftLZH5D8iljxStkfMQcs7Ufq4wXS+nIVaQ97Cw9gYl8PkgkOOrGxIdJhTGE
2p9B03Ya+fJd31wjAkIBwbUHSPHCzicecGnwns7mqr0UmYqxftn2gOxt8Zce2ziB
0ZwONR4iJtS156PseUwjv3yKNf7XhUWBl/9ODQiqc28=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
