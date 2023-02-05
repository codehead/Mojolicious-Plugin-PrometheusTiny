# NAME

Mojolicious::Plugin::PrometheusTiny - Export metrics using Prometheus::Tiny::Shared

# SYNOPSIS

    # Mojolicious
    $self->plugin('PrometheusTiny');

    # Mojolicious::Lite
    plugin 'PrometheusTiny';

    # Mojolicious::Lite, with custom response buckets (seconds)
    plugin 'Prometheus' => { response_buckets => [qw/4 5 6/] };

    # You can add your own route to do access control
    my $under = app->routes->under('/secret' =>sub {
      my $c = shift;
      return 1 if $c->req->url->to_abs->userinfo eq 'Bender:rocks';
      $c->res->headers->www_authenticate('Basic');
      $c->render(text => 'Authentication required!', status => 401);
      return undef;
    });
    plugin PrometheusTiny => {route => $under};

# DESCRIPTION

[Mojolicious::Plugin::PrometheusTiny](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3APrometheusTiny) is a [Mojolicious](https://metacpan.org/pod/Mojolicious) plugin that exports Prometheus metrics from Mojolicious.
It's based on [Mojolicious::Plugin::Prometheus](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3APrometheus) but uses [Prometheus::Tiny::Shared](https://metacpan.org/pod/Prometheus%3A%3ATiny%3A%3AShared) instead of [Net::Prometheus](https://metacpan.org/pod/Net%3A%3APrometheus).

Default hooks are installed to measure requests response time and count requests by HTTP return code,
with optional labeling of worker PID and HTTP method.
It is easy to add custom metrics and update them right before the metrics are exported.

There is no support for namespaces, subsystems or any other fancy Net::Prometheus features.

# CODE QUALITY NOTICE

This is BETA code which is still subject to change.

# HELPERS

## prometheus

Create further instrumentation into your application by using this helper which gives access to the
 [Prometheus::Tiny::Shared](https://metacpan.org/pod/Prometheus%3A%3ATiny%3A%3AShared) object.
See [Prometheus::Tiny](https://metacpan.org/pod/Prometheus%3A%3ATiny) for usage.

# METHODS

[Mojolicious::Plugin::PrometheusTiny](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3APrometheusTiny) inherits all methods from
[Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious%3A%3APlugin) and implements the following new ones.

## register

    $plugin->register($app, \%config);

Register plugin in [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

`%config` can have:

- route

    [Mojolicious::Routes::Route](https://metacpan.org/pod/Mojolicious%3A%3ARoutes%3A%3ARoute) object to attach the metrics to, defaults to generating a new one for '/'.

    Default: /

- path

    The path to mount the exporter.

    Default: /metrics

- prometheus

    Override the [Prometheus::Tiny::Shared](https://metacpan.org/pod/Prometheus%3A%3ATiny%3A%3AShared) object.
     The default is a new singleton instance of [Prometheus::Tiny::Shared](https://metacpan.org/pod/Prometheus%3A%3ATiny%3A%3AShared).

- request\_buckets

    Override buckets for request sizes histogram.

    Default: `[ 1, 10, 100, 1_000, 10_000, 50_000, 100_000, 500_000, 1_000_000 ]`

- response\_buckets

    Override buckets for response sizes histogram.

    Default: `[ 1, 10, 100, 1_000, 10_000, 50_000, 100_000, 500_000, 1_000_000 ]`

- duration\_buckets

    Override buckets for request duration histogram.

    Default: `[1..10, 20, 30, 60, 120, 300, 600, 1_200, 3_600, 6_000, 12_000]`

- worker\_label

    Label metrics by worker PID, which might increase significantly the number of Prometheus time series.

    Default: true

- method\_label

    Label metrics by HTTP method, which might increase significantly the number of Prometheus time series.

    Default: true

- setup

    Coderef to be executed during setup. Receives as arguments Application and Prometheus instances.
     It can be used to declare and/or initialize new metrics.

            setup  => sub($app, $p) {
                $p->declare('mojo_random',
                    type => 'gauge',
                    help => "Custom prometheus gauge"
                );
            }

- update

    Coderef to be executed right before invoking exporter action configured in `path`.
     Receives as arguments Controller and Prometheus instances.

        update => sub($c, $p) {
            $p->set(mojo_random => rand(100));
        }

# METRICS

This plugin exposes

- `http_requests_total`, request counter partitioned over HTTP method and HTTP response code
- `http_request_duration_seconds`, request duration histogram partitioned over HTTP method
- `http_request_size_bytes`, request size histogram partitioned over HTTP method
- `http_response_size_bytes`, response size histogram partitioned over HTTP method

# TO DO

- Add optional [Net::Prometheus::ProcessCollector](https://metacpan.org/pod/Net%3A%3APrometheus%3A%3AProcessCollector)-like process metrics.

# AUTHOR

Javier Arturo Rodriguez

A significant part of this code has been ripped off [Mojolicious::Plugin::Prometheus](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3APrometheus) written by Vidar Tyldum

# COPYRIGHT AND LICENSE

Copyright (c) 2023 by Javier Arturo Rodriguez.

This program is free software, you can redistribute it and/or modify it under the terms of the Artistic License version 2.0.

# SEE ALSO

[Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious%3A%3AGuides), [https://mojolicious.org](https://mojolicious.org),
 [Mojolicious::Plugin::Prometheus](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3APrometheus),  [Prometheus::Tiny](https://metacpan.org/pod/Prometheus%3A%3ATiny), [Prometheus::Tiny::Shared](https://metacpan.org/pod/Prometheus%3A%3ATiny%3A%3AShared).
