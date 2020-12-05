package Attribute::Bar {

  use v5.32;
  use warnings;
  use strict;
  use Sub::Util qw( subname set_subname );

  sub import {
    my $class = shift;

    my $export_to = caller;

    {
      no strict 'refs';
      no warnings 'redefine';

      *{ $export_to . '::MODIFY_CODE_ATTRIBUTES' } = do {
        use strict 'refs';
        use warnings 'redefine';
        # 他の自作 attribute が使われているか確認
        if ( my $orig = $export_to->can('MODIFY_CODE_ATTRIBUTES') ) {
          # 他の自作 attribute による MODIFY_CODE_ATTRIBUTES を先に呼び出し, 他の attribute では無効だった属性のリストを渡すようにする
          sub {
            my ($klass, $coderef, @attributes) = @_;
            my @orig_ignore_attributes = $klass->$orig($coderef, @attributes);
            return $class->MODIFY_CODE_ATTRIBUTES($coderef, @orig_ignore_attributes);
          };
        }
        else {
          \&MODIFY_CODE_ATTRIBUTES;
        }
      };

      *{ $export_to . '::FETCH_CODE_ATTRIBUTES' } = do {
        use strict 'refs';
        use warnings 'redefine';
        if ( my $orig = $export_to->can('FETCH_CODE_ATTRIBUTES') ) {
          sub {
            # 他の自作 attribute による FETCH_CODE_ATTRIBUTES を先に呼び出しその結果とあわせて設定されている属性のリストを返す
            my ($klass, $coderef) = @_;
            my @attributes = $klass->$orig($coderef);
            return ( @attributes, $class->FETCH_CODE_ATTRIBUTES($coderef) );
          };
        }
        else {
          \&FETCH_CODE_ATTRIBUTES;
        }
      };

    }

  }

  my %setted_attribute_of_method;

  sub MODIFY_CODE_ATTRIBUTES {
    my ($class, $coderef, @attributes) = @_;
    
    if ( grep { $_ eq 'Bar' } @attributes ) {
      my $method_name = subname($coderef);
      $setted_attribute_of_method{$method_name} = 1;
    }

    my @ignore_attributes = grep { $_ ne 'Bar' } @attributes;
    return @ignore_attributes > 0 ? @ignore_attributes : ();
  }

  sub FETCH_CODE_ATTRIBUTES {
    my ($class, $coderef) = @_;
    return exists $setted_attribute_of_method{ subname($coderef) } ? ('Bar') : ();
  }

}

1;
