

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220610022226479957"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapxvtbnk4upb"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MTAwMjIyMjZaFw0yMjEyMDcwMjIyMjZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBJveG1utCuPmiA/rClDqJMO5fHuYA
B4IS5+5RdTvA+vOxAAZ2rXn2M5tDaVLg+snK2Bx7agv4ifBLcVyzv/H53E4BB/F1
VaZ6eVtIrf5AyL/RDlqDxAxuX89ltRIcan1DoWiGLLd9s9K8DKMx+AKiGrTKY2g7
ez+jdJPk03Z6ec31RNCjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBB6fL5H1+
68txjhRh912evRV4jOqf+L3HPlyGmcWGE14h+rBh1V0u+4+jicxEmFqAFzAkpB19
+/7so0ih3JDiGZoCQVQy6V69iwFmloJJOnmg3LJcpuVbuNUHKx3KcAXNpJ5B/LWX
iUyxMRcVLaXyM62I4Vs84rRw/is8J3jHyzlcWRPz
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
