

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211021234702918530"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapztcxvw9pyk"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEwMjEyMzQ3MDJaFw0yMjA0MTkyMzQ3MDJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA5WVKEzhWjcWM+R11Bo23SsFcg2bj
b08ddYdcyiUnxAdQYiAxUSwVk5+N7EdTezouVu98zt6gpQhwNbmlxDKo5x4A65wQ
+rID9moJAqpwq/LbXmMv7jpclh0TVKtCrlybc/B/OhKe8ZjtszsXY0wzKFvQyaMx
/gdRv3LoVupGNImAPUqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAPd7pa8n
gMe9kIEYWXvGHioFct8U0nZW+EYpXDDlTNPE7XEy32e/Z+QYYdD3Cm0onmqVmrzL
ZfQE5w/tRTsMOdlwAkIA6Z7Wk8doZCfsvgGvSmgGerwvmYCIZVVyVcAgQkdls5V0
hN9DesORjCxNLJmy9+rXNvvFIlPjLmrtKYgXX6W0r5o=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
