

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221111020011174077"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapzh3gdma3u4"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjExMTEwMjAwMTFaFw0yMzA1MTAwMjAwMTFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBL4dqVMBznEFfy5f4qeBIgoo/bh6T
ClLFZs4VwQOwteLfBGbjKS1ojgxaWsk5ScDBCsq/7dlRdFM4ryRMbVIr/DkBUhSi
WDkpACmps+ugD1M+NcvRmJ70WIKNZnmBGpxP7sZTHefzFqHXJAnEPdHp9b9tkUgr
WwMT1Uw5Ziy1Vz2NuFKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAO8R8NLI
HKCk9f6cMUZqRxBPAIEl8ULyAyCc+GHo1j8FRSoBFRkVW7vLmmfctZGS/73T8Fwe
rw0dx0wTpUw+rjdRAkElXD+ylrJ7BQivOKaz4RmEZO8k3abKvkE7Swm82heZJi/D
Dx68Pih1MSAOf5p0B9tixuAiaV9WqFdYPCg4OllZdg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
