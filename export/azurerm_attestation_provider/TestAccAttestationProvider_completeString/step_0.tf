

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221222034234460003"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestaptt1a36b38p"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjEyMjIwMzQyMzRaFw0yMzA2MjAwMzQyMzRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBRbZ6VR6W1KS1qqtlkK2aa5rIqY84
s3hsuBsgUeF8Naz3HQRFtn10PQRUGPweTyPr7hnCx7jOHJ+e1JvCgPxcxr4AC/66
nzXo6WTuLkaqIOvrVgyhjP9wcYsx7rZmLMfwOTQKvwFlVHG22Jf1v4GLg9FzdCyd
pfGzWrJv46L9HqzA5UyjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBWHBYKSm6
vtqshlI9EnYjSpBCgVctsVGU0AMxbk38ezn2013M9Q3WCvE3eIMMAwEyFWi7V1oX
5WLwmos/6wpKSHsCQgFOOsmMk6jkRVeC/pqny3Nkf+/iegCU73/6yNkYwUlPPSGr
nZ7SOONLrUGxRIEL5Aly/seKcja3raleWjSCluARNw==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
