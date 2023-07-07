
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230707003318124638"
  location = "westus"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestap6rllj4h898"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA3MDcwMDMzMThaFw0yNDAxMDMwMDMzMThaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBVX7PJq85Tt4oucNhCt653n5kxi0U
6cDtG5a3h43G8CRC8K+FYVqSkjSSzAAqIW2f68zjjth9jBC5+Er/iof1NUoAoSLS
5OGxByQEUp1giQ2Jzs1NZ85Hn19NYeeaEY/NTAdy3srXSYw4V6Br//bhdKWCkmBB
s8BeOJVWwez0dockgNqjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCARHj/gnF
X+40oSZssRhURKqVPov32A3ybkq0ky7Tq4+STpetAHZQm6/toomQVeY6L3URGvBz
qa0Z7vssfUUmNToUAkIAt16GPCbe23/MpaO3bkORu4SbJqad/FAg2fZzj0E7YOvY
uJ8Y+WQhDBBABjaMNFj46KsImSkvrqApYx2KLUPcwto=
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
