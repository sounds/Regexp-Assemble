# 01_insert.t
#
# Test suite for Regexp::Assemble
#
# When a series of paths are inserted in an R::A object, they are
# stored into tree structure using a crafty blend of arrays and hashes.
# 
# These tests verify that the tokens that are added to the
# Regexp::Assemble object are stored correctly.
#
# The tests here verify to a much greater extent that the tree/hash structure
# built up from repeated add() calls produce a structure that the
# subsequent coalescing and reduction routines can operate upon correctly.
#
# copyright (C) 2004-2005 David Landgren

use strict;
use Regexp::Assemble;

use constant permute_testcount => 120 * 5; # permute() has 120 (5!) variants

use Test::More tests => 44 + permute_testcount;

#eval { require Test::Differences; import Test::Differences };
#if( $@ ) {
#	*identical = *is_deeply;
#}
#else {
#	*identical = *eq_or_diff;
#}

*identical = *is_deeply;

identical( Regexp::Assemble->new->insert->_path, [{'' => undef}], 'insert()' );

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( '' );
    my $r = ($rt->_path)->[0];
    ok( ref($r) eq 'HASH',  q{'' => first element is a HASH} );
    ok( keys %$r == 1,      q{'' => ...and contains one key} );
    ok( exists $r->{''},    q{'' => ...which is an empty string} );
    ok( !defined($r->{''}), q{'' => ...and points to undef} );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( 'a' );
    my $r = $rt->_path;
    ok( scalar @$r == 1,  q{'a' => path of length 1} );
    ok( $r->[0] eq 'a',   q{'a' => ...and is an 'a'} );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( 'a', 'b' );
    my $r = $rt->_path;
    ok( scalar @$r == 2,  q{'ab' => path of length 2} );
    ok( join( '' => @$r ) eq 'ab', q{'ab' => ...and is 'a', 'b'} );
	cmp_ok( $rt->dump, 'eq', '[a b]', 'dump([a b])' );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( 'a', 'b' );
    $rt->insert( 'a', 'c' );
	cmp_ok( $rt->dump, 'eq', '[a {b=>[b] c=>[c]}]', 'dump([a {b c}])' );
    my $r = $rt->_path;
    ok( scalar @$r == 2,        q{'ab,ac' => path of length 2} );
    ok( $r->[0] eq 'a',         q{'ab,ac' => ...and first atom is 'a'} );
    ok( ref($r->[1]) eq 'HASH', q{'ab,ac' => ...and second is a node} );
    $r = $r->[1];
    ok( keys %$r == 2,          q{'ab,ac' => ...node has two keys} );
    ok( join( '' => sort keys %$r ) eq 'bc',
        q{'ab,ac' => ...keys are 'b','c'} );
    ok( (exists $r->{b} and ref($r->{b}) eq 'ARRAY'),
        q{'ab,ac' => ... key 'b' exists and points to a path} );
    ok( (exists $r->{c} and ref($r->{c}) eq 'ARRAY'),
        q{'ab,ac' => ... key 'c' exists and points to a path} );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( undef );
    identical( $rt->_path,
        [],
        '// (from undef)'
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( '' );
    identical( $rt->_path,
        [{'' => undef}],
        q{// (from '')},
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( '0' );
    identical( $rt->_path,
        [0],
        q{/0/},
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/d/ );
    identical( $rt->_path,
        ['d'],
        '/d/',
    );
}

{
    my $r = Regexp::Assemble->new->lex( '\w' );
    $r->add( 'ab12-xy' );
    identical( $r->_path,
        [ 'a', 'b', '1', '2', '-', 'x', 'y' ],
        'ab12-xy (with /\w/ lexer)'
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/d a b/ );
    identical( $rt->_path,
        [qw/d a b/],
        '/dab/',
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/0 1/ );
    $rt->insert( qw/0 2/ );
    identical( $rt->_path,
        [
            '0',
            {
                '1' => ['1'],
                '2' => ['2'],
            },
        ],
        '/01/ /02/',
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/0/ );
    $rt->insert( qw/0 1/ );
    $rt->insert( qw/0 2/ );
    identical( $rt->_path,
        [
            '0',
            {
                '1' => ['1'],
                '2' => ['2'],
                ''  => undef,
            },
        ],
        '/0/ /01/ /02/',
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/d a m/ );
    $rt->insert( qw/d a m/ );
    identical( $rt->_path,
        [
            'd', 'a', 'm',
        ],
        '/dam/ x 2',
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/d a m/ );
    $rt->insert( qw/d a/ );
    $rt->insert( qw/d a/ );
    identical( $rt->_path,
        [
            'd', 'a',
            {
                'm' => ['m'],
                ''  => undef,
            },
        ],
        '/dam/, /da/ x 2',
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/d a m/ );
    $rt->insert( qw/d a/ );
    $rt->insert( qw/d/ );
    identical( $rt->_path,
        [
            'd',
            {
                'a' => [
                    'a',
                    {
                        'm' => ['m'],
                        ''  => undef,
                    },
                ],
                '' => undef,
            },
        ],
        '/dam/ /da/ /d/',
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/d a b/ );
    $rt->insert( qw/d a m/ );
    identical( $rt->_path,
        [
            'd', 'a',
            {
                'b' => ['b'],
                'm' => ['m'],
            },
        ],
        '/dab/ /dam/',
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/d a r t/ );
    $rt->insert( qw/d a m p/ );
    identical( $rt->_path,
        [
            'd', 'a',
            {
                'r' => ['r', 't'],
                'm' => ['m', 'p'],
            },
        ],
        '/dart/ /damp/',
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/a m b l e/ );
    $rt->insert( qw/i d l e/ );
    identical( $rt->_path,
        [
            {
                'a' => ['a', 'm', 'b', 'l', 'e'],
                'i' => ['i', 'd', 'l', 'e'],
            },
        ],
        '/amble/ /idle/',
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/a m b l e/ );
    $rt->insert( qw/a m p l e/ );
    $rt->insert( qw/i d l e/ );
    identical( $rt->_path,
        [
            {
                'a' => [
                    'a', 'm',
                    {
                        'b' => [ 'b', 'l', 'e' ],
                        'p' => [ 'p', 'l', 'e' ],
                    },
                ],
                'i' => ['i', 'd', 'l', 'e'],
            },
        ],
        '/amble/ /ample/ /idle/',
    );
}

{
    my $rt = Regexp::Assemble->new;
    $rt->insert( qw/d a m/ );
    $rt->insert( qw/d a r e/ );
    identical( $rt->_path,
        [
            'd', 'a',
            {
                'm' => ['m'],
                'r' => ['r', 'e'],
                    ,
            },
        ],
        '/dam/ /dare/',
    );
}

{
    my $rt = Regexp::Assemble->new
        ->insert(qw/d a/)
        ->insert(qw/d b/)
        ->insert(qw/d c/)
    ;
    identical( $rt->_path,
        [
            'd',
            {
                'a' => ['a'],
                'b' => ['b'],
                'c' => ['c'],
            },
        ],
        '/da/ /db/ /dc/',
    );
}

{
    my $rt = Regexp::Assemble->new
        ->insert(qw/d a/)
        ->insert(qw/d b c d/)
        ->insert(qw/d c/)
    ;
    identical( $rt->_path,
        [
            'd',
            {
                'a' => ['a'],
                'b' => ['b', 'c', 'd'],
                'c' => ['c'],
            },
        ],
        '/da/ /dbcd/ /dc/',
    );
}

sub permute {
    my $target = shift;
    my $path   = shift;
    my( $x1, $x2, $x3, $x4, $x5 );
    for $x1( 0..4 ) {
        for $x2( 0..4 ) {
            next if $x2 == $x1;
            for $x3( 0..4 ) {
                next if grep { $_ == $x3 } ($x1, $x2);
                for $x4( 0..4 ) {
                    next if grep { $_ == $x4 } ($x1, $x2, $x3);
                    for $x5( 0..4 ) {
                        next if grep { $_ == $x5 } ($x1, $x2, $x3, $x4);
                        my $rt = Regexp::Assemble->new
                            ->insert( @{$path->[$x1]} )
                            ->insert( @{$path->[$x2]} )
                            ->insert( @{$path->[$x3]} )
                            ->insert( @{$path->[$x4]} )
                            ->insert( @{$path->[$x5]} )
                        ;
                        identical( $rt->_path, $target,
                            '/' . join( '/ /', 
                                join( '' => @{$path->[$x1]}),
                                join( '' => @{$path->[$x2]}),
                                join( '' => @{$path->[$x3]}),
                                join( '' => @{$path->[$x4]}),
                                join( '' => @{$path->[$x5]}),
                            ) . '/'
                        ) or diag(
							$rt->dump(),
							' versus ',
							Regexp::Assemble->_dump($target),
							"\n",
						);
                    }
                }
            }
        }
    }
}

permute(
    [
        'a', {
            '' => undef, 'b' => [
                'b', {
                    '' => undef, 'c' => [
                        'c', {
                            '' => undef, 'd' => [
                                'd', {
                                    '' => undef, 'e' => [
                                        'e',
                                    ],
                                },
                            ],
                        },
                    ],
                },
            ],
        },
    ],
    [
        [ 'a',                    ],
        [ 'a', 'b'                ],
        [ 'a', 'b', 'c'           ],
        [ 'a', 'b', 'c', 'd'      ],
        [ 'a', 'b', 'c', 'd', 'e' ],
    ]
);

permute(
    [
        {
            '' => undef, 'a' => [
                'a', {
                    '' => undef, 'b' => [
                        'b', {
                            '' => undef, 'c' => [
                                'c', {
                                    '' => undef, 'd' => [
                                        'd',
                                    ],
                                },
                            ],
                        },
                    ],
                },
            ],
        },
    ],
    [
        [ '',                ],
        [ 'a',               ],
        [ 'a', 'b'           ],
        [ 'a', 'b', 'c'      ],
        [ 'a', 'b', 'c', 'd' ],
    ]
);

permute(
    [ 'd', 'o',
    {
        'n' => [
            'n', 'a', 't',
            {
                'e' => ['e'],
                'i' => ['i', 'o', 'n'],
            },
        ]
        ,
        't' => [
            't',
            {
                'a' => ['a', 't', 'e'],
                'i' => ['i', 'n', 'g'],
            },
        ],
        ,
        '' => undef,
    }],
    [
        [ split //, 'do'       ],
        [ split //, 'donate'   ],
        [ split //, 'donation' ],
        [ split //, 'dotate'   ],
        [ split //, 'doting'   ],
    ]
);

permute(
    [
        'o',
        {
            ''  => undef,
            'n' => [
                'n', {
                    ''  => undef,
                    'l' => ['l', 'y'],
                    'e' => [
                        'e', {
                            ''  => undef,
                            'r' => ['r'],
                        }
                    ],
                },
            ],
        },
    ],
    [
        [ split //, 'o'    ],
        [ split //, 'on'   ],
        [ split //, 'one'  ],
        [ split //, 'only' ],
        [ split //, 'oner' ],
    ],
);

permute(
    [
        'a', 'm',
        {
            'a' => [ 'a',
                {
                    's' => ['s', 's'],
                    'z' => ['z', 'e'],
                },
            ],
            'u' => [ 'u',
                {
                    'c' => ['c', 'k'],
                    's' => ['s', 'e'],
                }
            ],
            'b' => [ 'b', 'l', 'e' ],
        },
    ],
    [
        [ split //, 'amass' ],
        [ split //, 'amaze' ],
        [ split //, 'amble' ],
        [ split //, 'amuck' ],
        [ split //, 'amuse' ],
    ],
);

my $rx = Regexp::Assemble->new( lex => '(?:\d+|.)' );
$rx->add( 'ab1' );
$rx->add( 'ab123' );
identical( $rx->_path,
	[ 'a', 'b', { '1' => ['1'], '123' => ['123'] }],
	'/\\d+|./ new lexer'
);

Regexp::Assemble::Default_Lexer('.');

my $r1 = Regexp::Assemble->new;
$r1->add( '\\d+' );
identical( $r1->_path,
	[ '\\', 'd', '+' ],
	'\\d+ (with /./ lexer)'
);

my $r2 = Regexp::Assemble->new;
$r2->add( 'a[bc]' );
identical( $r2->_path,
	[ 'a', '[', 'b', 'c', ']' ],
	'a[bc] (with /./ lexer)'
);

$r2->lex('\\d')->reset()->add( '123abc456' );
identical( $r2->_path,
	[ '1', '2', '3', 'abc', '4', '5', '6' ],
	'123abc456 (with /\\d/ lexer)'
);

$r2->reset()->add( '123abc' );
identical( $r2->_path,
	[ '1', '2', '3', 'abc', ],
	'123abc (with /\\d/ lexer)'
);

$r2->reset()->add( 'abc123' );
identical( $r2->_path,
	[ 'abc', '1', '2', '3', ],
	'abc123 (with /\\d/ lexer)'
);

eval { $r2->filter('choke') };
ok( $@, 'die on non-CODE filter' );

eval { $r2->pre_filter('choke') };
ok( $@, 'die on non-CODE pre_filter' );
