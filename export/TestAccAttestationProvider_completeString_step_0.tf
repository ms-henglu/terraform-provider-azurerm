

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210924003903624534"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapmojqagill6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA5MjQwMDM5MDNaFw0yMjAzMjMwMDM5MDNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB2JcZMMC7s3J9QtCqoqm9NbEGDWON
GYN4wJknkHGIfHkQ4zwbFKMc1aprStJPP3w0i4sLzH9IG8s0d05/4hJit1oBFCPL
+rPSE9yiBe5V9D9F0a0J1v6dRO3Ne5x7kwLyXwl64ki/nXIpRvRupa5py9tCtTvD
nU8vowJMZkGTupWH3n2jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBaq633rRZ
rVhiGTVPcGwWtNBsPvy9lQ2Xr+obIh2iGwIkvz073qdEAv9mfp5iWWKSgzmZBF31
qCBTrBw4KRiyXCcCQgHkVSDa9CpR3E9OifeRSA90y8MCP+oqlZQmjLMSQb47qD92
yC7CwZNajv0xyfr7wNoHuWZYLa1LqQfi8MJS4gRZoQ==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
