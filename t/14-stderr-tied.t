# Copyright (c) 2009 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

use strict;
use warnings;
use Test::More;
use Config;
use t::lib::Utils qw/save_std restore_std/;
use t::lib::Tests qw(
  capture_tests           capture_count
  capture_merged_tests    capture_merged_count
  tee_tests               tee_count
  tee_merged_tests        tee_merged_count
);
use t::lib::TieLC;

#--------------------------------------------------------------------------#

plan skip_all => "In memory files not supported before Perl 5.8"
  if $] < 5.008;

plan tests => 2 + capture_count() + capture_merged_count() 
                + tee_count() + tee_merged_count(); 

my $no_fork = $^O ne 'MSWin32' && ! $Config{d_fork};

#--------------------------------------------------------------------------#

save_std(qw/stderr/);
tie *STDERR, 't::lib::TieLC', ">&=STDERR";
my $orig_tie = tied *STDERR;
ok( $orig_tie, "STDERR is tied" ); 

select STDERR; $|++;
select STDOUT; $|++;

capture_tests();
capture_merged_tests();

SKIP: {
  skip tee_count() + tee_merged_count, "requires working fork()" if $no_fork;
  tee_tests();
  tee_merged_tests();
}

is( tied *STDERR, $orig_tie, "STDERR is still tied" ); 
restore_std(qw/stderr/);

