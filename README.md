# Puppeteer

#### Table of Contents

1. [Overview](#overview)
1. [Tasks](#tasks)
    * [puppeteer::apply](#puppeteerapply)
    * [puppeteer::external_fact](#puppeteerexternal_fact)

## Overview

A variety of tasks using Puppet.

## Tasks

### puppeteer::apply

Run inline Puppet code

```shell
# puppet task run puppeteer::apply --nodes 'node1'  code='notify { $fqdn: }'
```

Run Puppet code from a manifest in noop mode

```shell
# puppet task run puppeteer::apply --nodes 'node1'  manifest='/tmp/fqdn.pp' --noop
```
### puppeteer::external_fact

Create a datacenter fact in datacenter.txt

```shell
puppet task run puppeteer::external_fact --nodes 'node1' fact=datacenter value=us-east
```

Create a role fact in server.yaml

```shell
puppet task run puppeteer::external_fact --nodes 'node1' fact=role value=default file=server.yaml
```

Remove an existing fact from config.json

```shell
puppet task run puppeteer::external_fact --nodes 'node1' fact=repo_server remove=true file=config.json
```

__NOTE__: Keys will be overwritten, not merged.
