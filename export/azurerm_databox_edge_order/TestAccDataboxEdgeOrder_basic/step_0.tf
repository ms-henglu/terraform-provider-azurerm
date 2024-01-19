

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databoxedge-240119021848001565"
  location = "eastus"
}

resource "azurerm_databox_edge_device" "test" {
  name                = "acctest-dd-80pvc"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku_name = "EdgeP_Base-Standard"
}


resource "azurerm_databox_edge_order" "test" {
  resource_group_name = azurerm_resource_group.test.name
  device_name         = azurerm_databox_edge_device.test.name

  contact {
    name         = "TerraForm Test"
    emails       = ["creator4983@FlynnsArcade.com"]
    company_name = "Microsoft"
    phone_number = "425-882-8080"
  }

  shipment_address {
    address     = ["One Microsoft Way"]
    city        = "Redmond"
    postal_code = "98052"
    state       = "WA"
    country     = "United States"
  }
}
