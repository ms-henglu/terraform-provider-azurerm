

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-220623223041683563"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapw6ycrtz6fq"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMjA2MjMyMjMwNDFaFw0yMjEyMjAyMjMwNDFaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAVqt5m9/YN8+D8krIA4uPNJuWfiez
7RrpHyQaUXod8sXDe5QqQkJXUVFOR2YcBV2GbQi8T9tfZ2NWMGZmkCtLX5UBYeKs
ZKJoZvzO5joj0YeEHijEstuxvbvLw5EcUn0KcQRhkT6eoQBmqjSgHPJArzIaE+9V
CNXiNxXYl7yNh8KH9XajNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJBYaC32FTA
BXcKMrqeTGLpIyP+lvfDLt6hj3F+lIxfXRG3//qL3fmJ+y0KuoFWVSTyyMqy0/SC
VH6YBh8bRkGIpHcCQgEGcVUTq1Yt2NOtswbNdkMGGVu+7SVLb6sFoLwlqEyl0Eni
hvJybJ5QTfDwFpovxoHw6iuLRPLfQ2Y4eWoeHuO2hA==
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
