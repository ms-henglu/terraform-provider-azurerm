
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-240112223935967019"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapx0pjaseaug"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIByzCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yNDAxMTIyMjM5MzVaFw0yNDA3MTAyMjM5MzVaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBHfvNzLe0FlaQk040SHuc4hKSUkSH
sDJqCu0CIeJlK7pkoMbiUghln5CroCdupNEWCEYeNZK2k/xTHSILgvMbSAwBB6gG
XFFX60TUz4pDXB5nZ3FNqzFVX8L5Rp5BAlrRkw4DDjyY3GHHt5R1PxPyu93Y8PFo
gFrN11TqplPXUMGOETqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GLADCBhwJCAYAorkBN
EVOrRke58uw1nGhdGj51hrgtZWPCZPDtzstscY3TKoLGlZN+7+KoeI5DmKM5OkTT
I7SAiVy6sV5VojIMAkEYQ1k7ZERQhlOqa3A4x/e0C9jCj4mpwB872NYUWB8gvEDu
6qt5ejEBEgd9tBTBhrz83dboXPu5zr/zdtNDzcZUCA==
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
