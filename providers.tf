provider "alicloud" {
  # Default provider configuration (optional)
  region = "cn-beijing"  # Default region; adjust as needed
}

provider "alicloud" {
  alias  = "beijing"
  region = "cn-beijing"
}

provider "alicloud" {
  alias  = "hangzhou"
  region = "cn-hangzhou"
}

provider "alicloud" {
  alias  = "shanghai"
  region = "cn-shanghai"
}
