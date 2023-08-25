
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230825024026074980"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap8x6q9btxds"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA4MjUwMjQwMjZaFw0yNDAyMjEwMjQwMjZaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQAZQuj+En7TEjTMMQLeIJcZAg5+3AU
Cl7r1yrhIt33h7ZZ9Mz6moiuu4MZcL1dz70Hj5O6nNdYzqCaL8oji3y4pnAACPXD
r04ajJBYpFyfnk++7ihnVP6SXDxP/oQV2zt0DzsjU7LQQnWxkp+f7BTRlH1hqxT/
tX63B1stl/YwjjO7gfWjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAVtsqy27
2nn3O1GDhGEI5+o3X8xDEjHV69cSpv0EhycG61B6AYCJMDAk7c3OLEgL736ZmyMZ
xn0MuFkDNhC7qEWZAkIBauQQeylODsiIgpEiSWX6587XcPkWBNZWiMU8TRPPUmV2
OnkhX5wuoyCPk0lqxTsaXoSdvzgJkww27OqRunEwrAs=
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
