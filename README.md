# Puppeteer

#### Table of Contents

1. [Overview](#overview)
1. [Tasks](#tasks)
    * [puppeteer::apply](#puppeteerapply)

## Overview

Run puppet apply as a PE task

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
