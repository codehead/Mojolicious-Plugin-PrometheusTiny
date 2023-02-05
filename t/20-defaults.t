use Mojo::Base -strict;
use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

plugin 'PrometheusTiny';

get '/' => sub {
    my $c = shift;
    $c->render(text => 'Hello Mojo!');
};

post '/' => sub {
    my $c = shift;
    $c->render(text => 'Hello Mojo!');
};

my $t = Test::Mojo->new;

for my $i (1 .. 100) {
    $t->get_ok('/')->status_is(200)->content_is('Hello Mojo!');
    $t->post_ok('/' => json => { hello => 'somedata' })
        ->status_is(200)
        ->content_is('Hello Mojo!');
}

$t->get_ok('/metrics')
    ->status_is(200)
    ->content_type_like(qr(^text/plain))
    ->content_like(qr/http_requests_total\{code="200",method="GET",worker="\d+"\} 100/);

$t->get_ok('/metrics')
    ->status_is(200)
    ->content_type_like(qr(^text/plain))
    ->content_like(qr/http_request_duration_seconds_count\{method="GET",worker="\d+"\} 100/);

done_testing();
