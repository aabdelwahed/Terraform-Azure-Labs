# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "b15d7xxx-xxxx-xxxxx-xxxx-xxxxx" # Replace with your subscription ID
  tenant_id       = "0616xxxx-xxxx-xxxxx-xxxxx-xxxxx" # Replace with your tenant ID
}

# Create a Resource Group
resource "azurerm_resource_group" "test" {
  name     = "Terraform-Test-RG"
  location = "East US" # Choose your desired Azure region
}
