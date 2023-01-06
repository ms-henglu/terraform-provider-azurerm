

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230106031126749978"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapxbnr1vg0l2"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAxMDYwMzExMjZaFw0yMzA3MDUwMzExMjZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB477/4XQgYif8hgouTNgR47TPvotP
BSiViRl9IXTia3a+7hpqCNfr+71Sv5+6vGKgP0QcSEMMKwksmSSeGp+kjsUBhSG3
6JDxYyrWgnlySGvs+wxXWnxfQY+zUo/yaN/qDor8RC1rvx/r11WFq0AvUxzfiYYx
goDxB0QjNhyqXZIOK7ajNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBaYgh78l8
nffxsB89xtfiijmEAoxi4nJGNd5QS+Ve+8+rTSaIksOh0sFN6i4nIe6il9PQLPDW
IyLjb3xSHybNE/0CQgEMMIuGE83r6KJBaCNuA1quU6OQQTK5GPaYHq5oS3WLFZZT
PBkz5S9U98cFfyj46hYTd8tEcXoZC7rjhfQ8h2yFhQ==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
