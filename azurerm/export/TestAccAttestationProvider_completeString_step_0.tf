

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220627122407394090"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapugzfn2ncfp"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MjcxMjI0MDdaFw0yMjEyMjQxMjI0MDdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBFwvSPYM7E5XwbMT1CBXZbCeKlyYO
wMrYleAdnx8J4c5L/9YveP1PE382SjhtxgWI0hkwThTd7WsTnANBsCD5FzoB8S4x
SukogROZ16Xnpl+3dt8LlaRAZyBVaR1w792eKeNUER3Ts3QQOY2TM4X9BvA2lgAy
NHp6FlMs/p7KUZOn5KijNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAVS5Hqe4
zPpdMP6bUS9o0uvBkOLBr/fbxkQGTgD8b4B38vfHWi8wjZXk8pKszEAlF17CqOYZ
CzRXNDyia9pR3aO8AkIBqYjOhnT3LrjaRJe5/BoJEn1w54S5CYgJORTmKjybEwvj
vrdGuhAg8GAp6JPwUPoU5R5V1USWXlDalRCpU9ungTU=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
