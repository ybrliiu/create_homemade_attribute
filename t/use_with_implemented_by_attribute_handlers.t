use Test2::V0;

package Hoge {

  use Attribute::PrivateMethod;
  use parent 'Attribute::Baz';

  # Invalid CODE attribute: Baz at t/use_with_implemented_by_attribute_handlers.t line 10.
  # Attribute::Handlers によって定義された UNIVERSAL::MODIFY_CODE_ATTRIBUTES が呼び出されなくなるから
  sub do_something :Baz :Private {
    warn 'Do something...';
  }

}

package Fuga {

  use Attribute::PrivateMethod;
  use Attribute::Foo;
  use Attribute::Bar;
  use parent 'Attribute::Baz';
  use parent 'Attribute::Qux';

  sub do_something :Baz :Qux :Private :Foo :Bar {
    warn 'Do something...';
  }

}

use attributes qw( get );

is [ get(\&Hoge::do_something) ], [qw( Private )], 'Attribute::Handlers で設定された属性は取得できない';

done_testing;
