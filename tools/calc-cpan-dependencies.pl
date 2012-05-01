#!/usr/bin/perl -w
# $Id: calc-cpan-dependencies.pl 13664 2007-05-08 12:58:03Z WillNorris $
# Copyright 2009 Will Norris.  All Rights Reserved.
# License: GPL
################################################################################

use strict;
use Data::Dumper qw( Dumper );
++$|;

#open(STDERR,'>&STDOUT'); # redirect error to browser
use LWP::UserAgent;

#use LWP;
use LWP::Simple;
use URI;
use XML::Simple;
use Getopt::Long;
use Config;
use Pod::Usage;

my $optsConfig = {
    'list-uninstalled' => 0,
    'list-versions'    => 0,

    #
    status  => 0,
    verbose => 0,
    debug   => 0,
    help    => 0,
    man     => 0,
};

GetOptions(
    $optsConfig,
    'list-uninstalled',
    'list-versions',
    'status',

    # miscellaneous/generic options
    'help', 'man', 'debug', 'verbose|v',
);
pod2usage(1) if $optsConfig->{help};
pod2usage( { -exitval => 1, -verbose => 2 } ) if $optsConfig->{man};
print STDERR Dumper($optsConfig) if $optsConfig->{debug};

if ( $optsConfig->{status} ) {
    print Dumper($optsConfig);
}

#print STDERR Dumper( $optsConfig ) if $optsConfig->{debug};

################################################################################

#my $ua = LWP::UserAgent->new;
#$ua->agent( 'Foswiki CpanContrib calc-cpan-dependencies.pl/0.1' );

#*calc_cpan_dependencies = \&calc_cpan_dependences_webservice;
my @deps = map { &calc_cpan_dependencies_webservice($_) } @ARGV;
my @versions = map { [ $_ => eval "use $_; \$${_}::VERSION" ] } @deps;
print "@versions: " . Dumper( \@versions ) if $optsConfig->{debug};

print join( ', ', map { "$_->[0] (" . ( $_->[1] || '' ) . ')' } @versions ),
  "\n"
  if $optsConfig->{'list-versions'};

print join( ' ',
    $optsConfig->{'list-uninstalled'}
    ? map { $_->[0] } grep { not defined $_->[1] } @versions
    : @deps ),
  "\n";

exit 0;

################################################################################

sub calc_cpan_dependencies_webservice {
    my $module = shift;
    print "calculating dependencies for $module\n" if $optsConfig->{verbose};

    my @deps;
    ( my $uri = URI->new('http://cpandeps.cantrell.org.uk/') )
      ->query_form( xml => 1, module => $module );
    if ( my $deps_xml = LWP::Simple::get($uri) ) {
        my $ref = XML::Simple::XMLin($deps_xml);
        my @modules =
          reverse sort { $a->{depth} <=> $b->{depth} } @{ $ref->{dependency} }
          if $ref->{dependency};
        @deps = map { $_->{module} } @modules;
    }
    else {
    }

    return @deps;
}

################################################################################
################################################################################

__DATA__

=head1 NAME

calc-cpan-dependencies.pl - calculate CPAN module dependency requirements

=head1 SYNOPSIS

tools/calc-cpan-dependencies.pl [options] <CPAN Module>...

Copyright 2009,2010 Will Norris.  All Rights Reserved.

  Options:
   --list-uninstalled  only list those modules which are not already installed
   --list-versions     display version number for each installed module
   -status             show configuration
   -verbose
   -debug
   -help               this documentation
   -man                full docs

=head1 OPTIONS

=over 8

=item B<-config>

=item B<-status>

=back

=head1 DESCRIPTION

B<calc-cpan-dependencies.pl> calculates all of the dependencies for the specified CPAN modules


=head2 EXAMPLES

perl calc-cpan-dependencies.pl Net::Twitter

produces

ExtUtils::MakeMakerCompress::Raw::ZlibCompress::Raw::Bzip2Package::ConstantsIO::ZlibCompress::ZlibFile::TempText::ParseWordsData::DumperIO::FileGetopt::LongExtUtils::ManifestArchive::TarExtUtils::InstallExtUtils::CBuilderModule::BuildFile::PathTestCarpAlgorithm::C3Data::OptListSub::InstallParams::UtilFile::SpecExporterXSLoaderClass::C3Sub::ExporterScope::GuardTest::HarnessbaseDigest::baseVariable::MagicMRO::CompatTask::WeakenDevel::GlobalDestructionSub::NameSub::UplevelTest::MoreUNIVERSAL::requireClass::Data::InheritableDigest::HMAC_SHA1Class::AccessorDigest::MD5HTML::ParserHTML::TagsetNet::FTPnamespace::cleanB::Hooks::EndOfScopeMIME::Base64List::MoreUtilsClass::MOPTest::ExceptionScalar::UtilJSON::AnyMooseX::MultiInitArgNet::OAuthDigest::SHAHTTP::Request::Commonnamespace::autocleanURIMoose::RoleNet::Twitter


=head2 SEE ALSO

        http://foswiki.org/Extensions/CpanContrib

=cut
