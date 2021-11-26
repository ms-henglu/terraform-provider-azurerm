

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211126030905930924"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap1y71ybtdiu"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTExMjYwMzA5MDVaFw0yMjA1MjUwMzA5MDVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBt0A6GJ1GeGsJxJphPpe4GC5T1XfH
lcw2PrInk4soH5iUlkL38S57XdxTtmcoLRhk5I0VmeBAj5/FnEPnrliwUQsB4A9+
MHClPHB6oI2d8PcYOQvG1kdJH9+ZDUInbaxNYDykwCLQV50JY1iX2QisNLnSFG8s
FtLcMxkgszbmswyPBBqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAb9jOybr
9SmUj2XJrIPY8IgcgbFQr1zRmP8CDUEEdRLU254/jdyrILlbGbHJQ5uhLgolP/aq
3sOZFEoQ8VSIvb55AkF3Bj9LlLv3hwO4tpNeZqhGQmO4rDoH6VWvpkADw/Vmfk+3
CSl1+1swzHGyTvAX0tKKLUGcIWl7briCveo5+1DY+w==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
