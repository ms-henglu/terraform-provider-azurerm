

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221202035142453174"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapeaoyoyt2rf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjEyMDIwMzUxNDJaFw0yMzA1MzEwMzUxNDJaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB2MObXL8lzCCpFkQCNCku5srATtDF
iCZZz5+wpN8adHfivkehod2syH40+oTj4DpgyQRY3GPDh+ri2/sqSywYDjsAgXuT
8rmk0uB3E+Icfs3JGRV8S868sglO4tJjZRgEu57xayEd3BvbqWo+IfY6msx9NUZu
rrPCp+7I8LkfGrZcou6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAV+Bnn1G
rsrJljCM9Z6UX/6pFsKcSxkBW5haoNo6wFgS1sp7bB6C/r8GlFnYrw4XzJqgx6aM
nN4h/ZJbuz77H/fBAkFo+e0lKm4k2vv2JhDZgVwfFK+8rcaE+Z2SFgEAzuxEXZ+n
HQO2PJE1o0zvZzqYnU3SwIv9ww7xR41BTk0lug1pgA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
