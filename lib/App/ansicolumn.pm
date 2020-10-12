package App::ansicolumn;

our $VERSION = "0.05";

use v5.14;
use warnings;
use open IO => 'utf8', ':std';
use Pod::Usage;
use Getopt::EX::Long;
Getopt::Long::Configure("bundling");

use Data::Dumper;
use List::Util qw(max);
use Text::Tabs qw(expand);
use Text::ANSI::Fold qw(:constants);
use Text::ANSI::Fold::Util qw(ansi_width);
use Text::ANSI::Printf qw(ansi_printf ansi_sprintf);
use App::ansicolumn::Util;

sub new {
    my $class = shift;
    bless {
	output_width     => undef,
	fillrows         => undef,
	table            => undef,
	separator        => ' ',
	output_separator => '  ',
	columnunit       => 8,
	pane             => 0,
	tabstop          => 8,
	ignore_space     => 1,
	fullwidth        => undef,
	linestyle        => 'none',
	boundary         => 'none',
	linebreak        => 'none',
	runin            => 2,
	runout           => 2,
    }, $class;
}

sub run {
    my $obj = shift;
    local @ARGV = @_;
    GetOptions(
	$obj,
	"output_width|output-width|c=i",
	"fillrows|x",
	"table|t",
	"separator|s=s",
	"output_separator|output-separator|o=s",
	"columnunit|cu=i",
	"pane=i",
	"tab=i",
	"ignore_space|ignore-space|is!",
	"fullwidth!",
	"linestyle|ls=s",
	"boundary=s",
	"linebreak|lb=s", "runin=i", "runout=i",
	"version|v",
	) || pod2usage();
    $obj->{version} and do { say $VERSION; exit };
    if ($obj->{linestyle} eq 'wordwrap') {
	$obj->{linestyle} = 'wrap';
	$obj->{boundary} = 'word';
    }
    $Text::Tabs::tabstop = $obj->{tabstop};
    my @lines = expand <>;
    if ($obj->{table}) {
	$obj->table_out(@lines);
    } else {
	$obj->column_out(@lines);
    }
}

my %linebreak = (
    none   => LINEBREAK_NONE,
    runin  => LINEBREAK_RUNIN,
    runout => LINEBREAK_RUNOUT,
    all    => LINEBREAK_ALL,
    );

sub column_out {
    my $obj = shift;
    my %opt = %$obj;
    my @item = @_;
    return unless @item;
    chop @item;

    use integer;
    my $width = $opt{output_width} || terminal_width();
    my @length = map { ansi_width $_ } @item;
    my $max_length = max @length;
    my $unit = $opt{columnunit} || 1;
    my $span = ($max_length + $unit) / $unit * $unit;
    my $panes = $opt{pane} || $width / $span || 1;
    if ($opt{fullwidth}) {
	$span = $width / $panes;
    }
    if ($max_length > $span and $opt{linestyle} ne 'none') {
	my $width = $span;
	my $linebreak = $linebreak{$opt{linebreak}};
	if ($linebreak & LINEBREAK_RUNIN) {
	    $width -= $opt{runin};
	}
	my $fold = Text::ANSI::Fold->new(
	    width => $width,
	    boundary => $opt{boundary},
	    linebreak => $linebreak,
	    runin => $opt{runin}, runout => $opt{runout},
	    );
	if ($opt{linestyle} eq 'truncate') {
	    @item = map { ($fold->fold($_))[0] } @item;
	}
	elsif ($opt{linestyle} eq 'wrap') {
	    @item = map {
		$_ eq '' ? $_ : $fold->text($_)->chops;
	    } @item;
	}
	else {
	    die "Unknown line style: $opt{linestyle}\n";
	}
    }
    my $rows = (@item + $panes - 1) / $panes;
    my @index = 0 .. $#item;
    my @lines = do {
	if ($opt{fillrows}) {
	    map { [ splice @index, 0, $panes ] } 1 .. $rows;
	} else {
	    zip map { [ splice @index, 0, $rows ] } 1 .. $panes;
	}
    };
    for my $line (@lines) {
	my $format = "%-${span}s" x (@$line - 1) . "%s\n";
	ansi_printf $format, @item[@$line];
    }
}

sub table_out {
    my $obj = shift;
    my %opt = %$obj;
    return unless @_;
    chomp @_;
    my $split = do {
	if ($opt{separator} eq ' ') {
	    $opt{ignore_space} ? ' ' : qr/ /;
	} else {
	    qr/[\Q$opt{separator}\E]/;
	}
    };
    my @lines  = map { [ split $split, $_ ] } @_;
    my @length = map { [ map { ansi_width $_ } @$_ ] } @lines;
    my @max    = map { max @$_ } zip @length;
    my @format = map { sprintf "%%-%ds", $_ } @max;
    for my $line (@lines) {
	my $format = join($obj->{output_separator},
			  @format[0..$#{$line}-1], "%s\n");
	ansi_printf $format, @$line;
    }
}

1;

__END__

=encoding utf-8

=head1 NAME

ansicolumn - ANSI sequence aware column command

=head1 DESCRIPTION

Document is included in executable script.
Use `perldoc ansicolumn`.

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright 2020 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

