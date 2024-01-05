
provider "azurerm" {
  features {}
}

data "azurerm_platform_image" "test" {
  location  = "West Europe"
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063504031244"
  location = "West Europe"
}


resource "azurerm_managed_disk" "test" {
  name                   = "acctestd-240105063504031244"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  os_type                = "Linux"
  hyper_v_generation     = "V2"
  create_option          = "FromImage"
  image_reference_id     = data.azurerm_platform_image.test.id
  storage_account_type   = "Standard_LRS"
  trusted_launch_enabled = true
}
