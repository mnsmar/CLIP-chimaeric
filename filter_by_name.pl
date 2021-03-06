#!/usr/bin/env perl

use Modern::Perl;
use autodie;
use Getopt::Long::Descriptive;

# Define and read command line options
my ($opt, $usage) = describe_options(
	"Usage: %c %o",
	["Print FASTA entries whose header matches any of the entries in another FASTA file."],
	[],
	['ifile=s',
		'Input FASTA file with sequences to be filtered. Use - for STDIN',
		{required => 1}],
	['ref-file=s',
		'Input FASTA file to filter with. Use - for STDIN',
		{required => 1}],
	['verbose|v', 'Print progress'],
	['help|h', 'Print usage and exit',
		{shortcircuit => 1}],
);
print($usage->text), exit if $opt->help; 

if ($opt->ifile eq '-' and $opt->ref_file eq '-') {
	die "cannot use STDIN for both input files\n";
}

my %accepted_name;
warn "opening filter file\n" if $opt->verbose;
my $FN = filehandle_for($opt->ref_file);
while (my $line = <$FN>){
	if ($line =~ /^>/){
		my $header = $line;
		chomp $header;
		$accepted_name{$header} = 1;
	}
}
close $FN;

warn "opening input file\n" if $opt->verbose;
my $IN = filehandle_for($opt->ifile);
while (my $line = $IN->getline()){
	if ($line =~ /^>/){
		my $header = $line;
		chomp $header;
		my $seqline = $IN->getline();
		chomp $seqline;
		if (exists $accepted_name{$header}){
			print $header."\n".$seqline."\n";
		}
	}
}
close $IN;

exit;

sub filehandle_for {
	my ($file) = @_;

	if ($file eq '-'){
		open(my $IN, "<-");
		return $IN;
	}
	else {
		open(my $IN, "<", $file);
		return $IN
	}
}

sub revcomp {
	my ($seq) = @_;
	$seq = reverse($seq);
	$seq =~ tr/ACTGactg/TGACtgac/;
	return $seq;
} 
