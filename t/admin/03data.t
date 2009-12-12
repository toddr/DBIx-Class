#
#===============================================================================
#
#         FILE:  03sql.t
#
#  DESCRIPTION:  test sql manipulation funtions
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Gordon Irving (), <Gordon.irving@sophos.com>
#      VERSION:  1.0
#      CREATED:  12/12/09 12:44:57 GMT
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use Test::More;

use Test::Exception;
use Test::Deep;

use Path::Class;
use FindBin qw($Bin);

use lib dir($Bin,'..', '..','lib')->stringify;
use lib dir($Bin,'..', 'lib')->stringify;

use ok 'DBIx::Class::Admin';

use DBICTest;

{ # test data maniplulation functions

	# create a DBICTest so we can steal its connect info
	my $schema = DBICTest->init_schema(
	#    no_deploy=>1,
	#	no_populate=>1,
		sqlite_use_file => 1,
		);


	my $admin = DBIx::Class::Admin->new(
		schema_class=> "DBICTest::Schema",
		connect_info => $schema->storage->connect_info(),
		quiet	=> 1,
		_confirm=>1,
	);
	isa_ok ($admin, 'DBIx::Class::Admin', 'create the admin object');

	$admin->insert_data('Employee', { name => 'Matt' });
	my $employees = $schema->resultset('Employee');
	is ($employees->count(), 1, "insert okay" );

	my $employee = $employees->find(1);
	is($employee->name(),  'Matt', "insert valid" );

	$admin->update_data('Employee', {name => 'Trout'}, {name => 'Matt'});

	$employee = $employees->find(1);
	is($employee->name(),  'Trout', "update Matt to Trout" );

	$admin->insert_data('Employee', {name =>'Aran'});

	my $expected_data = [ 
		[$employee->result_source->columns() ],
		[1,1,undef,undef,undef,'Trout'],
		[2,2,undef,undef,undef,'Aran']
	];
	my $data;
	lives_ok { $data = $admin->select_data('Employee')} 'can retrive data from database';
	cmp_deeply($data, $expected_data, 'DB matches whats expected');

	$admin->delete_data('Employee', {name=>'Trout'});
	my $del_rs  = $employees->search({name => 'Trout'});
	is($del_rs->count(), 0, "delete Trout" );
	is ($employees->count(), 1, "left Aran" );
}



done_testing;
