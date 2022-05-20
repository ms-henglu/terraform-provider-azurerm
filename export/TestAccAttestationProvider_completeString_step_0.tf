

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220520040345439074"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapnn1kgem0us"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA1MjAwNDAzNDVaFw0yMjExMTYwNDAzNDVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBWYLvSeUDE+oebbolhXZa9BiRcu99
Hs2WVNYW3zg0j3zQkXmI9SiTFlUq3anVE1Rt5vyqMvFspExpfI9w3SVdapwBFOT4
BZiXDpZ3nIbfzwBnElKS8+UIjJkD8KrhKSEiwigZ+bnlbcxOL0foVYT4BnD08cO+
k3Pe4u94QdPnyZdosT+jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAUcEdfvQ
wYWE5puukQkhw0CULxvGTMag24bS79Wqj3YSlgLPMyy9y46wVrrHBCmKLoTDAlJH
4YyP9PaVm6CrojZDAkIBZF+hZkS/QHmHj0U8Pyf/Pso8xOWg+4OcZ5U9nKgirbhz
cYqvAZ5ze1jVBDUrNN/2QHRONMhkiELx+AOArtrTFGA=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
