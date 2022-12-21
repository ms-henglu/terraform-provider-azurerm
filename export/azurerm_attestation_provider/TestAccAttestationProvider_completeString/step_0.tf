

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-221221203943618968"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapvbllr9zt3e"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjEyMjEyMDM5NDNaFw0yMzA2MTkyMDM5NDNaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAmyEe9nh+9fCscTH6NDVGV+wFc5uH
v2IKYGxEIyH027EtM1wClASdTmOg9P0dviYfFAQ3DBXjalGGUnZEDF9/G9sB7dN6
v6I0WaoP2PN9oRH4tl3/HWAavjIa9kHwCV/7g+bb2Ee9sVvgJHx7xQ0ZYur+kl8t
nstoExC3v0AB0cZGwcOjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBIbYhJ29A
irS81wfGstnrFOFCvY4lKDeIQp8W1nO2c4pgvtDq5wUmDH3QX/zPaWvxf9LFw6Aa
HZLCCLNJXz+llqwCQSDWJpDRziEpIcP6E9/ZBsqXhaSnymPz8IhRH6WWWwIFpudb
+gBKKvjD+WrTYD+maWa0116sTXXoLSU4uvn4tMRV
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
