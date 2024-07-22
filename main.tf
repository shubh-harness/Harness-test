terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 2.0"
    }
  }
}

provider "http" {}

data "http" "example" {
  url = "https://jsonplaceholder.typicode.com/posts/1"
}

output "response_body" {
  value = jsondecode(data.http.example.response_body)
}
