
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-240105063258996633"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap7weja02xsu"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yNDAxMDUwNjMyNTlaFw0yNDA3MDMwNjMyNTlaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQA4EOtrHzUDCjHBUvVi8y+pYtj5GOy
1bTQBxMty87nWAr0HJ/4qHEpgIzXVdrer6I+9VlVYTuUoIj2gfRgACM7x9IBm2xn
ltb5uius2Qf6ozg01bdfJGgqzDanR/5e6WBTL0ZzpTNl3t9FuT28I+FTdrUMMrfZ
1jsDhQQKFKxOcpFOeLCjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAIL4JgWZ
49AUhfTjVEULRqU6FKdo/Pfpm0WYUi2C/Smawpm4tE1XJn6NO/+UEit4G6JFaso5
H5ljcChikUMK85z1AkIBE4z0KsHK64uuccGkOE/6tUdgeEgJb337okPxTl7asHxK
9FRIgIAF+jbTK/GHooe5JgIWu4ElCX6ngjgajM7bbWA=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }

  lifecycle {
    ignore_changes = [
      "open_enclave_policy_base64",
      "sgx_enclave_policy_base64",
      "tpm_policy_base64",
      "sev_snp_policy_base64",
    ]
  }
}
