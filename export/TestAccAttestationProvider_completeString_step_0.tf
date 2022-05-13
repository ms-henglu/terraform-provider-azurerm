

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220513175928436281"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapavgspb2tss"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA1MTMxNzU5MjhaFw0yMjExMDkxNzU5MjhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBpUIwo3YJOU7UPaa0APXjIt30cthQ
jEJFtnBt1VxPU/DSuQ2WHayGPK9A2c+ZRn9rGOpujIuVPMbg6D2MIpVeNx8Aoimz
IS3UlU1IE8jtYj7iopwHeXDQmZAae69ILkjznHqpm37oGpPQsLofJSi7ZOMfdxLI
i3Px7tX5yad7P9HEwWmjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBS1nLptCP
lIGH0eWkZCJfhAxXIH0Ee0k08ieIeSHeu0xCcWO4lzdQ8wsjnMB8xxZ5LgvbCu9B
LQFBDac/TYNBF88CQV55ErD2xrIgXNX18VyxMfoPbroflsOjz0HroEcw4ZJtmHOr
dlfdZzMLYDKsffiQgjjbysrCj9Zo+GwB61C2wJMi
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
