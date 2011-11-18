require 'test/unit'
require File.expand_path('../lib/localizable', File.dirname(__FILE__))
require 'mongo_mapper'

class LocalizableTest < Test::Unit::TestCase

    def test_exists
        assert_nothing_raised do
            Localizable
        end
    end

    def test_localized_key
        assert_nothing_raised do
            DummyTest.localized_key :fieldname
        end

        obj = DummyTest.new

        assert_respond_to obj, :fieldname, 'fieldname'
        assert_respond_to obj, :fieldname=, 'fieldname='

        assert DummyTest.key?(:fieldname_values), 'fieldname_values key exists'
        assert_kind_of Hash, obj.fieldname_values
    end

    def test_fetch_default_locale
        begin
            assert_nothing_raised 'assign default locale fetcher' do
                Localizable.fetch_default_locale = Proc.new do
                    :en
                end
            end

            assert_nothing_raised do 'fetch_default_locale'
                assert_equal :en, Localizable.fetch_default_locale
            end
        ensure
            Localizable.reset
        end
    end

    def test_locale_to_string
        begin
            assert_nothing_raised do 'locale_to_string'
                assert_equal 'en', Localizable.locale_to_string(:en)
            end

            assert_nothing_raised 'assign locale to string convertor' do
                Localizable.locale_to_string = Proc.new do |locale|
                    "#{locale}-1"
                end
            end

            assert_equal 'en-1', Localizable.locale_to_string(:en)
            assert_equal 'nl-1', Localizable.locale_to_string(:nl)
        ensure
            Localizable.reset
        end
    end

    def test_locale_assign
        DummyTest.localized_key :fieldname

        obj = DummyTest.new
        obj.fieldname = {
            'en' => 'test 1',
            'nl' => 'test 2'
        }

        assert_equal({ 'en' => 'test 1', 'nl' => 'test 2' }, obj.fieldname_values)

        obj.fieldname = {
            'nl' => 'test 3'
        }

        assert_equal({ 'en' => 'test 1', 'nl' => 'test 3' }, obj.fieldname_values)
    end

    def test_locale_fetch
        DummyTest.localized_key :fieldname
        Localizable.fetch_default_locale = Proc.new do
            'en'
        end

        obj = DummyTest.new

        assert_equal '', obj.fieldname

        obj.fieldname = {
            'en' => 'test 1',
            'nl' => 'test 2'
        }

        assert_equal 'test 1', obj.fieldname
        assert_equal 'test 2', obj.fieldname(:nl)
    end

    def test_locale_with_type
        DummyTest.localized_key :fieldname, LocalizedTestingType
        obj = DummyTest.new

        obj.fieldname = {
            'en' => '1'
        }

        assert_equal({ 'en' => 'a' }, obj.fieldname_values)
        assert_equal 1, obj.fieldname('en')
    end

end

class DummyTest

    include MongoMapper::Document
    include Localizable

end

class LocalizedTestingType

    def self.to_mongo (value)
        'a'
    end

    def self.from_mongo (value)
        1
    end

end