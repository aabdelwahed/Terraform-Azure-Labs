# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "b15xxxx-xxxx-xxxx-xxxx-xxxx" # Replace with your subscription ID
  tenant_id       = "0616xxxx-xxxx-xxxx-xxxx-xxxx" # Replace with your tenant ID
}

# Create a Resource Group
resource "azurerm_resource_group" "linux_rg" {
  name     = "LinuxRG"
  location = "East US" # Replace with your preferred Azure region
}

# Create a Virtual Network
resource "azurerm_virtual_network" "linux_vnet" {
  name                = "LinuxVNet"
  location            = azurerm_resource_group.linux_rg.location
  resource_group_name = azurerm_resource_group.linux_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Create a Subnet
resource "azurerm_subnet" "linux_subnet" {
  name                 = "LinuxSubnet"
  resource_group_name  = azurerm_resource_group.linux_rg.name
  virtual_network_name = azurerm_virtual_network.linux_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a Public IP with Static Allocation
resource "azurerm_public_ip" "linux_public_ip" {
  name                = "LinuxPublicIP"
  location            = azurerm_resource_group.linux_rg.location
  resource_group_name = azurerm_resource_group.linux_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a Network Interface
resource "azurerm_network_interface" "linux_nic" {
  name                = "LinuxNIC"
  location            = azurerm_resource_group.linux_rg.location
  resource_group_name = azurerm_resource_group.linux_rg.name

  ip_configuration {
    name                          = "LinuxIPConfig"
    subnet_id                     = azurerm_subnet.linux_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_public_ip.id
  }
}

# Create a Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "Ubuntu_linux_vm" {
  name                = "UbuntuLinuxVM"
  location            = azurerm_resource_group.linux_rg.location
  resource_group_name = azurerm_resource_group.linux_rg.name
  size                = "Standard_B1ls"

  admin_username = "azureuser"
  admin_password = "SecurePassword123!" # Replace with your secure password

  network_interface_ids = [
    azurerm_network_interface.linux_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "ubuntu-pro"
    version   = "latest"
  }

  disable_password_authentication = false
}
