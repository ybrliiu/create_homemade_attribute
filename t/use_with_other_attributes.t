use Test2::V0;

package Hoge {

  use Attribute::PrivateMethod;
  use Attribute::Foo;
  use Attribute::Bar;

  sub do_something :Private :Foo :Bar {
    warn 'Do something...';
  }

  sub do_something2 :method {}

  sub do_something3 :method :Private {}

}

use attributes qw( get );

ok dies { Hoge->do_something() }, 'private method なのでパッケージ外から呼ぶと死ぬ';
is [ get(\&Hoge::do_something) ], [qw( Private Foo Bar )];
is [ get(\&Hoge::do_something2) ], ['method'];
# 組み込みの属性がなぜか返ってこない
is [ get(\&Hoge::do_something3) ], [qw( method Private )];

done_testing;
