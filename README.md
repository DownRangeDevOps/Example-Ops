# Example-Co Operations

***NOTE:*** This is a work in progress, sorry for the mess 🧹 😅

## Synopsis

An example project to bootstrap a GCP organization and prepare it to host the
***blazingly fast™*** infrastructure for my Start-Up™.

## The pitch

Okay Zoomers, listen up! This is the latest grinding hustle in the
Start-Up™ space. I'm cooking up the next big disruptive app guaranteed to 10x
our productivity leveraging cutting-edge synergies. The name? Still working on
it - but you can bet your NFTs it'll be one vowel shorter!

Strap in for the moon mission as I unleash my big brain 5D chess moves on the
tech landscape. Disruption inbound!

## On a serious note

My plan for this project is to eventually™ use it to host a small, cost
efficient infrastructure that is well maintained. Since this is for personal use,
I'll eventually pair it down to a GCP organization that can be created quickly
when the demonstration environment is required, and torn down after. Eventually™
I'll use a piece of it to host the portfolio site that I plan to - eventually™ -
create.

The current state is a bit messy, but one has to start somewhere when planning
the moon mission. Its origin was a demo project that I was asked to create, and
I had a three day window to complete it. So, there's quite a few bits that I had
to leave as is being that I was in GSD™ mode. As I get time I'll - eventually™ -
clean it up.

## Where we're at now

### Terraform

* Direnv
  * Auto-source `.envrc` files to set up cascading env within
  `terraform/environment/<environment>`
  * Drives TF vars that are environment specific
  * Configures back-end (GCP Cloud Storage bucket name)
* Symlinks
  * Leverage symlinks to drive common TF variable inheritance
  * `locals.<scope>.tf`: shared locals blocks
  * `providers.<scope>.tf`: shared provider blocks
  * `variables.<scope>.tf`: shared variables
* GCP org bootstrap
  * Create org service account and set up for impersonation
  * Create billing account
  * Create folder structure
* Staging environment
* App module:
  * GCR instances for back-end services
  * Cloud Storage buckets for static assets
  * Networking rules for a global load balancer
  * CDN rules for static content
  * HTTP redirection and SSL termination
* Project module:
  * Create project
  * Create service accounts
  * Set IAM roles
* VPC:
  * Create VPC
  * Create basic network
  * Create facilities for appropriate firewall to be used eventually™
* OIDC:
  * Create workload provider/pool(s)
  * Set up workload identities to enable Github oAuth
  * Note: no secrets needed!
* Sanitize labels:
  * Because the face you will make when you when you realize TF is failing with
    anonymous errors because GCP labels must be [a-z-_] is not attractive

### GitHub actions

* Dagger.io: all your CI/CD with none of the YAML
  * By my scientific calculations, Dagger is ***blazingly fast™***
  * Dagger SDK allows pipeline creation in your GP language of choice
  * As long as that language is Go or Python
  * Or typescript, I'm sorry, or congratulation!
* Action to sanity check changed Terraform modules
* Force `terraform fmt -recursive`
* Builds docker images asynchronously
* Pushes image assets, auto-tagging included, to GCP Artifact Store
* Deploys new revisions to GCR/Bucket (you remembered your cache busting, right?)
* Actually caches NPM modules, the heaviest thing in the known universe
* Allows you to implement logging (like anybody has use for that!)

### Coming soon™

* ArgoCD + Atlantis workflow for final Terraform deployment
* Helm charts for app and service definitions
* Kubernetes cluster for ArgoCD/Atlantis/Services
* DataDog for observeability
* Security scanning with Trivy
* K8s runtime security with Falco
* More Dagger.io!
* A website, so there is actually something to host 🤣

### Check back for updates!

They will be ***Coming Soon™®©*** *1979,1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023*
