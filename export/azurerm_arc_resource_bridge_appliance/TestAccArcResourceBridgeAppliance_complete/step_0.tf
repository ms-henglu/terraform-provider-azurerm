


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-230922053555379561"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-230922053555379561"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEAvQPdUOgFAPp2m/pZv25zd7yDZ8GkYExfYqb8lTpTU9FGFpRyhoTNtMHwlQsy7W8ctDrc/h/d4DW59odR5pNp63q+hrOWDKyBI96V5cXG8HJmQ/IeFKcv9sqt0pq6ErFDcy3psV0WubrilOQRFnFgxp1oTLOi7d/Pdo4AkNha251xl/Z4zHy57e6QW8xsXNxAjCqXMuBwF/YRa22YAKu1RmvDE8F8jY0rz/yj9VaQJA+GLh79u00t9l5S+c+wwXjc3MjLZcdSaF97TF+/pmvVdzOm3L8OfTMSEfy0KUlBR3beFh5w+ON66d1uaLzX7zvWOsQKRhTSSdXsC6pE+1n/wmrmomuz3JXoR1Oj8zHp5URIMhXButyuQwZnFCF8zfKftbIrE+kGxukQRp65Bff56qEH2QWxwC1rdufS2vZVUfPNaE2g2WX62uehRuMlyYApE6cr7cu75lcUIQP3dY1E4FsAb6v70wZB4SMgog6vlUCMWiGzgGAbnxZFNEI5ZjQV5Oom8hOR/3+miL3rsLxnPnHIzv6suWYP6t9p8BObXd5tHPfF9Uf11EihFYKSOzfTFMahWSFrK8Z3S4WogutmFmfFKmbyOaVBzHvGVS04RLw7P7r7iMv57TIKdEAu+cY3Mzo8F6gK9dJtWJ6xT6xk2MLGYG/f+rarimFALfKAVlMCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
