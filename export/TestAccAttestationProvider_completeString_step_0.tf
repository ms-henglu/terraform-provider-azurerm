

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210825031417786985"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapi4x343jytw"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA4MjUwMzE0MTdaFw0yMjAyMjEwMzE0MTdaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBcG7SN2uVr2zt3INdWH4rSodaypv2
j+YPwzqq4DMT+NoocDumpKbFLna0lW2J0s1QbsPxp9fQY0kyZVmuqogfDJYB7OM+
u4PrDrPPY6+zw9KdSw5oA29Qvh9h5RPs8zLohCziIsRIRuTrcNOHKUapStZiudXG
wn2/z6eD+mXDugLGvX6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBDiUKV+Y/
xauBzcRtZv1C8OADl3wJVryzdMm2SbFsWNbk/GUvTp0BUA76Q5wR54blsJggjpKC
TgiarXzfDIAvVo4CQgDSRxkXFymCEOeySyFcxZAW++6lTS0CZoUXVWETQWr4RJpv
Ceh+AfJiFCqY+Pff3U78LHg4PTYuzPCG/02gIpD1SA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
