

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210928075159581011"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapgw199aze32"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA5MjgwNzUxNTlaFw0yMjAzMjcwNzUxNTlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBKt8b3LirhKLlm45CVnpGjtJgeBf/
wKDRjdZP3r9fJbVJ6qcj2HnExqh8ld+crhib6POymzCAGft/jaDvLzc2/IIBBETK
NftWxMsbjlBOpjgcg4vCt2/1vwXGdAnuziIceDsp9cZY95MEiUnV96YFyhO/1rGa
0lA/DcDR/q4gL6kxoqOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAbdOQyO1
RoUM6tH0fNHp2hqAQxnmEcrgGuiyvo1tseSC8ztUzW4EqCYQ2kvTBooZK+1bCRa9
PiKEgMUzJzsVNaKiAkEmbFJexT4BqCdFj/uOmKv3vtlNXcVUjoi+m3GJy25YTm4v
KJG+CFkWeVlFnIOiirsiz5ZQWlL1YpeIUWgwQCapOg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
