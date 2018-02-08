# LitmusPaper

LitmusPaper is a backend health tester for Highly Available (HA) services.

[![Build Status](https://secure.travis-ci.org/braintree/litmus_paper.png)](http://travis-ci.org/braintree/litmus_paper)

## Installation

Add this line to your application's Gemfile:

    gem 'litmus_paper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install litmus_paper

## Overview

Litmus Paper reports health for each service on a node (like a server, vm, or container) on a 0-100 scale. Health is computed by aggregating the values returned from running various subchecks. Health information can be queried through a REST API for consumption by other services (like load balancers or monitoring systems), or queried on the command line.

There are two classes of subchecks: Dependencies and Metrics. Dependencies report either 0 or 100 health, and aggregate such that if any dependency is not 100 the whole service is down. Metrics report health on a scale from 0-100 and aggregate as averages based on their weight.

You can also force a service to report a health value on a host.
Forcing a service up makes it report a health of 100, regardless of the measured health.
Forcing a service down makes it report a health of 0.
Forcing a service's health to a value between 0 and 100 places a ceiling on its health. The service will report the lower of the measured health or the forced health value.

Force downs take precedence, followed by force ups, and finally force healths. If you specify both a force up and a force down, the service will report 0 health. If you specify a force up and a force health, the force health will be ignored and the service will report 100 health.

Using litmus-agent-check, Litmus can also output health information in haproxy agent check format.

## Usage

### Running Litmus Paper

Start the process under unicorn with `/usr/bin/litmus --unicorn-config <path_to_unicorn_conf>`. In the unicorn config file, set the number of worker processes, the pid, and the working directory. See the [unicorn documentation](https://bogomips.org/unicorn/Unicorn/Configurator.html) for the config format. There are a few command line options:

```
Usage: litmus [options]

    -b, --binding=ip                 Binds Litmus to the specified ip.
                                     Default: 0.0.0.0
    -d, --daemon                     Make server run as a Daemon.
    -p, --port=port                  Listen Port
    -c, --unicorn-config=config      Unicorn Config

    -h, --help                       Show this help message.
```

For HAProxy agent checks, run `/usr/bin/litmus-agent-check`. See the "HAProxy Agent Check Configuration" section below for a full list of options.

### Global configuration

Example:

```
# /etc/litmus.conf

include_files "litmus.d/*.conf"

port 80

data_directory "/litmus"
```

Available fields:
- include_files: Tells Litmus to load health check configurations from a path.
- port: Port Litmus unicorn server will listen on, defaults to 9292.
- data_directory: Where to store force down, up, and health files. Defaults to "/etc/litmus".
- cache_location: Where to store cached health information, defaults to "/run/shm".
- cache_ttl: Time to live in seconds for cached health check values, defaults to -1.

### Service health check configuration

To add services and health checks, Litmus Paper loads configurations written in ruby. Suppose you're writing a health check for a web application. You might start with a simple check to report if the server is responding at all:

```ruby
# /etc/litmus.d/myapp.conf
service "myapp" do |s|
  s.depends Dependency::HTTP, "https://localhost/heartbeat", :method => "GET", :ca_file => "/etc/ssl/certs/ca-certificates.crt"
end
```

Maybe you also want to balance traffic based on CPU load:

```ruby
# /etc/litmus.d/myapp.conf
service "myapp" do |s|
  s.depends Dependency::HTTP, "https://localhost/heartbeat", :method => "GET", :ca_file => "/etc/ssl/certs/ca-certificates.crt"
  s.measure_health Metric::CPULoad, :weight => 100
end
```

Once you've finished adding checks, restart litmus paper to pick up the new service.

Here are all the types of checks currently implemented:

- `Dependency::HTTP`: Checks HTTP 200 response from a URL.
  * url
  * method (defaults to get)
  * ca_file (defaults to nil)
  * timeout (defaults to 2s)

- `Dependency::TCP`: Checks successful completion of a TCP handshake with an address.
  * ip
  * port
  * input_data (defaults to nil)
  * expected_output (defaults to nil)
  * timeout (defaults to 2s)

- `Dependency::FileContents`: Checks whether the contents of a file match a string or regex.
  * path
  * regex
  * timeout (defaults to 5s)

- `Dependency::Script`: Checks whether the output of a command matches a string or regex.
  * command
  * timeout (defaults to 5s)

- `Metric::ConstantMetric`: A dummy metric that always reports a constant.
  * weight (0-100)

- `Metric::CPULoad`: Normalizes CPU load to a value between 1-100 and inverts it, so higher numbers mean less load and lower numbers mean more. Final health is weighted against other checks by `:weight`. The lower bound of 1 ensures that nodes will not leave the cluster solely based on CPU load. An example of how allowing 0 can cause problems: If one node has 4 CPUs and a load of 4 with CPU usage weighted at 100, it will report its health as 0, and all traffic will be shifted towards other nodes. These nodes in turn hit 100% CPU usage and report 0 health, causing a cascade of exiting nodes that shuts down the service.
  * weight (1-100)

- `Metric::InternetHealth`: Checks connectivity across a set of hosts and computes a weight based on how many are reachable. Helpful if you want to check outbound connectivity through multiple ISPs.
  * weight (0-100)
  * hosts
  * timeout (defaults to 5s)

- `Metric::Script`: Runs a script to obtain a health from 0-100. This is helpful for customized metrics.
  * command
  * weight (0-100)
  * timeout (defaults to 5s)

- `Metric::BigBrotherService`: Used in conjunction with [Big Brother](https://github.com/braintree/big_brother), reports health based on the overall health of another load balanced service.
  * service

### HAProxy agent check configuration

Litmus paper can also report health checks in HAProxy agent check format. The agent check functionality takes the health data from a service health check, and exposes it on a different port in the format HAProxy expects.

There are no additional configuration files for the agent check, since all options are specified on the command line. Services are configured as normal litmus services as described above.

```
Usage: litmus-agent-check [options]
    -s, --service SERVICE:PORT,...   agent-check service to port mappings
    -c, --config CONFIG              Path to litmus paper config file
    -p, --pid-file PID_FILE          Where to write the pid
    -w, --workers WORKERS            Number of worker processes
    -D, --daemonize                  Daemonize the process
    -h, --help                       Help text
```

The service:port argument means that the server will expose the data from the litmus check for `service` on `port` in HAProxy agent check format. For example, if you wanted to serve status information about `myapp` on port `8080`, and already had a service config for it, you'd pass `-s myapp:8080`.

On the HAProxy server, add `agent-check agent-port 8080 agent-inter <seconds>s` to the config line for each server listed for that backend. This tells HAProxy to query port 8080 on the backend every `<seconds>` seconds for health information. See the [HAProxy agent check documentation](https://cbonte.github.io/haproxy-dconv/1.8/configuration.html#5.2-agent-check) for more details.

### REST API

The REST API is the main way other services should interact with Litmus. For routes that take parameters, pass them as form parameters in the request body.

- /
  * GET: Returns table with status of each service.

		Litmus Paper 1.1.1

		 Service    │ Reported │ Measured │ Health
		 Name       │ Health   │ Health   │ Forced?
		────────────┴──────────┴──────────┴─────────
		 myapp            0        100      Yes, Reason: testing
		 myotherapp      72         72      No

- /down
  * POST: Creates a global force down. Parameters: reason => reason for the force down.
  * DELETE: Deletes global force down, if one is in place. Any service-specific force downs remain in effect.

- /up
  * POST: Creates a global force up. Parameters: reason => reason for the force up.
  * DELETE: Deletes global force up, if one is in place. Any service-specific force ups remain in effect.

- /health
  * POST: Creates a global force health. Parameters: reason => reason for the force health, health => health to force to.
  * DELETE: Deletes global force health, if one is in place. Any service-specific force healths remain in effect.

- /`<service>`/status
  * GET: Returns a detailed status output for `<service>`, including all the subchecks. This output easier to parse than the output from GET /. Also sets X-Health and X-Health-Forced headers in the response.

    ```
    Health: 82
    Measured Health: 82
    Dependency::HTTP(http://localhost/heartbeat): OK
    Metric::CPULoad(100): 82
    ```

- /`<service>`/down
  * POST: Creates a force down just for `<service>`. Parameters: reason => reason for the force down.
  * DELETE: Deletes force down for `<service>`, if one is in place. Global force downs remain in effect.

- /`<service>`/up
  * POST: Creates a force up just for `<service>`. Parameters: reason => reason for the force up.
  * DELETE: Deletes force up for `<service>`, if one is in place. Global force ups remain in effect.

- /`<service>`/health
  * POST: Creates a force health just for `<service>`. Parameters: reason => reason for the force health, health => health to force to.
  * DELETE: Deletes force health for `<service>`, if one is in place. Global force healths remain in effect.

### Litmusctl

There is also a CLI included called `litmusctl`.

This has the same functionality as the rest API:
- `litmusctl list` = `GET /`
- `litmusctl status <service>` = `GET /<service>/status`
- `litmusctl force (down|up|health) [health] [-r REASON]` = `POST /(down|up|health)`
- `litmusctl force (down|up|health) [health] <service> [-r REASON]` = `POST /<service>/(down|up|health)`
- `litmusctl force (down|up|health) -d` = `DELETE /(down|up|health)`
- `litmusctl force (down|up|health) <service> -d` = `DELETE /<service>/(down|up|health)`

## Tests

Run tests using `rake`. The default task runs all the tests.

## Releasing

    $ ./release

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

1. Accept configuration in either YAML or ruby format.
2. Improve concurrency model, with a health-check process and a responder process.
3. Improve concurrency of agent-check daemon.
4. Provide a Vagrant or Docker configuration for demo and testing purposes.
