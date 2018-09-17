# frozen_string_literal: true

require 'spec_helper'

describe JsRegex::Converter::BackreferenceConverter do
  it 'preserves traditional numeric backreferences' do
    given_the_ruby_regexp(/(a)(b)(c)\2/)
    expect_js_regex_to_be(/(a)(b)(c)\2/)
    expect_no_warnings
    expect_ruby_and_js_not_to_match(string: 'abc')
    expect_ruby_and_js_to_match(string: 'abcb')
  end

  it 'substitutes ab number backreferences ("\k<1>") with numeric ones' do
    given_the_ruby_regexp(/(a)(b)(c)\k<2>/)
    expect_js_regex_to_be(/(a)(b)(c)\2/)
    expect_no_warnings
    expect_ruby_and_js_not_to_match(string: 'abc')
    expect_ruby_and_js_to_match(string: 'abcb')
  end

  it 'substitutes sq number backreferences ("\k\'1\'") with numeric ones' do
    given_the_ruby_regexp(/(a)(b)(c)\k'2'/)
    expect_js_regex_to_be(/(a)(b)(c)\2/)
    expect_no_warnings
    expect_ruby_and_js_not_to_match(string: 'abc')
    expect_ruby_and_js_to_match(string: 'abcb')
  end

  it 'substitutes ab relative backreferences ("\k<-1>") with numeric ones' do
    given_the_ruby_regexp(/(a)(b)(c)\k<-1>/)
    expect_js_regex_to_be(/(a)(b)(c)\3/)
    expect_no_warnings
    expect_ruby_and_js_not_to_match(string: 'abc')
    expect_ruby_and_js_to_match(string: 'abcc')
  end

  it 'substitutes sq relative backreferences ("\k\'-1\'") with numeric ones' do
    given_the_ruby_regexp(/(a)(b)(c)\k'-1'/)
    expect_js_regex_to_be(/(a)(b)(c)\3/)
    expect_no_warnings
    expect_ruby_and_js_not_to_match(string: 'abc')
    expect_ruby_and_js_to_match(string: 'abcc')
  end

  it 'substitutes deep relative backreferences ("\k<-3>") with numeric ones' do
    given_the_ruby_regexp(/(a)(b)(c)\k<-3>/)
    expect_js_regex_to_be(/(a)(b)(c)\1/)
    expect_no_warnings
    expect_ruby_and_js_not_to_match(string: 'abc')
    expect_ruby_and_js_to_match(string: 'abca')
  end

  it 'substitutes relative backreferences to nested groups correctly' do
    given_the_ruby_regexp(/(a(b)a)\k<-1>/)
    expect_js_regex_to_be(/(a(b)a)\2/)
    expect_no_warnings
    expect_ruby_and_js_not_to_match(string: 'abaa')
    expect_ruby_and_js_to_match(string: 'abab')
  end

  it 'substitutes ab named backreferences ("\k<foo>") with numeric ones' do
    given_the_ruby_regexp(/(a)(?<foo>b)(c)\k<foo>/)
    expect_js_regex_to_be(/(a)(b)(c)\2/)
    expect_no_warnings
    expect_ruby_and_js_not_to_match(string: 'abc')
    expect_ruby_and_js_to_match(string: 'abcb')
  end

  it 'substitutes sq named backreferences ("\k\'foo\'") with numeric ones' do
    given_the_ruby_regexp(/(a)(?'foo'b)(c)\k'foo'/)
    expect_js_regex_to_be(/(a)(b)(c)\2/)
    expect_no_warnings
    expect_ruby_and_js_not_to_match(string: 'abc')
    expect_ruby_and_js_to_match(string: 'abcb')
  end

  context 'when there are preceding substitutions' do
    it 'increments traditional number backrefs accordingly' do
      given_the_ruby_regexp(/(?>aa|a)(?>aa|a)(X)\1/)
      expect_js_regex_to_be(/(?=(aa|a))\1(?:)(?=(aa|a))\2(?:)(X)\3/)
      expect_ruby_and_js_not_to_match(string: 'aaaaX')
      expect_ruby_and_js_to_match(string: 'aaaaXX')
    end

    it 'increments \k-style number backrefs accordingly' do
      given_the_ruby_regexp(/(?>aa|a)(?>aa|a)(X)\k<1>/)
      expect_js_regex_to_be(/(?=(aa|a))\1(?:)(?=(aa|a))\2(?:)(X)\3/)
      expect_ruby_and_js_not_to_match(string: 'aaaaX')
      expect_ruby_and_js_to_match(string: 'aaaaXX')
    end

    it 'increments relative backrefs accordingly' do
      given_the_ruby_regexp(/(?>aa|a)(?>aa|a)(X)\k<-1>/)
      expect_js_regex_to_be(/(?=(aa|a))\1(?:)(?=(aa|a))\2(?:)(X)\3/)
      expect_ruby_and_js_not_to_match(string: 'aaaaX')
      expect_ruby_and_js_to_match(string: 'aaaaXX')
    end

    it 'increments name backrefs accordingly' do
      given_the_ruby_regexp(/(?>aa|a)(?>aa|a)(?<foo>X)\k<foo>/)
      expect_js_regex_to_be(/(?=(aa|a))\1(?:)(?=(aa|a))\2(?:)(X)\3/)
      expect_ruby_and_js_not_to_match(string: 'aaaaX')
      expect_ruby_and_js_to_match(string: 'aaaaXX')
    end
  end

  context 'when there are group additions after the backref' do
    it 'does not increment traditional number backrefs' do
      given_the_ruby_regexp(/(a)\1_1(?>33|3)37/)
      expect_js_regex_to_be(/(a)\1_1(?=(33|3))\2(?:)37/)
      expect_no_warnings
      expect_ruby_and_js_not_to_match(string: 'aa_1337')
      expect_ruby_and_js_to_match(string: 'aa_13337')
    end

    it 'does not increment \k-style number backrefs' do
      given_the_ruby_regexp(/(a)\k<1>_1(?>33|3)37/)
      expect_js_regex_to_be(/(a)\1_1(?=(33|3))\2(?:)37/)
      expect_no_warnings
      expect_ruby_and_js_not_to_match(string: 'aa_1337')
      expect_ruby_and_js_to_match(string: 'aa_13337')
    end

    it 'does not increment relative number backrefs' do
      given_the_ruby_regexp(/(a)\k<-1>_1(?>33|3)37/)
      expect_js_regex_to_be(/(a)\1_1(?=(33|3))\2(?:)37/)
      expect_no_warnings
      expect_ruby_and_js_not_to_match(string: 'aa_1337')
      expect_ruby_and_js_to_match(string: 'aa_13337')
    end

    it 'does not increment name backrefs' do
      given_the_ruby_regexp(/(?<foo>a)\k<foo>_1(?>33|3)37/)
      expect_js_regex_to_be(/(a)\1_1(?=(33|3))\2(?:)37/)
      expect_no_warnings
      expect_ruby_and_js_not_to_match(string: 'aa_1337')
      expect_ruby_and_js_to_match(string: 'aa_13337')
    end
  end

  context 'when there are group additions between the backref and its target' do
    it 'does not increments traditional number backrefs' do
      given_the_ruby_regexp(/(X)(?>aa|a)\1/)
      expect_js_regex_to_be(/(X)(?=(aa|a))\2(?:)\1/)
      expect_ruby_and_js_not_to_match(string: 'Xa')
      expect_ruby_and_js_to_match(string: 'XaX')
    end

    it 'does not increments \k-style number backrefs' do
      given_the_ruby_regexp(/(X)(?>aa|a)\k<1>/)
      expect_js_regex_to_be(/(X)(?=(aa|a))\2(?:)\1/)
      expect_ruby_and_js_not_to_match(string: 'Xa')
      expect_ruby_and_js_to_match(string: 'XaX')
    end

    it 'does not increments relative number backrefs' do
      given_the_ruby_regexp(/(X)(?>aa|a)\k<-1>/)
      expect_js_regex_to_be(/(X)(?=(aa|a))\2(?:)\1/)
      expect_ruby_and_js_not_to_match(string: 'Xa')
      expect_ruby_and_js_to_match(string: 'XaX')
    end

    it 'does not increments name backrefs' do
      given_the_ruby_regexp(/(?<foo>X)(?>aa|a)\k<foo>/)
      expect_js_regex_to_be(/(X)(?=(aa|a))\2(?:)\1/)
      expect_ruby_and_js_not_to_match(string: 'Xa')
      expect_ruby_and_js_to_match(string: 'XaX')
    end
  end

  # see second_pass_spec.rb for tests of the final subexp call results
  context 'when dealing with subexp calls' do
    it 'marks subexp calls for SecondPass conversion' do
      conditional = Regexp::Parser.parse(/(a)\g<1>/).last

      result = JsRegex::Converter.convert(conditional)

      expect(result).to be_a JsRegex::Node
      expect(result.reference).to eq 1
      expect(result.type).to eq :subexp_call
    end

    it 'marks named subexp calls for SecondPass conversion' do
      conditional = Regexp::Parser.parse(/(?<A>a)\g<A>/).last

      result = JsRegex::Converter.convert(conditional)

      expect(result).to be_a JsRegex::Node
      expect(result.reference).to eq 'A'
      expect(result.type).to eq :subexp_call
    end

    it 'marks relative subexp calls for SecondPass conversion' do
      conditional = Regexp::Parser.parse(/(a)(b)\g<-1>/).last
      context = JsRegex::Converter::Context.new
      2.times { context.capture_group }

      result = JsRegex::Converter.convert(conditional, context)

      expect(result).to be_a JsRegex::Node
      expect(result.reference).to eq 2
      expect(result.type).to eq :subexp_call
    end

    it 'marks forward-referring subexp calls for SecondPass conversion' do
      conditional = Regexp::Parser.parse(/(a)\g<+1>(b)/)[1]
      context = JsRegex::Converter::Context.new
      context.capture_group # only preceding group is captured at this point

      result = JsRegex::Converter.convert(conditional, context)

      expect(result).to be_a JsRegex::Node
      expect(result.reference).to eq 2
      expect(result.type).to eq :subexp_call
    end

    it 'drops whole-pattern recursion calls with warning' do
      given_the_ruby_regexp(/(a(b|\g<0>))/)
      expect_js_regex_to_be(/(a(b))/)
      expect_warning('whole-pattern recursion')
    end
  end
end
