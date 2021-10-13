

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-211013071526418658"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapg2lcrpgnja"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTEwMTMwNzE1MjZaFw0yMjA0MTEwNzE1MjZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAMdhvPwdT2FcMuixnmeE4ltu1yBcX
FrlC3oLHZQ/UD9Y2ouZfHh0uOePfE7lDZQp7Qj/tQY4Mj7imhHKcdEh/Gw8AdIH1
M8U7qZU7srXXpsemzX+5xTPTvEDkLg8/IvNhUg9Do84z9vpLgryQmLNzXvcrWNxK
I7LwwI0iWamOfHGJwGyjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAe86qMMk
kgIYfhB24MEB27JflODwyR2Wk78Otx0uw8aU2Vf6U6hprECigT9nPTY0bRdfWl8y
tzWpRmHsDLsIf1bDAkIBNax2fl1CEjBejbEZe6nYCUdXE/ZVOSqoTQXKI0KXygIG
2mJqDgWD0ZqePHBc93w7oiDd3WmfWTse3XCBmoTZWYU=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
