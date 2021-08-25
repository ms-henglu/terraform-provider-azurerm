

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210825042555116417"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap9y02qrxvwh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA4MjUwNDI1NTVaFw0yMjAyMjEwNDI1NTVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBKGqU0I75lfG8ukwg7f6CDFquVKeG
hhBRn2hEdlZIjnQKa05Qoczj6TX26Ic16J77MHI3UqNBcTKzI9+snsx0EoUBBpl4
v3ZX98q64VGl3hNvCTme4Mu/MiK5sgFxAsBFlKMEecXjAsrpRoZRwx9VGrpNGNri
YuhJS58aA15hHrolesKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBURgrSfxe
pXPYFlUwrFsHbz3tNkSXk0gDdI566dJVI87vwiQPddNilDgBJwHvbiPvX3YH8wSl
DYgnrkjvhYrapiUCQgCrOLlxta2JC6KQYND/weviqSpcbwlLRV+5J1wN6hOuGUtR
PMkKkirYMd6IjzPHqNKTwPDFLTUYwwLRl8v3SRnWtg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
