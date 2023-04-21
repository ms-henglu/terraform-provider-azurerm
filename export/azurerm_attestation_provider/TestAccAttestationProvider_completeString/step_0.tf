

// TODO: switch to using regular regions when this is supported
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-attestation-230421021654381892"
  location = "uksouth"
}


resource "azurerm_attestation_provider" "test" {
  name                = "acctestapw7qqrtie4k"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  policy_signing_certificate_data = <<EOT
-----BEGIN CERTIFICATE-----
MIIBzDCCAS2gAwIBAgIBATAKBggqhkjOPQQDBDAQMQ4wDAYDVQQKEwVFTkNPTTAe
Fw0yMzA0MjEwMjE2NTRaFw0yMzEwMTgwMjE2NTRaMBAxDjAMBgNVBAoTBUVOQ09N
MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQB22/Yq+sdcyoFhPjVTLvJmub51xF8
jFs3t4BS2qrcfihF3irZciVVmO6fcR42xpqaueiSmLtNGoeCrgdz9PxqbFoA4ZDe
9P6F/TXvf084X0+2M543e1NVl1rWPfEaTjf6K+h125IMsNuMJ6cPVv6vgTotnGZA
9XUJlQCX4+jmrNmwTESjNTAzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
BgEFBQcDATAMBgNVHRMBAf8EAjAAMAoGCCqGSM49BAMEA4GMADCBiAJCAOCDtwNl
2aXMhcgJdysMPy/DUBJoGgXzvwzKly7XhYIOUM2HuGnPa4UbNh48/Ju6A9IahN4p
MMx46BFkXDMnEgteAkIBMR1VYvl3c+jeAEljTzVkSafwc8tdKXHhNNNF0sbMpbq4
5F/+IDqlX86In3wv9PZR4XOCSY2/omVV+dXTz3DDGW4=
-----END CERTIFICATE-----

EOT

  tags = {
    ENV = "Test"
  }
}
