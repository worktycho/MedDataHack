package MSXml;
use XML::Simple 'XMLin';
#use Data::Printer;
use File::Temp qw/tempdir tempfile/;
use Dancer ':syntax';
use strict;

sub getallocationsbyresources {
my ($player, $time) = @_;
my $projecttext = template (setting ('projectTemplate'), {player => $player, time => $time});
my ($tmpfile, $filename) = tempfile(SUFFIX => '.tjp');
print $tmpfile $projecttext; 
my ($tempdir) = tempdir(DIR => 'public/temp');
system("tj3 $filename -o \"$tempdir\" >tj3bin")  == 0 or die "fail";
my $resources;
my $project = XML::Simple::XMLin("$tempdir/Ms-Project.xml");
my @resources = @{$project->{Resources}->{Resource}};
for my $resouce (@resources) {
$resources->{$resouce->{UID}}->{Name} = $resouce->{Name};
}
my @assignments = $project->{Assignments}{Assignment};
for my $temp (@assignments) {
	for my $assignment (@{$temp}) {
		if (defined $resources->{$assignment->{ResourceUID}}) {
			$resources->{$assignment->{ResourceUID}}->{allocations} = [] if not defined $resources->{$assignment->{ResourceUID}}->{allocations};
			push $resources->{$assignment->{ResourceUID}}->{allocations}, { start  => $assignment->{start},
			finish => $assignment->{finish}};
		} else {
			die "parsing error";
		}
	}
}

return $resources
}

1;
