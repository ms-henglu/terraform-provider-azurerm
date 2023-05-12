
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003341170000"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230512003341170000"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_global_schema" "test" {
  schema_id           = "accetestSchema-230512003341170000"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  type                = "xml"
  value               = <<XML
    <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:tns="http://tempuri.org/PurchaseOrderSchema.xsd" targetNamespace="http://tempuri.org/PurchaseOrderSchema.xsd" elementFormDefault="qualified">
    <xsd:element name="PurchaseOrder" type="tns:PurchaseOrderType"/>
    <xsd:complexType name="PurchaseOrderType">
        <xsd:sequence>
            <xsd:element name="ShipTo" type="tns:USAddress" maxOccurs="2"/>
            <xsd:element name="BillTo" type="tns:USAddress"/>
        </xsd:sequence>
        <xsd:attribute name="OrderDate" type="xsd:date"/>
    </xsd:complexType>
    <xsd:complexType name="USAddress">
        <xsd:sequence>
            <xsd:element name="name" type="xsd:string"/>
            <xsd:element name="street" type="xsd:string"/>
            <xsd:element name="city" type="xsd:string"/>
            <xsd:element name="state" type="xsd:string"/>
            <xsd:element name="zip" type="xsd:integer"/>
        </xsd:sequence>
        <xsd:attribute name="country" type="xsd:NMTOKEN" fixed="US"/>
    </xsd:complexType>
</xsd:schema>
XML
}
