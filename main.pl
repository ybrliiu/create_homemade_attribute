package Attribute::PrivateMethod {

  use v5.32;
  use warnings;
  use strict;
  use Carp qw( croak );
  use Sub::Util qw( subname set_subname );

  my %is_method_setted_attribute;

  sub MODIFY_CODE_ATTRIBUTES {
    my (
      $class,
      $coderef,   # attribute が設定されたサブルーチンのリファレンス
      @attributes # 設定された attribute のリスト
    ) = @_;
    
    # (2) 設定された属性のリストの中に有効な属性があれば属性に応じて処理を行う
    if ( grep { $_ eq 'Private' } @attributes ) {

      my $privated_method = sub {
        my $class  = shift;
        my $caller = caller;
        croak 'Can not call private method from other package' if $caller ne __PACKAGE__;
        goto &$coderef;
      };

      my $method_name = subname($coderef);
      set_subname($method_name, $privated_method);

      {
        no strict 'refs';
        no warnings 'redefine';
        *$method_name = $privated_method;
      }

      # (7) FETCH_CODE_ATTRIBUTES でメソッド名から属性が付与されているか判定できるように記録する
      $is_method_setted_attribute{$method_name} = 1;
    }

    # (3) 設定された属性のリストの中に無効な属性がないかチェック
    my @ignore_attributes = grep { $_ ne 'Private' } @attributes;
    return @ignore_attributes > 0 ? @ignore_attributes : ();
  }

  # (6) attributes::get で attribute のリストを取得できるようにする
  sub FETCH_CODE_ATTRIBUTES {
    my ($class, $coderef) = @_;
    # 属性を設定済みなら設定済みの属性を、設定されてなければ空リストを返す
    return exists $is_method_setted_attribute{ subname($coderef) } ? ('Private') : ();
  }

  # (4) 自作した attribute を設定
  sub do_something :Private {
    say 'do something...';
  }

  # attribute が設定されたメソッドを呼ぶ
  __PACKAGE__->do_something();

}

use attributes qw( get );
use DDP +{ deparse => 1, use_prototypes => 0 };

# (5) 設定された属性の一覧を取得
p [ get(\&Attribute::PrivateMethod::do_something) ]; # [ [0] "Private" ]

