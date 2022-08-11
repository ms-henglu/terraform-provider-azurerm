

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220811052852504831"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap1gk8u3cfqb"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA4MTEwNTI4NTJaFw0yMzAyMDcwNTI4NTJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB5Pp+TVGpSAphnxtBffPCtUCNzRzg
Ubk5lvk7mkf6F2xLvPTCAqjSWaivDNZLDb5/I4BrDV3eZ2ibHBuX2S83cc0AFrgy
qbvBJr+aSsNieuDP+GKydlS+NKg5nBv0mdptK/8TvHPVCpyrn0vM7vg7HLjz/o0y
b7XNE69w/+e4zpKCMzajNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBP0F1t2pE
0hwPdaz+yRZw4CbyVqs/Th3aXoJ+ErjGvN8mUAilfm9e6LGpW0RD1PMmSdbprk08
8o6v3vk9XG/kzLMCQgFERmvQEg1iqP1BhCmPkmbAncRj/bn9HKpg+75+3d4OsMtI
bxNEJ3QrqHw6Ms0SAyh7MHYC3OZzJ2ZQ/HJXvnIHDw==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
