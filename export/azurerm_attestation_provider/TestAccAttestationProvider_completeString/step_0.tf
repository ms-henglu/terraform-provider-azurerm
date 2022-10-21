

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221021033804722211"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaprov3pt96oc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjEwMjEwMzM4MDRaFw0yMzA0MTkwMzM4MDRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBD7vMB3QSQadZrbVDkluphFd4vmGs
udGrdELsC6RNhv9ebSd2CcyuZUTkucMYYF24P0yy6YhD2fwLwknTfwPiG0EBmdZf
xBART2qCyxbcqvO+JoVGQm4CvS/xaL4edhhkhYfjVVjYhpOHD10Fp1rmDxa/CVCm
qJxoAnmV2nYiHsO43HSjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBY9uquCmB
6dh0hmgz0YW/0RoyYOGCHANaHRzNHcJwwVIDBBrWceRTmgR8SdSjwSYYCMAWc8K1
0IbSMA1w3PZp2h0CQgE71QRa4YAx/xNQpBOEMVZM95/W9KV+P3TMcOF/P/mMUO+C
B1030HnvWkINteN1YmaydfCUU27RQjVXZh+mRPljrg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
