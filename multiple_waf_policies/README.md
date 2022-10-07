# Consolidate Multiple WAF Policies on a single Virtual Server




## Goals
The goal is to create rules so we can, on a single HTTP/HTTPS listener, select a different WAAP Policy based on a specific selector. The selector being: an FQDN, a path, a cookie, a header...




## Why it matters?
For some Public Cloud environments, you may be limit in the number of secondary IP addresses per Network Interface depending on your instance size. In this case, you may want to share a single IP address with multiple applications and therefore configure specific selectors to use the right WAF Policy.

For example, you may want to have, on a listener (on a best match):
- if the FQDN is any of ["www1.f5demo.com", "app1.f5demo.com"] then use the policy **app1**
- if FQDN equals "www2.f5demo.com" then use the policy **app2**
- if the URI path starts with any of ["/restricted", "/admin", "/hr"], then use the policy **restricted**
- and default to **default** the WAF Policy




## Explain the Nuts & Bolts
Behind the scene, the module implements the **"bigip_ltm_policy"** terraform resource. We just added some magic and glitters to make it more human readable. 




## Example in Terraform

Let's first create 4 x Advanced WAF Policies:
- app1
- app2
- restricted
- default

```terraform
resource "bigip_waf_policy" "app1" {
  provider             = bigip.prod
  description          = "WAF Policy for App1"
  name                 = "app1"
  partition            = "Common"
  template_name        = "POLICY_TEMPLATE_RAPID_DEPLOYMENT"
  application_language = "utf-8"
  enforcement_mode     = "blocking"
  server_technologies  = ["Apache Tomcat", "MySQL", "Unix/Linux"]
}

resource "bigip_waf_policy" "app2" {
  provider             = bigip.prod
  description          = "WAF Policy for App2"
  name                 = "app2"
  partition            = "Common"
  template_name        = "POLICY_TEMPLATE_RAPID_DEPLOYMENT"
  application_language = "utf-8"
  enforcement_mode     = "blocking"
  server_technologies  = ["Apache Tomcat", "MySQL", "Unix/Linux", "MongoDB"]
}

resource "bigip_waf_policy" "restricted" {
  provider             = bigip.prod
  description          = "WAF Policy for restricted areas"
  name                 = "restricted"
  partition            = "Common"
  template_name        = "POLICY_TEMPLATE_RAPID_DEPLOYMENT"
  application_language = "utf-8"
  enforcement_mode     = "blocking"
  server_technologies  = ["Apache Tomcat", "MySQL", "Unix/Linux", "MongoDB"]
}

resource "bigip_waf_policy" "default" {
  provider             = bigip.prod
  description          = "desfault WAF Policy"
  name                 = "default"
  partition            = "Common"
  template_name        = "POLICY_TEMPLATE_RAPID_DEPLOYMENT"
  application_language = "utf-8"
  enforcement_mode     = "blocking"
  server_technologies  = ["Apache Tomcat", "MySQL", "Unix/Linux", "MongoDB"]
}
```

Then, call the **multiple_waf_policies** module. Don't forget the explicit dependency of the module to the WAF Policies:

```terraform
module "consolidated_vips" {
  source = "github.com/fchmainy/waf_modules"
  providers = {
    bigip = bigip.prod
  }
  name               = "vs1"
  partition          = "Common"
  rules = [
    {
        name            = "WWW1_App"
        hostname        = ["www1.f5demo.com", "app1.f5demo.com"]
        policy          = bigip_waf_policy.app1.name
    },
    {
        name            = "WWW2_App"
        hostname        = ["www2.f5demo.com"]
        policy          = bigip_waf_policy.app2.name
    },
    {
        name            = "restricted"
        path            = ["/restricted", "/admin", "/hr"]
        policy          = bigip_waf_policy.restricted.name
    }]
  default_policy      = bigip_waf_policy.default.name
  depends_on 		= [bigip_waf_policy.app1, bigip_waf_policy.app2, bigip_waf_policy.restricted, bigip_waf_policy.default]
}
```

Next step is to use the FAST terraform resources to consume the LTM Endpoint for a HTTP/HTTPS L7 application service.
