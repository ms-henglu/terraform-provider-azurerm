
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mapp-240119025325853704"
  location = "West Europe"
}

resource "azurerm_marketplace_agreement" "test" {
  publisher = "cisco"
  offer     = "cisco-meraki-vmx"
  plan      = "cisco-meraki-vmx"
}

resource "azurerm_managed_application" "test" {
  name                        = "acctestManagedApp240119025325853704"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  kind                        = "MarketPlace"
  managed_resource_group_name = "infraGroup240119025325853704"

  plan {
    name      = azurerm_marketplace_agreement.test.plan
    product   = azurerm_marketplace_agreement.test.offer
    publisher = azurerm_marketplace_agreement.test.publisher
    version   = "15.37.1"
  }

  parameter_values = jsonencode({
    zone = {
      value = "0"
    },
    location = {
      value = azurerm_resource_group.test.location
    },
    merakiAuthToken = {
      value = "f451adfb-d00b-4612-8799-b29294217d4a"
    },
    subnetAddressPrefix = {
      value = "10.0.0.0/24"
    },
    subnetName = {
      value = "acctestSubnet"
    },
    virtualMachineSize = {
      value = "Standard_DS12_v2"
    },
    virtualNetworkAddressPrefix = {
      value = "10.0.0.0/16"
    },
    virtualNetworkName = {
      value = "acctestVnet"
    },
    virtualNetworkNewOrExisting = {
      value = "new"
    },
    virtualNetworkResourceGroup = {
      value = "acctestVnetRg"
    },
    vmName = {
      value = "acctestVM"
    }
  })
}
