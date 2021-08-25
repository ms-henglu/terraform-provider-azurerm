

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210825044500307166"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapyrmwnt7bc1"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA4MjUwNDQ1MDBaFw0yMjAyMjEwNDQ1MDBaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA6LO6fKtEwjhFzdT0sIkuwWBmYXX4
hBYLodhGSymOKLGR9hHwKZ81WN1NWFsZieaSXH9wqAmHpdrcry0AJQNSOlYBitYN
m3LDjVoSyg1RlQOYqIV90JEjUbkQ5/8xh/LvseoiGxanZ7qPNk9OvmTO5L8ej+v9
+hLgvuuLkyNLriUvCxejNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAdKZdx/x
LX3KaiRJlXKKb3emh9Ye2KNPzPX3EA+aCQTFL62Ajalb/cZd88bto9LjbENe3Rv4
zrwBAE0HIBJ/DlwEAkIBjBQVKj7PNCXEzIwrrFxRQEvg3+EneEUI6wh/AJOaw4In
T8uYxWShsiqvHGmeLSOB+QHX4+jzkavLZgyCu7rkPkQ=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
