

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220520053557898704"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapa8t4q0b4ey"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA1MjAwNTM1NTdaFw0yMjExMTYwNTM1NTdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBWNlobxeIVbgGHNmYhDsyHw2NsWWX
beVul8yanuLXo1W6tpn6Px2nDINC0J63RQe2PKyepZzYO3eEaasduNwx6YMA1z3x
WreE23eBKWWeJ0owGoLXCy1kMs2ekd+0j4bB0JAF2lZosTfImmO/Lv66KBxMjVhY
f/QQrFYgy7+TD/eDQ/WjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBZeaE1NMn
6/iHLXSAcnHYpJaKk7Zz55hBmGKIOoOTJFP1f+RoNKyILE6AjEHa36JwYanzs0fY
hWRmhp3EAjU1iO4CQWY1W/iLTsqsJjwiqX3CCsFBEfUBkgorZU6rPz5VHqk+EeKN
1xX0ImLu0Usk1YwYTcrhqdjsXIuIuGpUL7+19vtR
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
