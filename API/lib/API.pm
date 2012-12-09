package API;
use warnings;
use strict;
use File::Temp qw/tempfile tempdir/;
use Dancer ':syntax';
use XML::Simple qw(:strict);
use MSXml;
our $VERSION = '0.1';

#not briliant
our $players = {};
our @patients = (
					{
						priority => 1,
						class => "neuro",
						"time" => 10
					},
					{
						priority => 2,
						class => "Thoracic",
						"time" => 20
					},
				);
post '/assignteam/' => sub {
	my $passeddata = params;
	$players->{$passeddata->{playerid}}->rooms->{$passeddata->{roomid}} = $passeddata->{roomcontents};
	$players->{$passeddata->{playerid}}->pool = $passeddata->{poolcontents};
	my %returndata = playerstatus($passeddata->{playerid});
	content_type('application/json');
	return to_json(\%returndata);
};

get '/roomstatus/:playerid/:time' => sub {
	return to_json(MSXml::getallocationsbyresources($players->{param('playerid')},param('time')));
};

sub playerstatus {
	my ($playerid) = @_;
	#do something
	return {};
}


get '/init/' => sub {
	my $data = {
		pool => {
		people => 
			[ 
				{
					num => 10,
					type => "anethatist"
				}
			],
			},
		patients => 
			[
				{
					priority => 1,
					class => "poly",
				}
			],
		playerid => rand()
	};
	$players->{$data->{playerid}} = $data;
	content_type('application/json');
	return to_json($data);
};

get '/report/:playerid/:time' => sub {
	my $project = template (setting ('projectTemplate'), {player => $players->{param('playerid')}, time => param('time')});
	my ($tmpfile, $filename) = tempfile(SUFFIX => '.tjp');
	print $tmpfile $project; 
	my ($tempdir) = tempdir(DIR => 'public/temp');
	system("tj3 $filename -o \"$tempdir\" >tj3bin")  == 0 or die "fail";
	$tempdir =~ s/^public//;
	return send_file( "$tempdir/" . setting 'projectReport');
};


sub runTjp {
	my %passeddata = @_;
	my $projectfile = template  'projectfile', %passeddata;
	my ($tmpfile, $filename) = tempfile;
	print $tmpfile $projectfile;
	my $output = `tj3 $filename -`;
	my $ref = XMLin($output);
	#process tjpfile
	return $output;
}
true;
