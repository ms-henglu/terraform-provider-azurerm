

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220627123833697878"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap4zqx066w46"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MjcxMjM4MzNaFw0yMjEyMjQxMjM4MzNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAGRcBAipvuJ92c1gCPGxM8cuffPMb
6xiJLEWaC8YkD3mXNI+nJKmHd18RfqkmtP55UV/StShhgMQUThJu1runenEAo8cr
SZqN/4EcI4QDrcxxhjz0seFs6eimCfp2ooC5HOgeaag3KqGHx4nhA8jJBePiyjbP
nwwS23On3xTHEXHJGnKjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAM6ZvNoC
WgpaWZvscsoDg8qKqADxCjHVg55FVojZVaBHvI9bN1xQYhJf0F/XPbS581lJVZIz
SG26csZhEGgeoGXFAkIBkZ1v4VyFxY04g7wldHeRUZ/cMt9OjAG+EK75BuqeA/pZ
D+cSyCvfXq4FSPA5WQ6TGmP/ubt9GbkkVggSPLGhfTk=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
