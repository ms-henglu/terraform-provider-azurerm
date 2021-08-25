

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210825044508356626"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapbex3uqzqej"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA4MjUwNDQ1MDhaFw0yMjAyMjEwNDQ1MDhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB3uKbJ0+hvSFjpynKvwOmWctSgoaT
q3LFhqEABxEce5Wmq0pCizJ1tvs8qRazpUrDLd+wGghb3d5jMggaHQI5ArEBE8kA
yTMf9nqJblQbRmuKueJWkjUyN/Drv95fU77I3Whscu3QvtfbH6rBXSzI6C0g/Br+
lEMkDfc0RGdBsWtXzwejNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAfUPnuA9
0B+Z7Mb3/SHr2akEHz37hvpBE39o0Cg1o+yX2exQBPvucbd4GaQ+6DJeSYM6xhm9
TqXtfdEj6j1KVn4KAkIAu62tcp+cTPU+8VvumjBsOD3pWd9AGtP8jBtOC9zVQbTe
qXwcmFYxVYtkJavwdvQl/X4t4L7FrAEp70F5F0mZoR0=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
