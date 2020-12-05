package Attribute::Baz;
use v5.32;
use warnings;
use utf8;
use Attribute::Handlers;

sub Baz :ATTR(CODE) {
  my ($package, $symbol, $referent, $attr, $data) = @_;
  warn 'baz...';
}

1;
