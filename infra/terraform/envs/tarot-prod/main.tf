terraform {
  required_version = ">= 1.6.0"
}
module "cosmocrat" {
  # Fill before apply:
  # - tenant: customer slug (e.g. tarot-by-marie)
  # - domain: public hostname (add to module variables when you wire DNS)
  # - tailscale_target + auth key: ephemeral key + device label for the edge host
  # - doppler_* toggles: enable + project slug when secrets sync via Doppler
  source          = "../../cosmocrat-stack"
  tenant          = "tarot-by-marie"
  tailscale_target= "edge-01"
}
