use Test::More;
use lib qw(t/lib);
use DBICTest;
use DBICTest::HelperRels;

require "t/run/27result_set_column.tl";
run_tests(DBICTest->schema);
