#!/usr/bin/env perl

use Mojolicious::Lite;
use 5.020;
use lib 'lib';
plugin 'AssetPack';

app->asset('main.css' => 'sprites:sprite' );

get '/' => 'index';

app->start;
__DATA__

@@ index.html.ep

test
%= asset 'main.css';
test 42
