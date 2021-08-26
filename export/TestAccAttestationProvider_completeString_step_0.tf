

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210826023056427304"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapqjuxw3lshf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA4MjYwMjMwNTZaFw0yMjAyMjIwMjMwNTZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB1VnUfuaXilgQd1nam87NLMzWwMx9
52GKP3NiDq9hdzEJIYpcWlDnnNBzmrR+rLAHrw3iL0sYLIlqZjluT0uXO+IAgE7v
QJHFIznr7PcA5iramov9i1RJa2Zq2hmaz9L1beN3h/9eDYgJ7xPB1Xl8tY4JN42Z
wETPIOrUY0KROluV2ZejNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCASDYHTF5
+ohfjIcalOsEwTkHqxmdgc39rFz67UhCEQY/+uimOEX/+9Sbrjp/enVsFr7db/HG
+oLmqcuFpg6vKjWKAkEaxfZdbI1JEqM1cz1Ybz1pS6gN/Q8seRIwdsVKS9h4V84a
14MsXpACjgsjGrL3SHFevBVY/HXwHhHxCffQke/+Hg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
