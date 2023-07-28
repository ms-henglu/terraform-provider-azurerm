
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230728031736981117"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapch8kbaxdej"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA3MjgwMzE3MzZaFw0yNDAxMjQwMzE3MzZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBLxDrgO+J7B2puxc7eQSGdsTrASiy
TBf6uC+q59j+Ljm5dCFZNl38Yjw8aFQl2OgXgIOTin3fTWqxa9bafrg9cB4AdVyq
lwHQeXzqWRUtcn9jdEDT5jGz44XOMg6ICpzirMr6+5zNYOmmBx/yiM0lDnaj/On4
DuYe0ZnJ5BxaLCqmw5ejNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAQYNekHQ
fBqs/DDOCJ+ZnNF2gI7yVc4HAAhAzblBt5hhoN1L/kwqtrOeFDyOEy4vknxv3DEm
zazTEVtNnmRuWZmAAkIBJ6obKMNJZH1/Af7N9khvtChfxy8YMVI54Fmdlpiw518j
d3jdGBzOfLudMgHxrFZdznD82Nik2AzXOUkP7h653Ss=
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
