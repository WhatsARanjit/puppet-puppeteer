# Puppeteer

#### Table of Contents

1. [Overview](#overview)
1. [Tasks](#tasks)
    * [puppeteer::apply](#puppeteerapply)
    * [puppeteer::external_fact](#puppeteerexternal_fact)
    * [puppeteer::certificate_info](#puppeteercertificate_info)
    * [puppeteer::features](#puppeteerfeatures)
    * [puppeteer::providers](#puppeteerproviders)

## Overview

A variety of tasks using Puppet.

## Tasks

### puppeteer::apply

Run inline Puppet code

```shell
puppet task run puppeteer::apply --nodes 'node1'  code='notify { $fqdn: }'
```

Run Puppet code from a manifest in noop mode

```shell
puppet task run puppeteer::apply --nodes 'node1'  manifest='/tmp/fqdn.pp' --noop
```

### puppeteer::external_fact

Create a datacenter fact in datacenter.txt

```shell
puppet task run puppeteer::external_fact --nodes 'node1' fact=datacenter value=us-east
```

__NOTE:__ If no file is specified, $fact.txt is used.

Create a role fact in server.yaml

```shell
puppet task run puppeteer::external_fact --nodes 'node1' fact=role value=default file=server.yaml
```

Remove an existing fact from config.json

```shell
puppet task run puppeteer::external_fact --nodes 'node1' fact=repo_server action=remove file=config.json
```

__NOTE__: Keys will be overwritten, not merged.

### puppeteer::certificate_info

Retrieve certificate information

```shell
puppet task run puppeteer::certificate_info --nodes 'node1'
```

...results in:

```shell
Started on node1 ...
Finished on node node1
tte : 5.0 years
issued : 2017-10-03 18:30:27 UTC
issuer : Puppet Enterprise CA generated on puppet2017.3.0.puppetlabs.vm at +2017-09-27 12:03:26 +0000
serial : 5
expires : 2022-10-03 18:30:27 UTC
subject : node1
tte_raw : 156285193.94213384
```

Find certificates that will expire within a specified interval

```
puppet task run puppeteer::certificate_info --nodes 'node1' threshold=6y
```

...results in:

```shell
Started on node1 ...
Failed on node1
Error: Task finished with exit-code 2
threshold : Expiring before 6y!
expires : 2022-10-03 18:30:27 UTC
serial : 5
tte : 5.0 years
issuer : Puppet Enterprise CA generated on puppet2017.3.0.puppetlabs.vm at +2017-09-27 12:03:26 +0000
issued : 2017-10-03 18:30:27 UTC
tte_raw : 156285079.43708673
subject : node1
```

Your `threshold` can be specified as a number followed by a unit from `[s,m,h,d,y]` or
as a parseable time string like `10/20`, `2022-10-20`, or `Oct 20 2022`. See 
[ruby docs](https://ruby-doc.org/stdlib-2.1.9/libdoc/time/rdoc/Time.html#method-c-parse) for more details.
Nodes with certificates due to expire in your specified interval will result in a failure with exit code 2. 
In order to report a success even if the certificate is due to expire in your specified interval, use the
`fail` parameter.

```
puppet task run puppeteer::certificate_info --nodes 'node1' threshold=6y fail=no_fail
```

...results in:

```shell
Started on node1 ...
Finished on node node1
tte : 5.0 years
issued : 2017-10-03 18:30:27 UTC
issuer : Puppet Enterprise CA generated on puppet2017.3.0.puppetlabs.vm at +2017-09-27 12:03:26 +0000
serial : 5
expires : 2022-10-03 18:30:27 UTC
subject : node1
tte_raw : 156270228.94399956
threshold : Expiring before 6y!
=======
### puppeteer::features

Look up the Puppet features on each system.

```shell
puppet task run puppeteer::features --nodes 'node1'
```

### puppeteer::providers

Look up the providers for a given type.

```shell
puppet task run puppeteer::providers --nodes 'node1' type=user
```
