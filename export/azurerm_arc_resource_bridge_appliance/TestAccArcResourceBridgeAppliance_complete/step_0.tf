


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-230922060549155670"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-230922060549155670"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEAzVmrkArWdm3yr+swHpjHWAjaEaxFr1KQAXcig2n7R98Jq7XfNJ7QisJHl7Y9GgAhugDOwVYjwOTmiUIUkVKJiwxSuibqnX/js6mGGHW3UvrinmMF4a58BFpWRQ7RAwFvSKZ0HAftgt3Qj4W5NQqpN1TD+TpxUa7Su13WM4BqlX8LwLRCB3oFpsOnDVK75FeAcskBJJ0H4xi0ppZFqyzZoBd1v/JgIhSKuO2Dfl0eykAqa6QT7QBEBp3uh3g11FpPanMbNresIvV7lKNGSDbVchKryI2vuFOE/azjpc5KTafWtCrYZQz++IWQPxiWeanQuKL1RI+USsdJFUMCUjwN19J7HWXgtfCr4H55095lJr1h1x6nHEgl6yi0GUja9zvI80HO/ILEGkzAoCpy5EUNB0/Ig/FxTnf9jW4iECX4VUaPIm4s1oHOj4W8NmfHMuiq+AAK808NzVYRCPIYHAqXLJkNMspG5v7tNkU3wImkNKpDv8eeHROUTwikdwF5ZqFgPR6rDfqVbQ9ZL1Uw9Es7cVNFV5/dQCjmIomq5k1hADKxzzC3bLiZqYVfhuWSih6Rqq/EeD5QDRXnGzSOLZp5KFuGNhQCiRcLcHEu/GBL/LnD51zVpr8Fsm326+XvhEKWLPRgmKJcldKm3J281W5jnchB2HaHRoxjnSgCmgybywsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
