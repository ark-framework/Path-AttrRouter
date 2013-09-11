requires 'Class::Data::Inheritable';
requires 'Data::Util';
requires 'Module::Pluggable::Object';
requires 'Mouse', '1.05';
requires 'Text::SimpleTable', '1.1';
requires 'Try::Tiny';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.36';
    requires 'Test::More', '0.88';
};
