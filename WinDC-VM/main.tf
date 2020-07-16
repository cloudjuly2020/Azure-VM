provider "azurerm" {
  features{}
}


# Create a resource group
resource "azurerm_resource_group" "group" {
  name     = "Azure"
  location = "west Europe"
}

resource "azurerm_availability_set" "DemoAset" {
  name                = "DemoAset"
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "sl"
  resource_group_name = azurerm_resource_group.group.name
  location            = "west Europe"
  address_space       = ["10.0.0.0/16"]
}

 resource "azurerm_subnet" "subnet" { 
   name                 = "Internal" 
   resource_group_name  = azurerm_resource_group.group.name 
   virtual_network_name = azurerm_virtual_network.example.name 
   address_prefix       = "10.0.1.0/24" 
 } 

 resource "azurerm_public_ip" "myvm1publicip" { 
   name                = "pip1" 
   location            = "west Europe" 
   resource_group_name = azurerm_resource_group.group.name 
   allocation_method   = "Dynamic" 
   sku                 = "Basic" 
 } 

 resource "azurerm_network_interface" "myvm1nic" { 
   name                = "myvm1-nic" 
   location            = "west Europe" 
   resource_group_name = azurerm_resource_group.group.name 

   ip_configuration { 
     name                          = "ipconfig1" 
     subnet_id                     = azurerm_subnet.subnet.id 
     private_ip_address_allocation = "Dynamic" 
   } 
 } 

 resource "azurerm_windows_virtual_machine" "example" { 
   name                  = "myvm1"   
   location              = "west Europe" 
   resource_group_name   = azurerm_resource_group.group.name 
   network_interface_ids = [ azurerm_network_interface.myvm1nic.id ] 
   size                  = "Standard_B1s" 
   admin_username        = "adminuser" 
   admin_password        = "Password123!" 
   availability_set_id   = azurerm_availability_set.DemoAset.id

   source_image_reference { 
     publisher = "MicrosoftWindowsServer" 
     offer     = "WindowsServer" 
     sku       = "2019-Datacenter" 
     version   = "latest" 
   } 

   os_disk { 
     caching              = "ReadWrite" 
     storage_account_type = "Standard_LRS" 
   } 
 }