# 00_basic.t
#
# Test suite for Regexp::Assemble
# Make sure the basic stuff works
#
# The fact that many of these tests access object internals directly
# does not constitute a coding recommendation.
#
# copyright (C) 2004-2005 David Landgren

use strict;

eval qq{use Test::More tests => 314 };
if( $@ ) {
    warn "# Test::More not available, no tests performed\n";
    print "1..1\nok 1\n";
    exit 0;
}

use Regexp::Assemble;

my $fixed = 'The scalar remains the same';
$_ = $fixed;

diag( "testing Regexp::Assemble v$Regexp::Assemble::VERSION" );

my $rt = Regexp::Assemble->new;
ok( defined($rt), 'new() defines something' );
is( ref($rt), 'Regexp::Assemble', 'new() returns a Regexp::Assemble object' );

cmp_ok( length(Regexp::Assemble::Default_Lexer), '>', 0,
    'default lexer is something' );

cmp_ok( ref( $rt->_path ), 'eq', 'ARRAY', '_path() isa ARRAY' );
cmp_ok( scalar @{$rt->_path}, '==', 0, '_path() is empty' );

{
    my $r = Regexp::Assemble->new( chomp => 1 );
    is( $r->{chomp}, 1, 'chomp new(1)' );
    $r->chomp( 0 );
    is( $r->{chomp}, 0, 'chomp(0)' );
    $r->chomp();
    is( $r->{chomp}, 1, 'chomp()' );
}

{
    my $r = Regexp::Assemble->new( indent => 1 );
    is( $r->{indent}, 1, 'indent new(1)' );
    $r->indent( 4 );
    is( $r->{indent}, 4, 'indent(4)' );
    $r->indent();
    is( $r->{indent}, 0, 'indent()' );
}

{
    my $r = Regexp::Assemble->new( reduce => 1 );
    is( $r->{reduce}, 1, 'reduce new(1)' );
    $r->reduce( 0 );
    is( $r->{reduce}, 0, 'reduce(0)' );
    $r->reduce();
    is( $r->{reduce}, 1, 'reduce()' );
}

{
    my $r = Regexp::Assemble->new( mutable => 1 );
    is( $r->{mutable}, 1, 'mutable new(1)' );
    $r->mutable( 0 );
    is( $r->{mutable}, 0, 'mutable(0)' );
    $r->mutable();
    is( $r->{mutable}, 1, 'mutable()' );
}

{
    my $r = Regexp::Assemble->new( flags => 'i' );
    is( $r->{flags}, 'i', 'flags new(i)' );
    $r->flags( 'sx' );
    is( $r->{flags}, 'sx', 'flags(sx)' );
    $r->flags( '' );
    is( $r->{flags}, '', q{flags('')} );
    $r->flags( 0 );
    is( $r->{flags}, '0', 'flags(0)' );
    $r->flags();
    is( $r->{flags}, '', q{flags()} );
}

{
    my $r = Regexp::Assemble->new( track => 2 );
    is( $r->{track}, 2, 'track new(n)' );
    $r->track( 0 );
    is( $r->{track}, 0, 'track(0)' );
    $r->track( 1 );
    is( $r->{track}, 1, 'track(1)' );
    $r->track( 0 );
    is( $r->{track}, 0, 'track(0) 2nd' );
    $r->track();
    is( $r->{track}, 1, 'track()' );
}

{
    my $r = Regexp::Assemble->new( mutable => 2 );
    is( $r->{mutable}, 2, 'mutable new(n)' );
    $r->mutable( 0 );
    is( $r->{mutable}, 0, 'track(0)' );
}

{
    my $r = Regexp::Assemble->new( reduce => 2 );
    is( $r->{reduce}, 2, 'reduce new(n)' );
    $r->reduce( 0 );
    is( $r->{reduce}, 0, 'reduce(0)' );
}

{
    my $r = Regexp::Assemble->new( debug => 15 );
    is( $r->{debug}, 15, 'debug new(n)' );
    $r->debug( 0 );
    is( $r->{debug}, 0, 'debug(0)' );
    $r->debug( 4 );
    is( $r->{debug}, 4, 'debug(4)' );
    $r->debug();
    is( $r->{debug}, 0, 'debug()' );
}

{
    my $r = Regexp::Assemble->new( pre_filter => sub { undef } );
    cmp_ok( ref($r->{pre_filter}), 'eq', 'CODE', 'pre_filter new(n)' );
    $r->pre_filter( undef );
    ok( !defined $r->{pre_filter}, 'pre_filter(0)' );
}

{
    my $r = Regexp::Assemble->new( filter => sub { undef } );
    cmp_ok( ref($r->{filter}), 'eq', 'CODE', 'filter new(n)' );
    $r->filter( undef );
    ok( !defined $r->{filter}, 'filter(0)' );
}

cmp_ok( Regexp::Assemble::_node_key(
        { a => 1, b=>2, c=>3 }
    ), 'eq', 'a', '_node_key(1)'
);

cmp_ok( Regexp::Assemble::_node_key(
        { b => 3, c=>2, z=>1 }
    ), 'eq', 'b', '_node_key(2)'
);

cmp_ok( Regexp::Assemble::_node_key(
        { a => 1, 'a.' => 2, b => 3 }
    ), 'eq', 'a', '_node_key(3)'
);

cmp_ok( Regexp::Assemble::_node_key(
        { '' => undef, a => 1, 'a.' => 2, b => 3 }
    ), 'eq', 'a', '_node_key(4)'
);

cmp_ok( Regexp::Assemble::_node_key(
        { '' => undef, abc => 1, def => 2, g => 3 }
    ), 'eq', 'abc', '_node_key(5)'
);

cmp_ok( Regexp::Assemble::_node_offset(
        [ 'a', 'b', '\\d+', 'e', '\\d' ]
    ), '==', -1, '_node_offset(1)'
);

cmp_ok( Regexp::Assemble::_node_offset(
        [ {x => ['x'], '' => undef}, 'a', 'b', '\\d+', 'e', '\\d' ]
    ), '==', 0, '_node_offset(2)'
);

cmp_ok( Regexp::Assemble::_node_offset(
        [ 'a', 'b', '\\d+', 'e', {a => 1, b => 2}, 'x', 'y', 'z' ]
    ), '==', 4, '_node_offset(3)'
);

cmp_ok( Regexp::Assemble::_node_offset(
        [ { z => 1, x => 2 }, 'b', '\\d+', 'e', {a => 1, b => 2}, 'z' ]
    ), '==', 0, '_node_offset(4)'
);

cmp_ok( Regexp::Assemble::_node_offset(
        [ [ 1, 2, 3, {a => ['a'], b=>['b']} ], 'a', { z => 1, x => 2 } ]
    ), '==', 2, '_node_offset(5)'
);

cmp_ok( Regexp::Assemble::_node_eq(     {},     {}), '==', 1, '{} eq {}');
cmp_ok( Regexp::Assemble::_node_eq(  undef,     {}), '==', 0, 'undef ne {}');
cmp_ok( Regexp::Assemble::_node_eq(     {},  undef), '==', 0, '{} ne undef');
cmp_ok( Regexp::Assemble::_node_eq(  undef,  undef), '==', 0, 'undef ne undef');
cmp_ok( Regexp::Assemble::_node_eq(     [],     []), '==', 1, '[] eq []');
cmp_ok( Regexp::Assemble::_node_eq(     [],     {}), '==', 0, '[] ne {}'); 
cmp_ok( Regexp::Assemble::_node_eq(     {},     []), '==', 0, '{} ne []');
cmp_ok( Regexp::Assemble::_node_eq(    [0],    [0]), '==', 1, 'eq [0]');
cmp_ok( Regexp::Assemble::_node_eq([0,1,2],[0,1,2]), '==', 1, 'eq [0,1,2]');
cmp_ok( Regexp::Assemble::_node_eq([0,1,2],[0,1,3]), '==', 0, 'ne [0,1,2]');
cmp_ok( Regexp::Assemble::_node_eq(  [1,2],[0,1,2]), '==', 0, 'ne [1,2]');

cmp_ok( Regexp::Assemble::_node_eq(
        {'a'=>['a','b']},
        {'a'=>['a','b']},
    ), '==', 1, 'eq {a}'
);

cmp_ok( Regexp::Assemble::_node_eq(
        {'a'=>['a','b']},
        {'a'=>['a','b'], '' => undef},
    ), '==', 0, 'ne {a}'
);

cmp_ok( Regexp::Assemble::_node_eq(
        {'a'=>['a','b'], 'b'=>['b','c']},
        {'a'=>['a','b'], 'b'=>['b','c']},
    ), '==', 1, 'eq {a,b}'
);

cmp_ok( Regexp::Assemble::_node_eq(
        {'a'=>['a','b'], 'b'=>['b','c']},
        {'a'=>['a','b'], 'b'=>['b','d']},
    ), '==', 0, 'ne {a,b}'
);

cmp_ok( Regexp::Assemble::_node_eq(
        [{'a'=>['a','b'], 'b'=>['b','c']}, {'z'=>['z','y'], 'm'=>['m','n']}],
        [{'a'=>['a','b'], 'b'=>['b','c']}, {'z'=>['z','y'], 'm'=>['m','n']}],
    ), '==', 1, 'eq {a,b},{z,m}'
);

cmp_ok( Regexp::Assemble::_node_eq(
        [{'a'=>['a','b'], 'b'=>['b','c']}, {'z'=>['z','y'], 'm'=>['m','n']}],
        [{'a'=>['a','b'], 'b'=>['b','c']}, {'z'=>['z','y'], 'm'=>['m','n','o']}],
    ), '==', 0, 'ne {a,b},{z,m}'
);

cmp_ok( Regexp::Assemble::_node_eq(
        {''=>undef, 'a'=>['a','b']},
        {''=>undef, 'a'=>['a','b']},
    ), '==', 1, '{eq {* a}'
);

cmp_ok( Regexp::Assemble::_node_eq(
        {''=>undef, 'a'=>['a','b']},
        {''=>undef, 'a'=>['a','b','c']},
    ), '==', 0, '{ne {* a}'
);

cmp_ok( Regexp::Assemble::_node_eq(
        ['z','\\d+', {'a'=>['a','b']}],
        ['z','\\d+', {'a'=>['a','b']}],
    ), '==', 1, 'eq [z \d+ {a}]'
);

cmp_ok( Regexp::Assemble::_node_eq(
        ['z','\\d+', {'a'=>['a','b'], 'z'=>['z','y','x']}],
        ['z','\\d+', {'a'=>['a','b'], 'z'=>['z','y','x']}],
    ), '==', 1, 'eq [z \d+ {a,z}]'
);

cmp_ok( Regexp::Assemble::_make_class( qw/ a b c / ),
    'eq', '[abc]', '_make_class a b c'
);

cmp_ok( Regexp::Assemble::_make_class( qw/ a a c / ),
    'eq', '[ac]', '_make_class a a c'
);

cmp_ok( Regexp::Assemble::_make_class( qw/ 0 1 2 / ),
    'eq', '[012]', '_make_class 0 1 2'
);

cmp_ok( Regexp::Assemble::_make_class( qw/ 0 1 2 3 4 5 6 7 8 9 / ),
    'eq', '\\d', '_make_class 0 1 ... 9'
);

cmp_ok( Regexp::Assemble::_make_class( '\\d', '\\D' ),
    'eq', '.', '_make_class \\d \\D'
);

cmp_ok( Regexp::Assemble::_make_class( '\\s', '\\S' ),
    'eq', '.', '_make_class \\s \\S'
);

cmp_ok( Regexp::Assemble::_make_class( '\\w', '\\W' ),
    'eq', '.', '_make_class \\w \\W'
);

cmp_ok( Regexp::Assemble::_make_class( '\\d', qw/5 a / ),
    'eq', '[\\da]', '_make_class \\d 5 a'
);

cmp_ok( Regexp::Assemble::_make_class( qw/ a z - / ),
    'eq', '[-az]', '_make_class a z -'
);

cmp_ok( Regexp::Assemble::_make_class( qw/ a z ^ / ),
    'eq', '[az^]', '_make_class a z ^'
);

cmp_ok( Regexp::Assemble::_make_class( qw/ a z ^ - / ),
    'eq', '[-az^]', '_make_class a z ^ -'
);

cmp_ok( Regexp::Assemble::_make_class( '\\.', '\\+' ),
    'eq', '[+.]', '_make_class \\. \\+'
);


sub xcmp {
    my $r = Regexp::Assemble->new;
    is_deeply(
        $r->_lex( $_[0] ), [ $_[1] ],
        sprintf( '_lex \\x%02x', ord( $_[0] ))
    );
}

xcmp( '\x20', ' ' );
xcmp( '\x21', '!' );
xcmp( '\x22', '"' );
xcmp( '\x23', '#' );
xcmp( '\x24', '\\$' );
xcmp( '\x25', '%' );
xcmp( '\x26', '&' );
xcmp( '\x27', q{'} );
xcmp( '\x28', '\\(' );
xcmp( '\x29', '\\)' );
xcmp( '\x2a', '\*' );
xcmp( '\x2b', '\+' );
xcmp( '\x2c', ',' );
xcmp( '\x2d', '-' );
xcmp( '\x2e', '\\.' );
xcmp( '\x2f', '\/' );
xcmp( '\x30', '0' );
xcmp( '\x3a', ':' );
xcmp( '\x3b', ';' );
xcmp( '\x3c', '<' );
xcmp( '\x3d', '=' );
xcmp( '\x3e', '>' );
xcmp( '\x3f', '\\?' );
xcmp( '\x40', '\\@' );
xcmp( '\x41', 'A' );

xcmp( '\x5a', 'Z' );
xcmp( '\x5b', '\\[' );
xcmp( '\x5c', '\\\\' );
xcmp( '\x5d', '\\]' );
xcmp( '\x5e', '\\^' );
xcmp( '\x5f', '_' );
xcmp( '\x60', '`' );
xcmp( '\x61', 'a' );
xcmp( '\x7a', 'z' );
xcmp( '\x7b', '\{' );
xcmp( '\x7c', '\|' );
xcmp( '\x7d', '}' );
xcmp( '\x7e', '~' );
xcmp( '\x7f', '' );

sub lcmp {
    is_deeply(
        Regexp::Assemble->new->_lex( $_[0] ),
        [ $_[0] ],
        "_lex $_[0] source line $_[1]" 
    );
}

lcmp( 'X?', __LINE__ );
lcmp( '\\?', __LINE__ );
lcmp( '\\+', __LINE__ );
lcmp( '\\*', __LINE__ );
lcmp( '\\@', __LINE__ );
lcmp( '\\.', __LINE__ );
lcmp( '\\(', __LINE__ );
lcmp( '\\)', __LINE__ );
lcmp( '\\[', __LINE__ );
lcmp( '\\]', __LINE__ );
lcmp( '\\|', __LINE__ );

lcmp( 'X??', __LINE__ );
lcmp( '\\??', __LINE__ );
lcmp( '\\+?', __LINE__ );
lcmp( '\\*?', __LINE__ );
lcmp( '\\@?', __LINE__ );
lcmp( '\\.?', __LINE__ );
lcmp( '\\(?', __LINE__ );
lcmp( '\\)?', __LINE__ );
lcmp( '\\[?', __LINE__ );
lcmp( '\\]?', __LINE__ );
lcmp( '\\|?', __LINE__ );

lcmp( 'X+?', __LINE__ );
lcmp( '\\?+?', __LINE__ );
lcmp( '\\++?', __LINE__ );
lcmp( '\\*+?', __LINE__ );
lcmp( '\\@+?', __LINE__ );
lcmp( '\\.+?', __LINE__ );
lcmp( '\\(+?', __LINE__ );
lcmp( '\\)+?', __LINE__ );
lcmp( '\\[+?', __LINE__ );
lcmp( '\\]+?', __LINE__ );
lcmp( '\\|+?', __LINE__ );

lcmp( 'X{2}', __LINE__ );
lcmp( '\\?{2}', __LINE__ );
lcmp( '\\+{2}', __LINE__ );
lcmp( '\\*{2}', __LINE__ );
lcmp( '\\@{2}', __LINE__ );
lcmp( '\\.{2}', __LINE__ );
lcmp( '\\({2}', __LINE__ );
lcmp( '\\){2}', __LINE__ );
lcmp( '\\[{2}', __LINE__ );
lcmp( '\\]{2}', __LINE__ );
lcmp( '\\|{2}', __LINE__ );

lcmp( 'X{2}?', __LINE__ );
lcmp( '\\?{2}?', __LINE__ );
lcmp( '\\+{2}?', __LINE__ );
lcmp( '\\*{2}?', __LINE__ );
lcmp( '\\@{2}?', __LINE__ );
lcmp( '\\.{2}?', __LINE__ );
lcmp( '\\({2}?', __LINE__ );
lcmp( '\\){2}?', __LINE__ );
lcmp( '\\[{2}?', __LINE__ );
lcmp( '\\]{2}?', __LINE__ );
lcmp( '\\|{2}?', __LINE__ );

lcmp( 'X{2,}', __LINE__ );
lcmp( '\\?{2,}', __LINE__ );
lcmp( '\\+{2,}', __LINE__ );
lcmp( '\\*{2,}', __LINE__ );
lcmp( '\\@{2,}', __LINE__ );
lcmp( '\\.{2,}', __LINE__ );
lcmp( '\\({2,}', __LINE__ );
lcmp( '\\){2,}', __LINE__ );
lcmp( '\\[{2,}', __LINE__ );
lcmp( '\\]{2,}', __LINE__ );
lcmp( '\\|{2,}', __LINE__ );

lcmp( 'X{2,}?', __LINE__ );
lcmp( '\\?{2,}?', __LINE__ );
lcmp( '\\+{2,}?', __LINE__ );
lcmp( '\\*{2,}?', __LINE__ );
lcmp( '\\@{2,}?', __LINE__ );
lcmp( '\\.{2,}?', __LINE__ );
lcmp( '\\({2,}?', __LINE__ );
lcmp( '\\){2,}?', __LINE__ );
lcmp( '\\[{2,}?', __LINE__ );
lcmp( '\\]{2,}?', __LINE__ );
lcmp( '\\|{2,}?', __LINE__ );

lcmp( 'X{2,4}', __LINE__ );
lcmp( '\\?{2,4}', __LINE__ );
lcmp( '\\+{2,4}', __LINE__ );
lcmp( '\\*{2,4}', __LINE__ );
lcmp( '\\@{2,4}', __LINE__ );
lcmp( '\\.{2,4}', __LINE__ );
lcmp( '\\({2,4}', __LINE__ );
lcmp( '\\){2,4}', __LINE__ );
lcmp( '\\[{2,4}', __LINE__ );
lcmp( '\\]{2,4}', __LINE__ );
lcmp( '\\|{2,4}', __LINE__ );

lcmp( 'X{2,4}?', __LINE__ );
lcmp( '\\?{2,4}?', __LINE__ );
lcmp( '\\+{2,4}?', __LINE__ );
lcmp( '\\*{2,4}?', __LINE__ );
lcmp( '\\@{2,4}?', __LINE__ );
lcmp( '\\.{2,4}?', __LINE__ );
lcmp( '\\({2,4}?', __LINE__ );
lcmp( '\\){2,4}?', __LINE__ );
lcmp( '\\[{2,4}?', __LINE__ );
lcmp( '\\]{2,4}?', __LINE__ );
lcmp( '\\|{2,4}?', __LINE__ );

{
    my $r = Regexp::Assemble->new;
    is_deeply( Regexp::Assemble->new->_lex( '' ), [], '_lex empty string' );

    my $str = 'abc';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'a', 'b', 'c' ], "_lex $str",);

    $str = 'a+b*c?';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ 'a+', 'b*', 'c?' ],
        "_lex $str",
    );

    $str = '\e\t\cb\cs';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ '\e', '\t', '\cb', '\cs' ],
        "_lex $str",
    );

    $str = 'a+\\d+';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ 'a+', '\\d+' ],
        "_lex $str",
    );

    $str = 'a/b';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ 'a', '\\/', 'b' ],
        "_lex $str",
    );

    $str = 'a+?b*?c??';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ 'a+?', 'b*?', 'c??' ],
        "_lex $str",
    );

    $str = 'abc[def]g';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ 'a', 'b', 'c', '[def]', 'g' ],
        "_lex $str",
    );

    $str = '(?:ab)?c[def]+g';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ '(?:ab)?', 'c', '[def]+', 'g' ],
        "_lex $str",
    );

    $str = '(?:ab)?c[def]{2,7}?g';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ '(?:ab)?', 'c', '[def]{2,7}?', 'g' ],
        "_lex $str",
    );

    $str = 'abc[def]g(?:hi[jk]lm[no]p)';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ 'a', 'b', 'c', '[def]', 'g', '(?:hi[jk]lm[no]p)' ],
        "_lex $str",
    );

    $str = 'abc[def]g[,.%\\]$&].\\.$';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ 'a', 'b', 'c', '[def]', 'g', '[,.%\\]$&]', '.', '\\.', '$' ],
        "_lex $str",
    );

    $str = 'abc[def]g[,.%\\]$&{]{2,4}.\\.$';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ 'a', 'b', 'c', '[def]', 'g', '[,.%\\]$&{]{2,4}', '.', '\\.', '$' ],
        "_lex $str",
    );

    $str = '\\w+\\d{2,}\\s+?\\w{1,100}?\\cx*';
    is_deeply( Regexp::Assemble->new->_lex( $str  ),
        [ '\\w+', '\\d{2,}', '\\s+?', '\\w{1,100}?', '\\cx*' ],
        "_lex $str",
    );

    $str = '\\012+\\.?\\xae+\\x{dead}\\x{beef}+';
    is_deeply( Regexp::Assemble->new->_lex( $str  ),
        [ '\\012+', '\\.?', '\\xae+', '\\x{dead}', '\\x{beef}+' ],
        "_lex $str",
    );

    $str = '\\012+\\.?\\xae+\\x{dead}\\x{beef}{2,}';
    is_deeply( Regexp::Assemble->new->_lex( $str  ),
        [ '\\012+', '\\.?', '\\xae+', '\\x{dead}', '\\x{beef}{2,}' ],
        "_lex $str",
    );

    $str = '\\c[\\ca\\c]\\N{foo}';
    is_deeply( Regexp::Assemble->new->_lex( $str  ),
        [ '\\c[', '\\ca', '\\c]', '\\N{foo}' ],
        "_lex $str",
    );

    $str = '\\b(?:ab\(cd\)ef)+?(?:ab[cd]+e)*';
    is_deeply( Regexp::Assemble->new->_lex( $str  ),
        [ '\\b', '(?:ab\(cd\)ef)+?', '(?:ab[cd]+e)*' ],
        "_lex $str",
    );

    $str = '\\A[^bc\]\d]+\\Z';
    is_deeply( Regexp::Assemble->new->_lex( $str  ),
        [ '\\A', '[^bc\]\d]+', '\\Z' ],
        "_lex $str",
    );

    $str = 'a\\d+\\w*:[\\d\\s]+.z(?!foo)d';
    is_deeply( Regexp::Assemble->new->_lex( $str  ),
        [ 'a', '\\d+', '\\w*', ':', '[\\d\\s]+', '.', 'z', '(?!foo)', 'd' ],
        "_lex $str",
    );

    $str = '\t+b*c?';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ '\t+', 'b*', 'c?' ],
        "_lex $str",
    );

    $str = '\Q[';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ '\\[' ],
        "_lex $str",
    );

    $str = '\Q]';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ '\\]' ],
        "_lex $str",
    );

    $str = '\Q(';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ '\\(' ],
        "_lex $str",
    );

    $str = '\Q)';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ '\\)' ],
        "_lex $str",
    );

    $str = '\Qa+b*c?';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str ),
        [ 'a', '\+', 'b', '\*', 'c', '\?' ],
        "_lex $str",
    );

    $str = '\Qa+b*\Ec?';
    is_deeply( Regexp::Assemble->new->_lex( $str ),
        [ 'a', '\+', 'b', '\*', 'c?' ],
        "_lex $str",
    );

    $str = 'a\\LBC\\Ude\\Ef\\Qg+';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str  ),
        [ 'a', 'b', 'c', 'D', 'E', 'f', 'g', '\\+' ],
        "_lex $str",
    );

    $str = 'a\\ub';
    is_deeply( Regexp::Assemble->new->_lex( $str  ),
        [ 'a', 'B' ],
        "_lex $str",
    );

    $str = 'a\\uC';
    is_deeply( Regexp::Assemble->new(debug => 4) ->_lex( $str  ),
        [ 'a', 'C' ],
        "_lex $str",
    );

    $str = 'A\\lB';
    is_deeply( Regexp::Assemble->new->_lex( $str  ),
        [ 'A', 'b' ],
        "_lex $str",
    );

    $str = '\\Qx*';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'x', '\\*' ], "_lex $str" );

    $str = 'a\\Q+x*\\Eb+';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'a', '\\+', 'x', '\\*', 'b+' ], "_lex $str" );

    $str = 'a\\Q+x*b+';
    is_deeply( Regexp::Assemble->new->_lex( $str  ), [ 'a', '\\+', 'x', '\\*', 'b', '\\+' ], "_lex $str" );

    $str = 'a\\Q\\L\\Ez';
    is_deeply( Regexp::Assemble->new->_lex( $str  ), [ 'a', 'z' ], "_lex $str" );

    $str = 'a\\L\\Q\\Ez';
    is_deeply( Regexp::Assemble->new->_lex( $str  ), [ 'a', 'z' ], "_lex $str" );

    $str = 'a\\L\\Q\\U\\Ez';
    is_deeply( Regexp::Assemble->new->_lex( $str  ), [ 'a', 'z' ], "_lex $str" );

    $str = 'a\\L\\Q\\Uz';
    is_deeply( Regexp::Assemble->new->_lex( $str  ), [ 'a', 'Z' ], "_lex $str" );

    $str = '\Q\/?';
    is_deeply( Regexp::Assemble->new->debug(4)->_lex( $str  ), [ '\/', '\?' ], "_lex $str" );

    $str = 'a\\Eb';
    is_deeply( Regexp::Assemble->new->_lex( $str  ), [ 'a', 'b', ], "_lex $str" );

    $str = 'a\\LBCD\\Ee';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'a', 'b', 'c', 'd', 'e' ], "_lex $str" );

    $str = 'f\\LGHI';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'f', 'g', 'h', 'i' ], "_lex $str" );

    $str = 'a\\Ubcd\\Ee';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'a', 'B', 'C', 'D', 'e' ], "_lex $str" );

    $str = 'a\\Ub/d\\Ee';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'a', 'B', '\\/', 'D', 'e' ], "_lex $str" );

    $str = 'f\\Ughi';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'f', 'G', 'H', 'I' ], "_lex $str" );

    $str = 'f\\Ughi\\LMX';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'f', 'G', 'H', 'I', 'm', 'x' ], "_lex $str" );

    $str = 'f\\Ughi\\E\\LMX';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'f', 'G', 'H', 'I', 'm', 'x' ], "_lex $str" );

    $str = 'f\\Ugh\\x20';
    is_deeply( Regexp::Assemble->new->_lex( $str ), [ 'f', 'G', 'H', ' ' ], "_lex $str" );

    $str = 'a\\Q+x*\\Eb+';
    is_deeply( Regexp::Assemble->new->add( $str )->_path,
        [ 'a', '\\+', 'x', '\\*', 'b+' ], "add $str" );

    $str = 'a\\Q+x*b+';
    is_deeply( Regexp::Assemble->new->add( $str )->_path,
        [ 'a', '\\+', 'x', '\\*', 'b', '\\+' ], "add $str" );

    $str = 'X\\LK+L{2,4}M\\EY';
    is_deeply( Regexp::Assemble->new->add( $str )->_path,
        [ 'X', 'k+', 'l{2,4}', 'm', 'Y' ], "add $str" );

    $str = 'p\\Q\\L\\Eq';
    is_deeply( Regexp::Assemble->new->add( $str )->_path,
        [ 'p', 'q' ], "add $str" );

    $str = 'p\\L\\QA+\\EZ';
    is_deeply( Regexp::Assemble->new->debug(4)->add( $str )->_path,
        [ 'p', 'a', '\\+', 'Z' ], "add $str" );

    $str = 'q\\U\\Qh{7,9}\\Ew';
    is_deeply( Regexp::Assemble->new->add( $str )->_path,
        [ 'q', 'H', '\{', '7', ',', '9', '\}', 'w' ], "add $str" );

    $str = 'a\\Ubc\\ldef\\Eg';
    is_deeply( Regexp::Assemble->new->add( $str )->_path,
        [ 'a', 'B', 'C', 'd', 'E', 'F', 'g' ], "add $str" );

    $str = 'a\\LBL+\\uxy\\QZ+';
    is_deeply( Regexp::Assemble->new->add( $str )->_path,
        [ 'a', 'b', 'l+', 'X', 'y', 'z', '\+' ], "add $str" );

    $str = '^\Qa[b[';
    is_deeply( Regexp::Assemble->new->debug(15)->add( $str )->_path,
        [ '^', 'a', '\\[', 'b', '\\[' ], "add $str" );

    $str = '\Q^a[b[';
    is_deeply( Regexp::Assemble->new->add( $str )->_path,
        [ '\\^', 'a', '\\[', 'b', '\\[' ], "add $str" );
}

{
    my $path;

    $path = [];
    is_deeply( $path, Regexp::Assemble::_path_copy($path),
        '_path_copy([])' );

    $path = [0, qw[ab cd ef]];
    is_deeply( $path, Regexp::Assemble::_path_copy($path),
        '_path_copy(0 ab cd ef)' );

    $path = {};
    is_deeply( $path, Regexp::Assemble::_node_copy($path),
        '_node_copy({})' );

    $path = {'a' => [qw[a bb ccc]], 'b'=>[qw[b cc ddd]]};
    is_deeply( $path, Regexp::Assemble::_node_copy($path),
        '_node_copy({a,b})' );

    $path = [
        {'c'=>['c','d'],'e'=>['e','f']},
        't',
        {'d'=>['d','f'],'b'=>['b',0]},
        { '' => undef, 'a' => ['a']},
    ];
    is_deeply( $path, Regexp::Assemble::_path_copy($path),
        '_path_copy({c,e} t {d,b} {* a}' );

    $path = [
        [0, 1, 2],
        ['a','b','c'],
        ['d',{'e'=>['e','f'],'g'=>['g','h']}],
    ];
    is_deeply( $path, Regexp::Assemble::_path_copy($path),
        '_path_copy(ab cd ef {* a})' );
}

is_deeply( $rt->_path, [], 'path is empty' );

my $context = { debug => 0, depth => 0 };

is_deeply( Regexp::Assemble::_unrev_path(
    [0, 1], $context),
    [1, 0], 'path(0,1)' );

is_deeply( Regexp::Assemble::_unrev_path(
    [qw[ ab cd ef ]], $context),
    [qw[ ef cd ab ]], 'path(ab,cd,ef)' );

is_deeply( Regexp::Assemble::_unrev_path( Regexp::Assemble::_unrev_path(
    [qw[ ab cd ef ]], $context), $context),
    [qw[ ab cd ef ]], 'path(ab,cd,ef) back' );

is_deeply( Regexp::Assemble::_unrev_path(
    [qw[ ab cd ef \\d+ \\D ghi jkl mno ]], $context),
    [qw[ mno jkl ghi \\D \\d+ ef cd ab ]], 'path(ab cd...)' );

is_deeply( Regexp::Assemble::_unrev_path( Regexp::Assemble::_unrev_path(
    [qw[ ab cd ef \\d+ \\D ghi jkl mno ]], $context), $context),
    [qw[ ab cd ef \\d+ \\D ghi jkl mno ]], 'path(ab cd...) back' );

is_deeply( Regexp::Assemble::_unrev_node(
    { 0 => [0, 1]}, $context),
    { 1 => [1, 0]},
    'node(0)' );

is_deeply( Regexp::Assemble::_unrev_node(
    { 0 => [0, 1], 2 => [2, 0]}, $context),
    { 1 => [1, 0], 0 => [0, 2]},
    'node(0,2)' );

is_deeply( Regexp::Assemble::_unrev_node(
    { '' => undef, a => [qw[a b]] }, $context),
    { '' => undef, b => [qw[b a]] },
    'node(*,a,b)' );

is_deeply( Regexp::Assemble::_unrev_node(
    { '' => undef, a => [qw[a b]], b => [qw[b c d e f g]] }, $context),
    { '' => undef, b => [qw[b a]], g => [qw[g f e d c b]] },
    'node(*a,b2)' );

is_deeply( Regexp::Assemble::_unrev_path(
    [{x => [qw[x 0]], '' => undef }], $context),
    [{0 => [qw[0 x]], '' => undef }], 'node(* 0)' );

is_deeply( Regexp::Assemble::_unrev_node(
    { ab => [qw[ab bc]], bc => [qw[bc cd de ef fg gh]], ef => [qw[ef gh ij]] }, $context),
    { bc => [qw[bc ab]], gh => [qw[gh fg ef de cd bc]], ij => [qw[ij gh ef]] },
    'node(ab,bc,ef)' );

is_deeply( Regexp::Assemble::_unrev_path(
    [qw[a b], {c=>[qw[c d e]], f=>[qw[f g h]], i=>[qw[i j], {k => [qw[k l m]], n=>[qw[n o p]]}, 'x' ]}], $context),
    [{e=>[qw[e d c]], h=>[qw[h g f]], x=>['x', {m=>[qw[m l k]], p=>[qw[p o n]]}, qw[j i]]}, qw[b a]],
    'path(node(path))');

{
    my $ra = Regexp::Assemble->new
        ->add( 'refused' )
        ->add( 'fused' )
        ->add( 'used' );
    $ra->_reduce;

    ok( eq_set(
        [keys %{Regexp::Assemble::_lookahead($ra->{path}[0])}],
        ['f', 'r']),
        '_lookahead refused/fused/used'
    );

    $ra->reset
        ->add( 'refused' )
        ->add( 'reamused' )
        ->add( 'fused' )
        ->add( 'amused' )
        ->add( 'used' )
        ->_reduce;

    ok( eq_set(
        [keys %{Regexp::Assemble::_lookahead($ra->{path}[0])}],
        ['a', 'f', 'r']),
        '_lookahead reamused/refused/amused/fused/used'
    );

    $ra->reset
        ->add( 'reran' )
        ->add( 'ran' )
        ->_reduce;

    ok( eq_set(
        [keys %{Regexp::Assemble::_lookahead($ra->{path}[0])}],
        ['r']),
        '_lookahead reran/ran'
    );

    $ra->reset
        ->add( 'cruised' )
        ->add( 'bruised' )
        ->add( 'hosed' )
        ->add( 'gazed' )
        ->add( 'used' )
        ->_reduce;

    ok( eq_set(
        [keys %{Regexp::Assemble::_lookahead($ra->{path}[0])}],
        ['b', 'c', 'g', 'h', 'u']),
        '_lookahead cruised/bruised/hosed/gazed/used'
    );
}

cmp_ok( Regexp::Assemble::_dump( [1, 0, undef] ),
    'eq', '[1 0 *]', 'dump 1'
);

cmp_ok( Regexp::Assemble::_dump( [1, 0, q{ }] ),
    'eq', q{[1 0 ' ']}, 'dump 2'
);

cmp_ok( Regexp::Assemble::_dump( {a => ['a', 'b'], b => ['b']} ),
    'eq', '{a=>[a b] b=>[b]}', 'dump 3'
);

cmp_ok( Regexp::Assemble::_combine( '?=', qw/ c a b / ),
    'eq', '(?=[abc])', '_combine c a b'
);

cmp_ok( Regexp::Assemble::_combine( '?=', qw/ c ab de / ),
    'eq', '(?=ab|de|c)', '_combine c ab de'
);

cmp_ok( Regexp::Assemble::_combine( '?=', qw/ in og / ),
    'eq', '(?=in|og)', '_combine in og'
);

cmp_ok( Regexp::Assemble::_combine( '?=', qw/ in og j k l / ),
    'eq', '(?=[jkl]|in|og)', '_combine in og j k l'
);

cmp_ok( Regexp::Assemble::_combine( '?=', qw/ in og 0 1 2 3 4 5 6 7 8 9 / ),
    'eq', '(?=\d|in|og)', '_combine in og 0 1 ... 9'
);

is_deeply( Regexp::Assemble::_unrev_path(
    [{x1     => ['x1', 'z\\d'], '' => undef }], $context),
    [{'z\\d' => ['z\\d', 'x1'], '' => undef }], 'node(* metachar)' );

is_deeply( Regexp::Assemble::_unrev_path(
    [{x     => ['x', '\\d'], '' => undef }], $context),
    [{'\\d' => ['\\d', 'x'], '' => undef }], 'node(* metachar) 2' );

is_deeply( Regexp::Assemble::_unrev_path(
    [qw[ ab cd ef ], {x1 => ['x1', 'y2', 'z\\d'], mx => [qw[mx us ca]] }], $context),
    [{ 'z\\d' => ['z\\d', 'y2', 'x1'], ca => [qw[ca us mx]]}, qw[ef cd ab]], 'path(node)' );

eval {
    my $ra = Regexp::Assemble->new;
    $ra->Default_Lexer( qr/\d+/ );
};

like( $@,
    qr/^Cannot pass a Regexp::Assemble to Default_Lexer at \S+ line \d+/m,
	'Default_Lexer die'
);

cmp_ok( $_, 'eq', $fixed, '$_ has not been altered' );

