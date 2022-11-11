

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221111013105449835"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap3urdg8z99s"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjExMTEwMTMxMDVaFw0yMzA1MTAwMTMxMDVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBktzWjk7B4JaTiO6yBP+4+eY1oI9O
+dwrcf/QFM5ySXs742yxYip9nbYU52VDCzpiK8vG7c/g08ZQ/35ti0WzUYUADv+y
203If2supMk/3IOlIoA5HoFzhwsSMsv4aHZSQl8FfC4kuto4fLtu7j8LdakDdEY+
rjUR3L+RhlRfCHg9lNGjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBJLEV4Q/j
TXzq2+tgcWZZgpUZlDB1ZACkEl1gooZbPdH/s3bS6SD0ZFKcfd90WDRAeojCrhi9
MdRd9n7J3SjgoR0CQgG21VxnzEWgWLT9W//IztIL0pNBoqlGo45YgqrmIIFjn1Bp
ioi0S0Qk+f6ZOOV7VcvYe5vsX/63n2ha4sDJvEyEqQ==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
