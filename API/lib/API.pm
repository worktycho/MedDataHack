package API;
use warnings;
use strict;
use File::Temp 'tempfile';
use Dancer ':syntax';

our $VERSION = '0.1';

post '/assignteam/' => sub {
	my %passeddata = params;
	my %returndata = runTjp(%passeddata);
	content_type('text/xml')
	return to_xml(\%returndata);
};


get '/' => sub {
    template 'index';
};

sub runTjp {
	my %passeddata = @_;
	my $projectfile = template  'projectfile', %passeddata;
	my ($tmpfile, $filename) = tempfile;
	print $tmpfile $projectfile;
	my $output = `tj3 $filename -`;
	#process tjpfile
	return $output;
}
true;
