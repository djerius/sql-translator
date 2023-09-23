use strict;
use Test::More;
use Test::Exception;
use Test::SQL::Translator qw(maybe_plan);
use SQL::Translator;
use FindBin '$Bin';

BEGIN {
  maybe_plan(3, 'SQL::Translator::Parser::DBI::Sybase',);
}

use_ok('SQL::Translator::Parser::DBI::Sybase');
use_ok('SQL::Translator::Parser::Storable');
use_ok('SQL::Translator::Producer::Storable');

my $file = "$Bin/data/sybase/index_with_where.yaml";
open my $fh, '<', $file or die "Can't read '$file': $!\n";
local $/;
my $data = <$fh>;
my $tr = SQL::Translator->new(
    no_comments => 1,
    parser => 'YAML',
    producer => 'Sybase',
    data => $data,
);

my $out;
lives_ok { $out = $tr->translate } 'Translate YAML to Sybase';
$out =~ s/^\h*\n//mg;
is( $out, <<'SQL', 'SQL matches expected' );
CREATE TABLE person (
  person_id numeric(11) NULL,
  name varchar(20) NOT NULL
);
CREATE INDEX u_name_id ON person(name, person_id) WHERE person_id is not null
SQL
1;

