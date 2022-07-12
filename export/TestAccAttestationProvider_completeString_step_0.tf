

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220712041938685059"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap62amk3q1cw"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByjCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA3MTIwNDE5MzhaFw0yMzAxMDgwNDE5MzhaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA+VRhv2R+ctsoc6ejA4mj8LdvcjY6
uK+rTckt74GQ11utGKF+CiDOp/+EsvgY7ambbqE09yz+vTVrHaEYxN3Ga2wANuY+
ndlG6N9+Upg2tY5p6m8j5peqt3a4m7O6lcfUXKG19UEGR3dq2E6s1hyY61w24u9Y
WsE4KbnpzLKhxeR+9O6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GKADCBhgJBQ+mGa5AD
mttxzcopBbSBOgX+YwnJhz3Hpi3dhn06pMLCFVvtaFH1rjZZfZN9RuFgjm9q5FaY
8itevfQjmAhk0i8CQU0PVmAqWTNrbr8xuPsrgnIkcZplCQnTiP/m5TnswQYDnWNr
sXg2+ORiSKfMraVWiGvssBUas6jznPbPdZ0DJXKy
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
