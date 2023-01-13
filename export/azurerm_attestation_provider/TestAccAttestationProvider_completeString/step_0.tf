

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230113180725041784"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapx6be7grmjh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzAxMTMxODA3MjVaFw0yMzA3MTIxODA3MjVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAIiCo0zZIx76amBhh7xPAiawWDLy4
+X/otpBKeGsY0p0HfyZERwd6eP06DIHBUZwXkB6zT6FtFTCpXfl2rKHfJroAQ28I
PHNw+WF5C1nFSSLNMkDvGNSQee5EAMrvcU2vl1f4wyfhi6e5zvM8AuAzUefY5apv
ac18fofqj3QoUMYpbd6jNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCALb3eEKf
mJOtZWUhT7GC5ZL4v40N8HmHgW4RvocoIiS6SgHVgy9WqDevpReshfBKwakFZ7TW
p+czW8CYtI1DAAXKAkIAzSM+3FCYtFTDYM4D7PVppafbHYz9auyNtJbqgeamMD92
u7Q+2bD4UKT6NPw6ofXqyJnvNEdp9hnL5ilptNE/akU=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
