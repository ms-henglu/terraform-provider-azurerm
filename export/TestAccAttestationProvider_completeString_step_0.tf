

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220128052145394379"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapzpa2iygshl"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjAxMjgwNTIxNDVaFw0yMjA3MjcwNTIxNDVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB4sJ+REC1ZK6+TkLSPy3DvrQcFCO1
6em0ZIXx7JNxaXfqi+5cY9UdSwZTTgwyQ8LJXJubcUI+sFl5OAmXmzhY+lUBrueL
Y2Dx1w4IN21E4UyEXiHTN4g5TmlH8gUNTSDg2q1Un6kMCgw2FzxSTWE6Ir8zy4mf
stXClrBv0dh114afCuWjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBH6QxgN5J
vw1TwNA7YXesXy11J2aRxNb4YsEBjXAchqd/EXdscIoHC1JgBdrKW4jsoG21u3+s
Md+0oMzjobRfaQECQgCi+32EWyAuaLhRPGJ2HxT/xmvT7RHvXSul+TaVxLGjsqQW
WwJvu6pEbtfL6AyRoF/PX3J4v26rK7V2w/ZLPx7zMg==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
