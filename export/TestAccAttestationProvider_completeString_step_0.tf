

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210906021946222537"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap8hfmmjtcec"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA5MDYwMjE5NDZaFw0yMjAzMDUwMjE5NDZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAMW8W28ZVZyzqjaH4ciFO0zuNlhIB
fc2IqcyyYIAmnmxCto9AnePiOQtlUpDx3Tf3bFFsokjwTI8wNA8ezMvNnjYBbBOF
JDN/mh4hNKJyQrYBw/ZXlWhe0xVF9aXjQBg4/am4Hj5Mo/QqPCbAnq749S3Q6i6R
OfX9jrJi2IdQYKijiJqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBXKj5HeLA
9dkBfX6SMtTgsxEozqPNsyuqYYAiZKkIFFpuXEfpSTpsOLbKQGmhMCeVQyLZ9Xtb
f9UDINk4vg2CkMUCQgHjOQXOudZf5nZQvyPvQU8JUJQP5xcPiPW3RpQIQyif0g+p
hxjbEUctJCNz0jsUmxsJsLjWEdH/O5f6x4gvuCySew==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
