

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220726014508985886"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap64bwph4jlv"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA3MjYwMTQ1MDhaFw0yMzAxMjIwMTQ1MDhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAlV4gUC3euJH9EcMqLgeJTsPev9gM
hzLDPCnQ+1oreX8yctm0uawHSLhQiqy24MyOe+EpBEnoQ6EPq0fy9z/gmAcA3VV9
AYxD96mr/Eq91XTGX+eYv86r9VMX/4886uMr4Bg2KKOgJcc2E4Cq2GA5RDAJhgVU
h9CKZuEaFfwfBiT3nQOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAK8VA3XD
3VAhb+LNQYbFVjcSGQl4Y39SP0ajKSLsxo+BfLMpwLg5I9f5fTP2dghbIdgw+Qce
9sJ2xFQTIMfm1OoBAkIBZ89Kf5naxRMzIDPNHdQLbgNN3268e4bAcwAiw8qYo8x8
PHUjgYTpB5KKeStTmSsKAzNV0ILa4RmwadFWAjHgAVo=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
