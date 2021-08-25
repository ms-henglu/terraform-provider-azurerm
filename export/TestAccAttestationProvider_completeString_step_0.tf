

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-210825025525175898"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapixf99moeo7"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMTA4MjUwMjU1MjVaFw0yMjAyMjEwMjU1MjVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAn6pSOanc5lWkVmMBAkW3atNc2GTh
F/KJafF7f164yCqx9eBtA2i4kijDmERq691r94gV4dzBGaefk4n2B100fvYBg+Zu
HLShs+Q3+p9f1uXHgYmXf+7Wg8wsKzK5TaYET935Nl+c4OjMXEfGwHTYKzYWBh0U
qKRjEdCanEQloBlYc0ijNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAZRv4WJt
u5kBOwXAbZMrebt5nS+rE018GK/UrnTF0v0xsmom9sJGb13/hLNV21vfhyxrfOZW
NEox+o1TylFaQmSJAkIAtqkpzjCcEoGkmsbA6cMRlGvNs/Z57WolD/SYIuR/OpE9
Jxfg6w+EIxSOHP92d8cJidhX3NtzUYcwFvAF5g/6lHU=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
