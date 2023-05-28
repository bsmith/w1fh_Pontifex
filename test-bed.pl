#!/usr/bin/perl

use 5.030001;
use strict;
use warnings;

use Getopt::Long qw/GetOptions/;
use IPC::Run qw/run/;

my $PROG = './pontifex.pl';

GetOptions(
	'prog' => \$PROG,
) or die "$0: GetOptions failed\n";

if (@ARGV != 0) {
	die "$0: does not take any command line args\n";
}

sub run_program {
	my ($cmd, $input) = @_;
	my $output;
	$input = "$input\n" unless $input =~ /\n\z/;
	run $cmd, \$input, \$output or die "@$cmd: $?";
	# chomp is not sufficient as the original has other whitespace here
	$output =~ s/\s+\z//;
	return $output;
}

sub test_encrypt {
	my ($passphrase, $input, $expected_output) = @_;
	my $actual_output = run_program([$PROG, ($passphrase // ())], $input);
	if ($actual_output ne $expected_output) {
		print "test_encrypt(", defined($passphrase) ? "'$passphrase'" : '(undef)', ", '$input')\n";
		print "FAILED: got '$actual_output', expected '$expected_output'\n";
	}
}

sub test_decrypt {
	my ($passphrase, $input, $expected_output) = @_;
	my $actual_output = run_program([$PROG, '-d', ($passphrase // ())], $input);
	if ($actual_output ne $expected_output) {
		print "test_decrypt(", defined($passphrase) ? "'$passphrase'" : '(undef)', ", '$input')\n";
		print "FAILED: got '$actual_output', expected '$expected_output'\n";
	}
}

#
# Test Vectors from appendix
# --------------------------
#
# > echo aaaaa aaaaa | ./pontifex.pl
# < EXKYI ZSGEH
# > echo aaaaa aaaaa aaaaa | ./pontifex.pl foo
# < ITHZU JIWGR FARMW
# < echo solitaire | ./pontifex.pl cryptonomicon
# > KIRAK SFJAN

test_encrypt(undef, 'aaaaa aaaaa', 'EXKYI ZSGEH');
test_encrypt(undef, 'AaAaA aAaAa', 'EXKYI ZSGEH');
test_encrypt('foo', 'a'x15, 'ITHZU JIWGR FARMW');
test_encrypt('cryptonomicon', 'solitaire', 'KIRAK SFJAN');

test_decrypt(undef, 'EXKYI ZSGEH', 'AAAAA AAAAA');
test_decrypt('FOO', 'ITHZU JIWGR FARMW', 'AAAAA AAAAA AAAAA');
test_decrypt('CRYPTONOMICON', 'KIRAK SFJAN', 'SOLIT AIRE');

print "--- END OF TESTS ---\n";
