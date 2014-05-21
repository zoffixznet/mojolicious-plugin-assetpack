#!/usr/bin/env perl
use Mojolicious::Lite;

plugin 'Bootstrap3' => css => [], js => [], jquery => 0;
plugin 'PODRenderer';

$ENV{SASS_PATH} = Mojolicious::Plugin::Bootstrap3->asset_path('sass');

app->asset(
  'presentation.css' => qw(
    css/impress-demo.css
    sass/presentation.scss
    sass/bootstrap.scss
  )
);

app->asset(
  'presentation.js' => qw(
    js/impress.js
  )
);

get '/' => sub {
  my $self = shift;
  # ...
}, 'presentation';

app->helper(
  pre => sub {
    my $content = pop;
    my($self, %args) = @_;

    $self->tag(
      'pre',
      class => join(' ', 'text-left', grep { $_ } delete $args{class}),
      %args,
      Mojo::ByteStream->new($content->()),
    );
  },
);

app->helper(
  slide => sub {
    my $content = pop;
    my($self, $name, %args) = @_;
    my $n = $self->stash->{n} || 0;
    my $p = $self->stash->{p} || 0;

    $self->stash->{p}++ unless delete $args{stop};
    $self->stash->{n}++;
    $args{"data-$_"} = delete $args{$_} for grep { $args{$_} } qw( y z scale );

    $self->tag('div',
      id => $name,
      class => join(' ', 'step', grep { $_ } delete $args{class}),
      'data-x' => $p * (delete $args{x} || 1400),
      'data-z' => $p * -200,
      %args,
      $content,
    );
  },
);

app->defaults(layout => 'slides', title => 'Presentation');
app->start;
__DATA__
@@ presentation.html.ep
%#===========================================================================
%= slide 'intro', class => 'text-center', begin
<h2 class="text-center">Mojolicious::Plugin::AssetPack</h2>
<p>Jan Henning Thorsen</p>

<div class="note">
  Hello. I'm very happy to be here with you at the very first
  Mojolicious conference.
  My name is Jan Henning Thorsen. I work for a Norwegian Telecom company
  called Telenor, where I use Mojolicious to configure routers so our customers
  can access the Internet.

  Today I'm here to tell you about a Mojolicious plugin called
  "Mojolicious::Plugin::AssetPack".

  Please wait wait questions until after the talk. (?)
</div>
% end

%#===========================================================================
%= slide 'toc', begin
<ul>
  <li>What is an asset?</li>
  <li>What is AssetPack?</li>
  <li>How does it work?</li>
  <li>Customization</li>
  <li>Extensions</li>
  <li>Gotchas</li>
</ul>

<div class="note">
Through this talk, I will explain what the plugin can do, how it works
and ways to customize and extend it. But first...What is an asset?
</div>
% end

%#===========================================================================
%= slide 'asset', class => 'text-center', begin
<h1>An asset is a static file.</h1>

<div class="note">
An asset is content which is static from the perspective from many users.
These files are typically css and javascript. These assets are often many and
not very space effective. Example: You split your javascript into multiple files
for easy development, but that is no good for the browser, since it has to
download all those files. Many requests to the webserver slows down the website.
</div>
% end

%#===========================================================================
%= slide 'assetpack', class => 'text-center', begin
<h1>How does AssetPack work?</h1>
%= pre begin
              .--------------.
  [a.css]-----|              |
  [b.less]----| Preprocessor |--->[my_asset.css]
  [c.scss]----|              |
              '--------------'
% end

<div class="note">
So how can AssetPack help you out? AssetPack is a system which can cram
all assets of the same type into one file. The example above reads
a plain CSS file and a LESS and SASS file, and converts them all into one
output CSS file. The output file is also minified. A minified file is a file
where all private variables are shortened ("some_variable" turns into "a"),
and whitespace is removed. The result is less requests hitting the server
but also less bandwidth is used to transport the same information.

<br>
Note: LESS and SASS are CSS with superpowers. If you are still
writing plain CSS, you should check out SASS. It allows you to use
inheritance and functions inside your CSS.
</div>
% end

%#===========================================================================
%= slide 'preprocessors', stop => 1, begin
<h2>Pre-processors</h2>
<div class="note">
The way AssetPack convert files is by mapping file extensions to a pre-processor.
The most common pre-processors are detected on startup, but you can also
redefine or add custom pre-processors if you like. More on this later on.
</div>
% end

%#===========================================================================
%= slide 'formats', begin
<h1>Default pre-processors</h1>
<dl class="dl-horizontal">
  <dt>.css</dt>
  <dd><a href="https://metacpan.org/pod/CSS::Minifier::XS">CSS::Minifier::XS</a></dd>
  <dt>.js</dt>
  <dd><a href="https://metacpan.org/pod/JavaScript::Minifier::XS">JavaScript::Minifier::XS</a></dd>
  <dt>.less</dt>
  <dd><a href="http://lesscss.org/">LESS</a> (optional)</dd>
  <dt>.coffee</dt>
  <dd><a href="http://coffeescript.org">CoffeeScript</a> (optional)</dd>
  <dt>.scss</dt>
  <dd><a href="http://sass-lang.com/">SASS</a> (optional)</dd>
</dl>
<div class="note">
AssetPack need some external helpers to get the job done: To minify plain
CSS and javascript files, it use two CPAN modules called CSS::Minifier::XS
and JavaScript::Minifier::XS.
They are fast, because they are written in C, but they do require a compiler
to be built. In addition, AssetPack supports CoffeeScript, LESS and SASS.
These formats are compiled using the official compilers, so they require
you to install Ruby and/or Node.js. I've found some modules on CPAN which
in theory are supposed to do the same job, but they are simply not good
enough, compared to the official tools.
</div>
% end

%#===========================================================================
%= slide 'define_asset_pre', y => 0, stop => 1, begin
<h2>Define asset</h2>
%= pre begin
#!/usr/bin/env perl
use Mojolicious::Lite;
% end
<div class="note">
This example start out as a Mojolicious::Lite application.
</div>
% end

%#===========================================================================
%= slide 'define_asset_plugin', y => 130, stop => 1, begin
%= pre begin
plugin "AssetPack";
% end
<div class="note">
Then we load the AssetPack plugin with the default configuration, which in
most cases JustWork &trade;.
</div>
% end

%#===========================================================================
%= slide 'define_asset', y => 340, stop => 1, begin
%= pre begin
app->asset(
  # Friendly name (moniker)
  "my_asset.css",

  # Files found in @{ $app->static->paths }
  qw(
    css/impress-demo.css
    sass/presentation.scss
  )
);
% end
<div class="note">
Then we define our assets. The first argument is the "friendly name" (moniker)
you will refere to later in your template. The rest of the arguments is a
list of the input files. The input files need to be relative to one of the
static directories.
</div>
% end

%#===========================================================================
%= slide 'define_asset_post', y => 550, begin
%= pre begin
app->start;
% end
<div class="note">
Then at "start()" the assets are built and available to be used in your
templates.
</div>
% end

%#===========================================================================
%= slide 'include_asset', begin
<h2>Include assets</h2>
%= pre begin
<html>
<head>
  <title><%= title %></title>
  %%= asset "my_asset.css"
</head>
</html>
% end
<div class="note">
In your template, you can then generate css or javascript tags using the
"asset()" helper again. You only give one argument to the helper this:
The friendly name defined in you application.
</div>
% end

%#===========================================================================
%= slide 'web_assets', begin
<h1>Assets from the internet</h1>
%= pre begin
app->asset('bundle.js' => (
  'http://cdnjs.cloudflare.com/es5-shim.js',
  'http://cdnjs.cloudflare.com/es5-sham.js',
  'http://code.jquery.com/jquery-1.11.0.js',
  '/js/myapp.js',
));
% end
<div class="note">
Ever tired of using "wget" or "curl" to download assets and then include them
in your project? AssetPack got your back: Just drop in a full URL and
Mojolicious::UserAgent will download the assets for you.
</div>
% end

%#===========================================================================
%= slide 'environment', begin
<h1 class="text-center">Environments</h1>
<div class="row">
  <div class="col-xs-5 text-center bg-primary"><h2>Production</h2></div>
  <div class="col-xs-2 text-center"><h2>V.S</h2></div>
  <div class="col-xs-5 text-center bg-danger"><h2>Development</h2></div>
</div>
<div class="note">
So in production mode all the assets are crammed together to one cached,
minifed asset which the regular visitor will love to download, but a hacker
will hate. (Since it's minified). In development mode on the other hand,
AssetPack will simply compile SASS, LESS and CoffeeScript into something
the browser can understand. The output will be readable code - not minified,
so you can easier debug typos and other weird stuff in your javascript.
</div>
% end

%#===========================================================================
%= slide 'env_no_cache', begin
<h2 class="text-center">MOJO_ASSETPACK_NO_CACHE=1</h2>
<div class="note">
You can also set the MOJO_ASSETPACK_NO_CACHE environment variable, if you
want the assets to be compiled on each request, instead of using the cached
files created on "start()".
</div>
% end

%#===========================================================================
%= slide 'summary', begin
To summarize...
Questions..?

Presentation is powered by
<%= link_to 'impress.js', 'https://github.com/bartaz/impress.js' %> and
<%= link_to 'Mojolicious', 'http://mojolicio.us' %>.
% end

@@ layouts/slides.html.ep
<html>
<head>
  <title><%= title %></title>
  %= asset 'presentation.css'
</head>
<body class="impress-not-supported">
  <div class="fallback-message">
    <p>Your browser <b>doesn't support the features required</b> by impress.js, so you are presented with a simplified version of this presentation.</p>
    <p>For the best experience please use the latest <b>Chrome</b>, <b>Safari</b> or <b>Firefox</b> browser.</p>
  </div>
  <div class="menu">
  %= link_to 'Presentation mode', url_for('presentation')->query(present => 1), class => 'btn btn-success'
  </div>
  <div id="impress">
    %= content
  </div>
  %= asset 'presentation.js'
% if($self->param('present')) {
  <script>impress().init();</script>
% } else {
  <style>
    .note { display: block; }
    .menu { display: block; }
  </style>
% }
</body>
</html>
