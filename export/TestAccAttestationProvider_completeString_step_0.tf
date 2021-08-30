

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210830083655636541"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapfs6efkfdq2"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA4MzAwODM2NTVaFw0yMjAyMjYwODM2NTVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBhqS9yecLiXMafX42Ya9IT9rSca/N
eOClCsiPfnLJp0Hvy4QpRc8qb0yHePjVvkDDcVSW1NOAuqbbniv5c+JGa+4BaqVV
2WZ4rYP7OemyQ5srUxV5QtbjkyMjTN8o5NI21IxR1U8KI82q3ZtpS/8f5wJlgRGo
3mMcMZTyuOBiSbC0prKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBScB/Ek93
vADRjfX4usJWDgCT9BG7eUmzmgx1tAMa7z88ynaHFb6u6Kub6BGOtiAu3NPfBA4y
AJlhTTF5kJjU9qsCQgC+gfCG5QmerMR3S6Qr62jzdAZMKnNQ3N+PccuiCMKbA7Vk
185MsQbiB7wuNw3RNAbNZn0KyCPFY6ONMsPpWYC7Cw==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
