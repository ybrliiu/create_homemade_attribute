package Attribute::Qux;
use v5.32;
use warnings;
use utf8;
use Attribute::Handlers;

sub Qux :ATTR(CODE) {
  my ($package, $symbol, $referent, $attr, $data) = @_;
  warn 'qux';
}

1;
