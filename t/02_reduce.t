# 02_reduce.t
#
# Test suite for Regexp::Assemble
#
# Test the various tail reductions, e.g. /dab/ /cab/ => /[cd]ab/
#
# copyright (C) 2004 David Landgren

use strict;
use Regexp::Assemble;

# development
use Data::Dumper;
$Data::Dumper::Terse     = 0;
$Data::Dumper::Indent    = 0;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Pair      = '=>';

use constant deep_testcount => 47; # tests requiring Test::Deep
use Test::More tests => deep_testcount;

my $have_Test_Deep = do {
	eval { require Test::Deep; import Test::Deep };
	$@ ? 0 : 1;
};

SKIP: {

skip 'Test::Deep not installed on this system', deep_testcount
	unless $have_Test_Deep;

{
	my $ra = Regexp::Assemble->new;
	$ra->insert($_) for 0..2;
	$ra->_reduce;
	cmp_deeply( $ra->_path,
		[
			{
				'0' => ['0'],
				'1' => ['1'],
				'2' => ['2'],
			},
		],
		'/0/ /1/ /2/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'cat' )
		->insert( split //, 'dog' )
		->insert( split //, 'bird' )
		->insert( split //, 'worm' )
		->_reduce;
	cmp_deeply( $ra->_path,
		[
			{
				'b' => ['b','i','r','d'],
				'c' => ['c','a','t'],
				'd' => ['d','o','g'],
				'w' => ['w','o','r','m'],
			},
		],
		'/cat/ /dog/ /bird/ /worm/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'proamendment' )
		->insert( split //, 'proappropriation' )
		->insert( split //, 'proapproval' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			'p', 'r', 'o', 'a',
			{
				'm' => ['m','e','n','d','m','e','n','t'],
				'p' => ['p','p','r','o', {
						'p' => ['p','r','i','a','t','i','o','n'],
						'v' => ['v','a','l'],
					},
				],
			},
		],
		'/proamendment/ /proappropriation/ /proapproval/',
	);
}

{
	my $ra = Regexp::Assemble->new;
	$ra->insert( 0 )
		->insert( 1 )
		->insert( split //, 10 )
		->insert( split //, 100 )
		->_reduce;
	cmp_deeply( $ra->_path,
		[
			{
				'0' => ['0'],
				'1' => [
					'1', {
						''  => undef,
						'0' => [
							'0', {
								'' => undef,
								'0' => ['0'],
							},
						],
					}
				],
			},
		],
		'/0/ /1/ /10/ /100/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( 'c', 'a', 'b' )
		->insert( 'd', 'a', 'b' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'c' => ['c'],
				'd' => ['d'],
			},
			'a', 'b',
		],
		'/cab/ /dab/'
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( 'c', 'r', 'a', 'b' )
		->insert( 'd', 'a', 'b' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'c' => ['c', 'r'],
				'd' => ['d'],
			},
			'a', 'b',
		],
		'/crab/ /dab/'
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( 'd', 'a', 'b' )
		->insert( 'd', 'a', 'y' )
		->insert( 'd', 'a', 'i', 'l', 'y' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			'd', 'a',
			{
				'b' => ['b'],
				'i' => [
					{
						''  => undef,
						'i' => ['i', 'l'],
					},
					'y'
				],
			},
		],
		'/dab/ /day /daily/'
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( 'c', 'r', 'a', 'b' )
		->insert( 'd', 'a', 'b' )
		->insert( 'l', 'o', 'b' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'c' => [
					{
						'c' => ['c', 'r'],
						'd' => ['d'],
					},
					'a',
				],
				'l' => ['l', 'o'],
			},
			'b',
		],
		'/crab/ /dab/ /lob/'
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'hat' )
		->insert( split //, 'that' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'' => undef,
				't' => ['t'],
			},
			'h', 'a', 't',
		],
		'/hat/ /that/'
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'treat' )
		->insert( split //, 'threat' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			't',
			{
				'' => undef,
				'h' => ['h'],
			},
			'r', 'e', 'a', 't'
		],
		'/treat/ /threat/'
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'treat' )
		->insert( split //, 'threat' )
		->insert( split //, 'eat' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'' => undef,
				't' => [
					't',
					{
						'' => undef,
						'h' => ['h'],
					},
					'r',
				],
			},
			'e', 'a', 't'
		],
		'/eat/ /treat/ /threat/'
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'treat' )
		->insert( split //, 'threat' )
		->insert( split //, 'teat' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			't',
			{
				''  => undef,
				'h' => [
					{
						'h' => ['h'],
						''  => undef,
					},
					'r'
				],
			},
			'e', 'a', 't'
		],
		'/teat/ /treat/ /threat/'
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'grit' )
		->insert( split //, 'lit' )
		->insert( split //, 'limit' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'g' => [ 'g', 'r' ],
				'l' => [ 'l',
					{
						''  => undef,
						'i' => ['i', 'm'],
					},
				],
			},
			'i', 't'
		],
		'/grit/ /lit/ /limit/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'in' )
		->insert( split //, 'ban' )
		->insert( split //, 'ten' )
		->insert( split //, 'tent' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'b' => [
					{
						'i' => ['i'],
						'b' => ['b', 'a'],
					},
					'n',
				],
				't' => ['t', 'e', 'n',
					{
						''  => undef,
						't' => ['t'],
					}
				]
			}
		],
		'/in/ /ban/ /ten/ /tent/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( '' )
		->insert( split //, 'do' )
		->insert( split //, 'don' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				''  => undef,
				'd' => [  'd', 'o',
					{
						''  => undef,
						'n' => ['n'],
					},
				],
			}
		],
		'// /do/ /don/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'bf' )
		->insert( split //, 'cdf' )
		->insert( split //, 'cgf' )
		->insert( split //, 'cez' )
		->insert( split //, 'daf' )
		->insert( split //, 'dbf' )
		->insert( split //, 'dcf' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'b' => [
					{
						'b' => ['b'],
						'd' => ['d',
							{
								'a'=>['a'],
								'b'=>['b'],
								'c'=>['c'],
							},
						],
					},
					'f',
				],
				'c' => [ 'c', {
						'd' => [
							{
								'd' => ['d'],
								'g' => ['g'],
							},
							'f',
						],
						'e' => ['e', 'z'],
					}
				],
			}
		],
		'/bf/ /cdf/ /cgf/ /cez/ /daf/ /dbf/ /dcf/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'kids' )
		->insert( split //, 'acids' )
		->insert( split //, 'acidoids' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'k' => [ 'k' ],
				'a' => [ 'a', 'c',
					{
						'' => undef,
						'i' => ['i', 'd', 'o'],
					},
				],
			},
			'i', 'd', 's',
		],
		'/kids/ /acids/ /acidoids/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'schoolkids' )
		->insert( split //, 'acids' )
		->insert( split //, 'acidoids' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				's' => [ 's', 'c', 'h', 'o', 'o', 'l', 'k' ],
				'a' => [ 'a', 'c',
					{
						'' => undef,
						'i' => ['i', 'd', 'o'],
					},
				],
			},
			'i', 'd', 's',
		],
		'/schoolkids/ /acids/ /acidoids/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'skids' )
		->insert( split //, 'kids' )
		->insert( split //, 'acids' )
		->insert( split //, 'acidoids' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				's' => [
					{
						''  => undef,
						's' => ['s'],
					},
					'k',
				],
				'a' => [ 'a', 'c',
					{
						'' => undef,
						'i' => ['i', 'd', 'o'],
					},
				],
			},
			'i', 'd', 's',
		],
		'/skids/ /kids/ /acids/ /acidoids/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'skids' )
		->insert( split //, 'kids' )
		->insert( split //, 'acids' )
		->insert( split //, 'acidoids' )
		->insert( split //, 'schoolkids' )
		# ;$ra->debug(3);$ra
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				's' => [
					{
						''  => undef,
						's' => ['s',
							{
								''  => undef,
								'c' => ['c', 'h', 'o', 'o', 'l'],
							}
						],
					},
					'k',
				],
				'a' => [ 'a', 'c',
					{
						'' => undef,
						'i' => ['i', 'd', 'o'],
					},
				],
			},
			'i', 'd', 's',
		],
		'/skids/ /kids/ /acids/ /acidoids/ /schoolkids/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'showeriness' )
		->insert( split //, 'showerless' )
		->insert( split //, 'showiness' )
		->insert( split //, 'showless' )
		# ;$ra->debug(3);$ra
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			's', 'h', 'o', 'w',
			{
				''  => undef,
				'e' => ['e', 'r'],
			},
			{
				'i' => ['i', 'n'],
				'l' => ['l'],
			},
			'e', 's', 's'
		],
		'/showeriness/ /showerless/ /showiness/ /showless/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'gait' )
		->insert( split //, 'grit' )
		->insert( split //, 'blaze' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'b' => ['b', 'l', 'a', 'z', 'e'],
				'g' => ['g',
					{
						'a' => ['a'],
						'r' => ['r'],
					},
					'i', 't',
				],
			},
		],
		'/gait/ /grit/ /blaze/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'gait' )
		->insert( split //, 'grit' )
		->insert( split //, 'glaze' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			'g',
			{
				'l' => ['l', 'a', 'z', 'e'],
				'a' => [
					{
						'a' => ['a'],
						'r' => ['r'],
					},
					'i', 't',
				],
			},
		],
		'/gait/ /grit/ /glaze/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'gait' )
		->insert( split //, 'grit' )
		->insert( split //, 'graze' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			'g',
			{
				'r' => ['r',
					{
						'a' => ['a', 'z', 'e'],
						'i' => ['i', 't'],
					},
				],
				'a' => ['a', 'i', 't'],
			},
		],
		'/gait/ /grit/ /graze/',
	);
}

{
	my $node = [ 't', {
			'a' => ['a'],
			'i' => ['i'],
		},
		'b',
	];
	my $path = [ 't', {
			'a' => ['a'],
			'i' => ['i'],
		},
		's',
	];
	my $res = Regexp::Assemble::_insert( $node, 0, @$path );
	cmp_deeply( $res,
		[
			't',
			{
				'a' => ['a'],
				'i' => ['i'],
			},
			{
				'b' => ['b'],
				's' => ['s'],
			},
		],
		'_insert sit/sat -> bit/bat',
	) or print Dumper($res),"\n";
}

{
	my $node = [ 't', {
			'a' => ['a'],
			'i' => ['i'],
		},
		{
			'b' => ['b'],
			's' => ['s'],
		}
	];
	my $path = [ 't', {
			'a' => ['a'],
			'i' => ['i'],
		},
		'f',
	];
	my $res = Regexp::Assemble::_insert( $node, 0, @$path );
	cmp_deeply( $res,
		[
			't',
			{
				'a' => ['a'],
				'i' => ['i'],
			},
			{
				'b' => ['b'],
				'f' => ['f'],
				's' => ['s'],
			},
		],
		'_insert fit/fat -> sit/sat, bit/bat',
	) or print Regexp::Assemble::_dump($res), "\n";
}

{
	my $node = [ 't', {
			''  => undef,
			'a' => ['a'],
		},
		'e', 'b',
	];
	my $path = [ 't', {
			''  => undef,
			'a' => ['a'],
		},
		'e', 's',
	];
	my $res = Regexp::Assemble::_insert( $node, 0, @$path );
	cmp_deeply( $res,
		[
			't',
			{
				''  => undef,
				'a' => ['a'],
			},
			'e',
			{
				'b' => ['b'],
				's' => ['s'],
			},
		],
		'_insert seat/set -> beat/bet',
	);
}

{
	my $node = [ 'd', 'i',
		{
			''  => undef,
			'o' => ['o'],
		},
		't', 'y', 'd',
	];
	my $path = [ 'd', 'i',
		{
			''  => undef,
			'o' => ['o'],
		},
		't', 'a', 'b',
	];
	my $res = Regexp::Assemble::_insert( $node, 0, @$path );
	cmp_deeply( $res,
		[
			'd', 'i',
			{
				''  => undef,
				'o' => ['o'],
			},
			't',
			{
				'a' => ['a', 'b'],
				'y' => ['y', 'd'],
			},
		],
		'_insert dio?tyd -> dio?tab',
	) or print '# ', Regexp::Assemble::_dump( $res ). "\n";
}

{
	my $node = [ 'd', 'i',
		{
			''  => undef,
			'o' => ['o'],
		},
		't',
		{
			'a' => ['a', 'b'],
			'y' => ['y', 'd'],
		},
	];
	my $path = [ 'd', 'i',
		{
			''  => undef,
			'o' => ['o'],
		},
		't', 'm', 'x',
	];
	my $res = Regexp::Assemble::_insert( $node, 0, @$path );
	cmp_deeply( $res,
		[
			'd', 'i',
			{
				''  => undef,
				'o' => ['o'],
			},
			't',
			{
				'a' => ['a', 'b'],
				'm' => ['m', 'x'],
				'y' => ['y', 'd'],
			},
		],
		'_insert dio?tmx -> dio?t(ab|yd)',
	) or print '# ', Regexp::Assemble::_dump( $res ). "\n";
}

{
	my $node = [ 'd', 'i',
		{
			''  => undef,
			'o' => ['o'],
		},
		't',
		{
			'a' => ['a', 'b'],
			'y' => ['y', 'd'],
		},
	];
	my $path = [ 'd', 'i',
		{
			''  => undef,
			'o' => ['o'],
		},
		't', 'a', 'x',
	];
	my $res = Regexp::Assemble::_insert( $node, 0, @$path );
	cmp_deeply( $res,
		[
			'd', 'i',
			{
				''  => undef,
				'o' => ['o'],
			},
			't',
			{
				'a' => ['a',
					{
						'b' => ['b'],
						'x' => ['x'],
					}
				],
				'y' => ['y', 'd'],
			},
		],
		'_insert dio?tax -> dio?t(ab|yd)',
	) or print '# ', Regexp::Assemble::_dump( $res ). "\n";
}
{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'gait' )
		->insert( split //, 'grit' )
		->insert( split //, 'summit' )
		->insert( split //, 'submit' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'g' => ['g',
					{
						'a' => ['a'],
						'r' => ['r'],
					},
				],
				's' => [
					's', 'u',
					{
						'b' => ['b'],
						'm' => ['m'],
					},
					'm',
				],
			},
			'i', 't',
		],
		'/gait/ /grit/ /summit/ /submit/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'gait' )
		->insert( split //, 'grit' )
		->insert( split //, 'summit' )
		->insert( split //, 'submit' )
		->insert( split //, 'it' )
		->insert( split //, 'emit' )
		# ;$ra->debug(3);$ra
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				''  => undef,
				'g' => ['g',
					{
						'a' => ['a'],
						'r' => ['r'],
					},
				],
				'e' => [
					{
						'e' => ['e'],
						's' => ['s', 'u',
							{
								'b' => ['b'],
								'm' => ['m'],
							},
						],
					},
					'm',
				],
			},
			'i', 't',
		],
		'/gait/ /grit/ /summit/ /submit/ /it/ /emit/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'gait' )
		->insert( split //, 'grit' )
		->insert( split //, 'lit' )
		->insert( split //, 'limit' )
		# ;$ra->debug(3);$ra
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'g' => ['g',
					{
						'a' => ['a'],
						'r' => ['r'],
					},
				],
				'l' => [ 'l',
					{
						''  => undef,
						'i' => ['i','m'],
					},
				],
			},
			'i', 't',
		],
		'/gait/ /grit/ /lit/ /limit/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'gait' )
		->insert( split //, 'grit' )
		->insert( split //, 'bait' )
		->insert( split //, 'brit' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'b' => ['b'],
				'g' => ['g'],
			},
			{
				'a' => ['a'],
				'r' => ['r'],
			},
			'i', 't',
		],
		'/gait/ /grit/ /bait/ /brit/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'gait' )
		->insert( split //, 'grit' )
		->insert( split //, 'bebait' )
		->insert( split //, 'bait' )
		->insert( split //, 'brit' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'b' => ['b',
					{
						'e' => [
							{
								''  => undef,
								'e' => ['e','b'],
							},
							'a',
						],
						'r' => ['r'],
					},
				],
				'g' => ['g',
					{
						'a' => ['a'],
						'r' => ['r'],
					}
				]
			},
			'i', 't',
		],
		'/gait/ /grit/ /bait/ /bebait/ /brit/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'gait' )
		->insert( split //, 'grit' )
		->insert( split //, 'bait' )
		->insert( split //, 'brit' )
		->insert( split //, 'summit' )
		->insert( split //, 'submit' )
		->insert( split //, 'emit' )
		->insert( split //, 'transmit' )
		# ;$ra->debug(3);$ra
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'b' => [
					{
						'b' => ['b'],
						'g' => ['g'],
					},
					{
						'a' => ['a'],
						'r' => ['r'],
					},
				],
				'e' => [
					{
						'e' => ['e'],
						's' => ['s','u',{'b'=>['b'],'m'=>['m']}],
						't' => ['t','r','a','n','s'],
					},
					'm',
				],
			},
			'i', 't',
		],
		'/gait/ /grit/ /bait/ /brit/ /emit/ /summit/ /submit/ /transmit/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'lit' )
		->insert( split //, 'limit' )
		->insert( split //, 'commit' )
		->insert( split //, 'emit' )
		->insert( split //, 'transmit' )
		->_reduce
	;
	cmp_deeply( $ra->_path,
		[
			{
				'c' => [
					{
						'c' => ['c','o','m'],
						'e' => ['e'],
						't' => ['t','r','a','n','s'],
					},
					'm',
				],
				'l' => ['l',
					{
						''  => undef,
						'i' => ['i','m'],
					},
				],
			},
			'i', 't',
		],
		'/lit/ /limit/ /emit/ /commit/ /transmit/',
	);
}

{
	my $ra = Regexp::Assemble->new
		->insert( split //, 'apocryphal' )
		->insert( split //, 'apocrustic' )
		->insert( split //, 'apocrenic' )
		->_reduce
	;
	cmp_deeply( $ra->_path, 
		[
			'a','p','o','c','r',
			{
				'e' => [
					{
						'e' => ['e', 'n'],
						'u' => ['u', 's', 't'],
					},
					'i','c',
				],
				'y' => ['y','p','h','a','l'],
			},
		],
		'/apocryphal/ /apocrustic/ /apocrenic/',
	);
}

{
	my @list = qw/ den dent din dint ten tent tin tint /;
	my $ra = Regexp::Assemble->new;
	$ra->insert( split // ) for @list;
	$ra->_reduce;
	cmp_deeply( $ra->_path, [
			{
				'd' => ['d',
					{
						'e' => [ 'e', 'n', {
								''  => undef,
								't' => ['t'],
							},
						],
						'i' => [ 'i', 'n', {
								''  => undef,
								't' => ['t'],
							},
						],
					},
				],
				't' => ['t',
					{
						'e' => [ 'e', 'n', {
								''  => undef,
								't' => ['t'],
							},
						],
						'i' => [ 'i', 'n', {
								''  => undef,
								't' => ['t'],
							},
						],
					},
				],
			},
		],
		join( ' ', map { "/$_/" } @list ),
	);
}

{
	my @list = qw/ gait git grapefruit grassquit grit guitguit /;
	my $ra = Regexp::Assemble->new;
	$ra->insert( split // ) for @list;
	$ra->_reduce;
	cmp_deeply( $ra->_path,
		[ 'g',
			{ 
				''  => undef,
				'a' => ['a'],
				'r' => ['r',
					{
						''  => undef,
						'a' => ['a',
							{
								'p' => ['p','e','f','r'],
								's' => ['s','s','q'],
							},
							'u',
						],
					},
				],
				'u' => [ 'u','i','t','g','u'],
			},
			'i', 't'
		],
		join( ' ', map { "/$_/" } @list ),
	);
}

{
	my @list = qw/ gait gambit gaslit giggit git godwit goldtit goodwillit
		gowkit grapefruit grassquit grit guitguit /;
	my $ra = Regexp::Assemble->new;
	$ra->insert( split // ) for @list;
	$ra->_reduce;
	cmp_deeply( $ra->_path,
		[ 'g',
			{
				'a' => [ 'a',
					{
						''  => undef,
						'm' => ['m','b'],
						's' => ['s','l'],
					},
				],
				'i' => [
					{
						''  => undef,
						'i' => ['i','g','g'],
					}
				],
				'o' => [ 'o',
					{
						'd' => ['d','w'],
						'l' => ['l','d','t'],
						'o' => ['o','d','w','i','l','l'],
						'w' => ['w','k'],
					}
				],
				'r' => [ 'r',
					{
						''  => undef,
						'a' => ['a',
							{
								'p' => ['p','e','f','r'],
								's' => ['s','s','q'],
							},
							'u',
						],
					},
				],
				'u' => [ 'u','i','t','g','u'],
			},
			'i', 't'
		],
		join( ' ', map { "/$_/" } @list ),
	);
}

{
	my @list = qw/ lit limit lid livid /;
	my $ra = Regexp::Assemble->new;
	$ra->insert( split // ) for @list;
	$ra->_reduce;
	cmp_deeply( $ra->_path,
		[
			'l','i', {
				'm' => [
					{
						''  => undef,
						'm' => ['m','i'],
					},
					't'
				],
				'v' => [
					{
						''  => undef,
						'v' => ['v','i'],
					},
					'd'
				],
			},
		],
		join( ' ', map { "/$_/" } @list ),
	);
}

{
	my @list = qw/ theatre metre millimetre /;
	my $ra = Regexp::Assemble->new;
	$ra->insert( split // ) for @list;
	$ra->_reduce;
	cmp_deeply( $ra->_path,
		[
			{
				'm' => [
					{
						''  => undef,
						'm' => ['m','i','l','l','i'],
					},
					'm','e',
				],
				't' => ['t','h','e','a'],
			},
			't','r','e'
		],
		join( ' ', map { "/$_/" } @list ),
	);
}

{
	my @list = qw/ sad salad spread/;
	my $ra = Regexp::Assemble->new;
	$ra->insert( split // ) for @list;
	$ra->_reduce;
	cmp_deeply( $ra->_path,
		[
			's',
			{
				'a' => [
					{
						''  => undef,
						'a' => ['a','l'],
					},
				],
				'p' => ['p','r','e'],
			},
			'a','d',
		],
		join( ' ', map { "/$_/" } @list ),
	);
}

{
	my @list = qw/ tough trough though thorough /;
	my $ra = Regexp::Assemble->new;
	$ra->insert( split // ) for @list;
	$ra->_reduce;
	cmp_deeply( $ra->_path,
		[
			't',
			{
				''  => undef,
				'h' => ['h',
					{
						''  => undef,
						'o' => ['o','r'],
					}
				],
				'r' => ['r'],
			},
			'o','u','g','h',
		],
		join( ' ', map { "/$_/" } @list ),
	);
}

{
	my @list = qw/ tough though trough through thorough /;
	my $ra = Regexp::Assemble->new;
	$ra->insert( split // ) for @list;
	$ra->_reduce;
	cmp_deeply( $ra->_path,
		['t',
			{
				''  => undef,
				h   => [ 'h',
					{
						o => [
							{
								'' => undef,
								o  => ['o','r']
							}
						],
						r => ['r'],
					}
				],
				r => ['r'],
			},
			'o','u','g','h'
		],
		join( ' ', map { "/$_/" } @list ),
	);
}

{
	my @list = qw/ tit titanate titania titanite titano tite titi titian titien tittie /;
	my $ra = Regexp::Assemble->new;
	$ra->insert( split // ) for @list;
	$ra->_reduce;
	cmp_deeply( $ra->_path,
		['t','i','t',
			{
				''  => undef,
				'a' => [ 'a','n',
					{
						'a' => ['a','t','e'],
						'i' => ['i',
							{
								'a' => ['a'],
								't' => ['t','e']
							}
						],
						'o' => ['o']
					}
				],
				'i' => [ 'i',
					{
						''  => undef,
						'a' => [
							{
								'e' => ['e'],
								'a' => ['a']
							},
							'n'
						]
					}
				],
				't' => [
					{
						''  => undef,
						't' => ['t','i']
					},
					'e'
				]
			}
		],
		join( ' ', map { "/$_/" } @list ),
	);
}


} # SKIP:
